# Ride Matching

## Overview

When a rider requests a ride the **MatchingService** in `apps/backend/ride-service/src/matching/` picks the best available driver and offers the ride to them over the `/ride` socket namespace. This doc covers the full pipeline: queue, scoring, dispatch, and re-match.

For status transitions on the wire, see [REALTIME.md](./REALTIME.md). For schema details, see [DATABASE.md](./DATABASE.md).

## Pipeline

```
ride request ─▶ rides.service ─▶ MatchingQueue (BullMQ)
                                       │
                                       ▼
                              MatchingProcessor.process()
                                       │
                                       ▼
                              MatchingService.findBestDriver()
                                       │
                                       ▼
                              ride:offered ─▶ driver:<id>
                                       │
                              ┌────────┴────────┐
                       accept ▼                 ▼ reject / timeout
                  assign + status MATCHED   re-enqueue (excludeDriver)
```

The producer (rides controller) **never blocks on matching** — it persists the ride row, returns `201` to the rider, and pushes a `RideMatchJob` onto the BullMQ queue. The matching processor consumes asynchronously. This keeps p95 of `POST /rides` under 200ms even when the matching pool is hot.

## Queue

`apps/backend/ride-service/src/matching/matching-queue.module.ts` registers a BullMQ queue named `ride-matching` against the shared Redis instance.

```typescript
export const RIDE_MATCHING_QUEUE = 'ride-matching';

interface RideMatchJob {
  rideId: string;
  pickupLat: number;
  pickupLng: number;
  excludeDriverIds?: string[];   // for re-match after rejection
  attempt: number;               // incremented on each retry
}
```

Default job options:

| Option       | Value | Why                                              |
|--------------|-------|--------------------------------------------------|
| `attempts`   | 5     | At most 5 driver offers before falling back     |
| `backoff`    | 4 s exponential | Avoids thundering-herd on a busy region |
| `removeOnComplete` | 100 | Keep recent jobs for debugging              |
| `removeOnFail`     | 500 | Keep failures for postmortem                |

## Scoring

`MatchingService.findBestDriver()` ranks every eligible driver inside the search radius using a weighted score:

```
score = 0.7 * (1 - normalized_distance) + 0.3 * normalized_rating
```

| Constant            | Value | Source                                        |
|---------------------|-------|-----------------------------------------------|
| `SEARCH_RADIUS_M`   | 3000  | `matching.service.ts`                         |
| `DISTANCE_WEIGHT`   | 0.7   | Distance is the dominant factor              |
| `RATING_WEIGHT`     | 0.3   | Quality breaks ties between near drivers     |

Normalization is done **inside the candidate set**, not against a fixed scale:

- `normalized_distance = driver.distance_m / max(distances)` — the closest driver gets the full distance reward, the furthest gets zero.
- `normalized_rating = (rating - 1.0) / (5.0 - 1.0)` — clamps to the 1–5 star range used by the rating service.

Drivers in `excludeDriverIds` (rejected this ride before, currently on another trip, recently disconnected) are filtered out before scoring.

## Driver eligibility

A driver enters the candidate pool only if **all** of these hold:

1. Status `ONLINE` and not on an active ride.
2. Last `driver:location` update arrived within the last 30 s (sorted-set TTL in Redis).
3. Vehicle type matches the request (`car`, `bike`, `premium`).
4. Not flagged for review (no soft-suspension on the account).
5. Not in the `excludeDriverIds` set for this job.

Lookups go through `DriversService.findNearbyDrivers(lat, lng, radius)` which uses a Redis GEO index (`drivers:geo`) populated by the location stream in [REALTIME.md](./REALTIME.md). The bounded radius is critical — a city-wide query is O(n) and will cripple matching at scale.

## Offer and acceptance

Once a driver is selected:

1. Ride row is updated to `MATCHED`, `driver_id` set, `matched_at = NOW()`.
2. Gateway emits `ride:offered` to `driver:<id>` with `{ rideId, pickup, dropoff, fare, expiresIn: 15 }`.
3. Rider receives `ride:status MATCHED` with the driver's profile snippet.

The driver has **15 seconds** to accept. Three outcomes:

| Outcome     | Server action                                                              |
|-------------|----------------------------------------------------------------------------|
| Accept      | `ride.status = ACCEPTED`. Job complete. Publish `ride:status ACCEPTED`.   |
| Explicit reject | Add driver to `excludeDriverIds`. Re-enqueue job with `attempt + 1`.   |
| Timeout (no response) | Treated like a reject. Driver gets a soft strike (3 timeouts in 1h triggers a 10-minute cool-down). |

## Surge

Surge multiplier is computed by `FareService.calculateSurge(activeRequests, onlineDrivers)`:

```
demandRatio = activeRequests / onlineDrivers
surge       = clamp(1.0, 3.0, 1.0 + 0.5 * (demandRatio - 1))
```

The multiplier is captured on the ride row at request time, not at acceptance — riders see the price they agreed to, and drivers see the same number reflected in their offer. Surge is recalculated every minute by a separate cron, never per-request, to avoid step-function jumps that confuse riders.

## Re-match flow

If the matching processor returns `null` (no eligible drivers in radius) **or** the offer times out / is rejected, the job is re-enqueued with:

- `excludeDriverIds` extended.
- `attempt + 1`.
- Backoff scaled by attempt count.

After 5 attempts the job is dead-lettered and the rider is notified via `ride:status NO_DRIVERS_AVAILABLE`. They can retry — a new request creates a new job from scratch.

## Cancellation

A rider cancelling at `REQUESTED` simply marks the ride `CANCELLED` and removes the queue job. A rider cancelling at `MATCHED`/`ACCEPTED` does the same plus emits `ride:cancelled` to `driver:<id>`. Cancellations after `IN_TRIP` are blocked at the API layer and require dispatcher intervention.

## Observability

Every match attempt emits structured logs with `request_id`, `ride_id`, `driver_id`, `score`, `distance_m`, `attempt`. Prometheus metrics:

- `crab_matching_attempt_total{outcome}` — counter, outcomes are `matched`, `no_drivers`, `rejected`, `timeout`.
- `crab_matching_duration_seconds{quantile}` — histogram of end-to-end match time.
- `crab_matching_radius_drivers{radius=3000}` — gauge of drivers found per attempt.

Grafana dashboard `dashboards/matching.json` plots p95 match time and the no-drivers rate per region.

## Failure modes

| Symptom                              | Likely cause                        | Where to look                              |
|--------------------------------------|-------------------------------------|--------------------------------------------|
| Job stuck in `waiting`               | BullMQ worker not running           | `pnpm --filter @crab/ride-service start` logs |
| Every request → `NO_DRIVERS_AVAILABLE` | Geo index empty                  | `redis-cli ZCARD drivers:geo`              |
| Drivers see no offers                | Wrong namespace / stale token        | Gateway handshake logs                     |
| Surge stuck > 1.0 with low demand    | `online_drivers` query slow         | `EXPLAIN` in [DATABASE.md](./DATABASE.md)  |

## Testing

- Unit: `apps/backend/ride-service/src/fare/fare.service.spec.ts`, `rides/rides.service.spec.ts` cover scoring math + happy/sad paths with mocked `DriversService`.
- Integration: `tests/integration/ride-flow.spec.ts` (Postgres + Redis) drives a request → match → accept → complete sequence.
- Load: `tests/load/ride-flow.js` keeps 50 active riders and 200 drivers and gates on p95 match time.
