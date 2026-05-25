# Rating Service

Source: `apps/backend/rating-service/`

## Purpose

Captures one-time, post-completion star ratings (1-5) plus optional review text, tags, and photos for any rateable target (driver, rider, restaurant, food delivery). Maintains a per-target denormalized aggregate so consumer apps can render an average score and distribution histogram in O(1) without scanning the rating table.

The service runs on port `3008` (override with `PORT`), exposes a NestJS REST API under `api/v1`, and shares the standard observability surface (`/healthz`, `/readyz`, `/metrics`).

## Data model

Two TypeORM entities backed by Postgres.

### `ratings`

`apps/backend/rating-service/src/ratings/entities/rating.entity.ts`

```text
id            uuid              PK, generated
raterId       string            who left the rating
targetId      string            who/what was rated
targetType    enum              DRIVER | RIDER | RESTAURANT | DELIVERY
context       enum              RIDE | ORDER
referenceId   string            unique - the ride or order id
score         smallint          1..5 (validated by class-validator)
review        text?             optional free text
tags          jsonb?            ['friendly', 'fast', ...]
photos        jsonb?            URLs
flagged       boolean           default false
flagReason    text?             populated by moderators
hidden        boolean           default false
createdAt     timestamptz       auto

INDEX (targetId, targetType)
INDEX (raterId)
UNIQUE INDEX (referenceId)
```

The `referenceId` unique index plus the explicit `findOne({ referenceId, raterId })` check in `RatingsService.create` enforce one rating per rater per ride/order.

### `rating_aggregates`

`apps/backend/rating-service/src/ratings/entities/rating-aggregate.entity.ts`

```text
targetId       string            PK part 1
targetType     enum              PK part 2
avgScore       decimal(3,2)      rolling average, default 0
totalRatings   int               default 0
count1..count5 int               distribution buckets, default 0
updatedAt      timestamptz       auto
```

Composite primary key `(targetId, targetType)` so the same id can carry independent aggregates (for example a user who is both a `DRIVER` and a `RIDER`).

## API endpoints

Base path: `/api/v1` (set via `app.setGlobalPrefix('api/v1', { exclude: ['health', 'healthz', 'readyz', 'metrics'] })`).

| Method | Path                                      | Body / Query                                            | Returns |
|--------|-------------------------------------------|---------------------------------------------------------|---------|
| POST   | `/ratings`                                | `CreateRatingDto`                                       | created `RatingEntity` |
| GET    | `/ratings/:id`                            | -                                                       | `RatingEntity` (404 if missing) |
| GET    | `/ratings/target/:targetType/:targetId`   | `?page=1&limit=20&minScore=4`                           | `{ data, total, page, limit }` |
| GET    | `/ratings/aggregate/:targetType/:targetId`| -                                                       | `{ targetId, targetType, avgScore, totalRatings, distribution }` |
| GET    | `/ratings/reference/:referenceId`         | -                                                       | `RatingEntity[]` for the ride/order |
| GET    | `/ratings/rater/:raterId`                 | `?limit=50`                                             | recent ratings authored by this user |
| PUT    | `/ratings/:id/flag`                       | `{ reason: string }`                                    | flagged rating |
| PUT    | `/ratings/:id/hide`                       | -                                                       | hidden rating |

`CreateRatingDto`:

```text
raterId       string                     required
targetId      string                     required
targetType    DRIVER|RIDER|RESTAURANT|DELIVERY
context       RIDE|ORDER
referenceId   string                     unique per (rater, reference)
score         int  1..5
review        string?
tags          string[]?
photos        string[]?
```

Validation runs through `ValidationPipe({ whitelist: true, transform: true })` set up in `main.ts`, so unknown fields are stripped before the DTO reaches the service layer.

The list endpoint hides flagged or hidden rows by filtering `r.hidden = false` in the query builder; aggregates do not (they reflect the full historical signal).

## Aggregate update on insert

`RatingsService.create` runs the rating insert and the aggregate upsert in a single TypeORM `dataSource.transaction`:

1. Reject duplicates: `findOne({ referenceId, raterId })` returns existing -> `ConflictException('Already rated')`.
2. Insert the `RatingEntity`.
3. Look up `RatingAggregateEntity` by `(targetId, targetType)`.
   - **First rating for the target**: create a new aggregate with `avgScore = score`, `totalRatings = 1`, and the appropriate `count{N}` bucket set to 1.
   - **Subsequent ratings**: recompute incrementally without rescanning the rating table:

     ```text
     newTotal  = oldTotal + 1
     newSum    = oldAvg * oldTotal + score
     newAvg    = round(newSum / newTotal, 2)
     count{N}  = oldCount{N} + 1
     ```

4. Save the aggregate. The transaction commits atomically; partial state (rating without aggregate or vice versa) cannot be observed.

`getAggregate` returns a normalized payload even when no aggregate row exists, so clients can rely on the same shape:

```json
{ "targetId": "...", "targetType": "DRIVER",
  "avgScore": 0, "totalRatings": 0,
  "distribution": { "1": 0, "2": 0, "3": 0, "4": 0, "5": 0 } }
```

## Position in completion flows

The rating service is the trailing leg of two journeys.

- **Ride completion**: when `ride-service` marks a ride `COMPLETED`, the rider app prompts for a driver rating and the driver app prompts for a rider rating. Both calls hit `POST /api/v1/ratings` with `context = RIDE` and `referenceId = rideId`. The unique index on `referenceId` blocks accidental double submission.
- **Food order completion**: when `food-service` marks an order `DELIVERED`, the customer app prompts for a `RESTAURANT` rating and a `DELIVERY` (driver) rating. Both calls use `context = ORDER` and `referenceId = orderId`.

Driver score on the rider app, restaurant score on the menu, and rider profile reputation in the admin console all read `GET /ratings/aggregate/:targetType/:targetId`, which is O(1) thanks to the denormalized `rating_aggregates` row.

## Type sharing

The mobile and admin clients re-declare a small Rating shape locally rather than importing from `packages/common-types/src/index.ts` (no `Rating` export today). When sharing types becomes necessary, add the entity-mirroring interface to `packages/common-types` and import it across services.

## Related docs

- [../README.md](../README.md)
- [./INDEX.md](./INDEX.md)
- [./RIDE_MATCHING.md](./RIDE_MATCHING.md)
- [./FOOD_DELIVERY.md](./FOOD_DELIVERY.md)
