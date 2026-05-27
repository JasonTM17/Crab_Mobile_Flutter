# Crab load tests

Reproducible load profiles for the production-like local demo. The scripts
exercise the gateway edge because `docker-compose.prod.yml` publishes the
gateway/nginx boundary and keeps internal service ports private.

## Prerequisites

- A running stack reachable from your machine. Defaults assume the local Docker
  gateway at `http://localhost:3000`.
- Demo data loaded with `pnpm run db:migrate && pnpm run db:seed`.
- k6 v0.50+ for direct `k6 run ...` usage and the deeper ride/order scenarios.
  On Windows, `pnpm run test:load` also checks `C:\Program Files\k6\k6.exe`
  when the current terminal has not picked up PATH changes yet. The default
  root command has a Node fallback for the gateway baseline when k6 is not
  installed.

## Required environment variables

| Variable | Default | Used by |
| --- | --- | --- |
| `BASE_URL` | `http://localhost:3000` | All scripts |
| `JWT_TOKEN` | empty | `ride-flow.js`, `order-flow.js` reuse if set; otherwise scripts log in |
| `RIDER_ID` | empty | Required only when `JWT_TOKEN` is supplied |
| `LOGIN_EMAIL` | `rider@crab.app` | Login step when no `JWT_TOKEN` is provided |
| `LOGIN_PASSWORD` | `User123!` | Same as above |
| `CRAB_RIDE_TARGET_VUS` | `3` | `ride-flow.js` local demo concurrency |
| `CRAB_RIDE_DURATION` | `30s` | `ride-flow.js` steady-state duration |
| `CRAB_ORDER_TARGET_VUS` | `3` | `order-flow.js` local demo concurrency |
| `CRAB_ORDER_DURATION` | `30s` | `order-flow.js` steady-state duration |

## Run

```sh
pnpm run test:load
k6 run tests/load/baseline-smoke.js
k6 run tests/load/ride-flow.js
k6 run tests/load/order-flow.js
```

Run all k6 scripts through the root runner:

```powershell
$env:CRAB_LOAD_SCRIPTS = "tests/load/baseline-smoke.js,tests/load/ride-flow.js,tests/load/order-flow.js"
pnpm run test:load
Remove-Item Env:CRAB_LOAD_SCRIPTS
```

When k6 is not installed, `pnpm run test:load` runs a built-in Node baseline
against `/health` and `/api/v1/proxy/health`. Override its defaults with:

| Variable | Default | Node fallback only |
| --- | --- | --- |
| `CRAB_LOAD_VUS` | `1` | Concurrent workers |
| `CRAB_LOAD_DURATION_MS` | `5000` | Test duration |
| `CRAB_LOAD_P99_MS` | `500` | p99 latency threshold |
| `CRAB_LOAD_TIMEOUT_MS` | `2000` | Request timeout |

Override env inline:

```sh
k6 run -e BASE_URL=https://staging.crab.app -e CRAB_RIDE_TARGET_VUS=10 tests/load/ride-flow.js
```

## Thresholds

- `baseline-smoke.js` - `http_req_duration p(99) < 500ms`, `http_req_failed = 0`.
- `ride-flow.js` - `http_req_duration p(95) < 700ms`, `http_req_failed < 1%`.
- `order-flow.js` - `http_req_duration p(95) < 900ms`, `http_req_failed < 2%`.

A red threshold fails the run with a non-zero exit code.

## Interpretation

- `http_req_duration` - server-side plus network latency.
- `http_req_failed` - share of non-2xx responses.
- `iterations` / `vus` - concurrency reached.
- `checks` - assertion success rate; less than 100% means a payload regressed.
