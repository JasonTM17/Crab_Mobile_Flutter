# Crab load tests (k6)

Reproducible load profiles that exercise the most contended user journeys
on Crab Super App's NestJS backend. All scripts use modern k6 ESM syntax.

## Prerequisites

- [k6](https://k6.io/) v0.50+ installed locally or in CI.
- A running stack reachable from your machine (defaults assume the local
  `docker compose up` topology with the API gateway on `:3000`).

## Required environment variables

| Variable     | Default                  | Used by                                  |
|--------------|--------------------------|------------------------------------------|
| `BASE_URL`   | `http://localhost:3000`  | All scripts                              |
| `JWT_TOKEN`  | _(empty)_                | `ride-flow.js`, `order-flow.js` reuse if set; otherwise scripts log in |
| `LOGIN_EMAIL`| `loadtest@crab.dev`      | Login step when no `JWT_TOKEN` provided  |
| `LOGIN_PASSWORD`| `LoadTest!2026`       | Same as above                            |

## Run

```sh
k6 run tests/load/baseline-smoke.js
k6 run tests/load/ride-flow.js
k6 run tests/load/order-flow.js
```

Override env inline: `k6 run -e BASE_URL=https://staging.crab.app tests/load/ride-flow.js`.

## Thresholds (CI gates)

- `baseline-smoke.js` — `http_req_duration p(99) < 200ms`, `http_req_failed = 0`.
- `ride-flow.js` — `http_req_duration p(95) < 500ms`, `http_req_failed < 1%`.
- `order-flow.js` — `http_req_duration p(95) < 800ms`, `http_req_failed < 2%`.

A red threshold fails the run with non-zero exit code; wire that into CI to
catch regressions on `main`.

## Interpretation

- **`http_req_duration`** — server-side + network latency.
- **`http_req_failed`** — share of non-2xx responses; investigate spikes.
- **`iterations`** / **`vus`** — concurrency reached. Compare against ramp.
- **`checks`** — assertion success rate; <100% means a payload regressed.
