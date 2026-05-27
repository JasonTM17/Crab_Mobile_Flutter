# Testing Guide

Crab uses layered checks so portfolio claims can be backed by repeatable
commands, not screenshots alone.

## Test Matrix

| Layer | Command | Notes |
| --- | --- | --- |
| Package/release guardrails | `pnpm run package:check` | Private package metadata, Docker namespace, release media references |
| API contract | `pnpm run contract:check` | Static OpenAPI and shared contract drift checks |
| Backend units | `pnpm test` | Turbo runs package tests with one worker group |
| Dependency security audit | `pnpm run security:audit` | Fails on moderate, high, or critical advisories |
| Admin build | `pnpm --filter @crab/web-admin build` | Vite production build |
| Mobile analyze | `pnpm run mobile:analyze` | Flutter analyze through the mobile helper |
| Mobile tests | `pnpm run mobile:test` | Flutter unit/widget/BLoC tests |
| Release media | `pnpm run mobile:screenshots` | Regenerates verified Flutter release screenshots |
| Compose config | `pnpm run docker:config` | Parses `docker-compose.prod.yml` with `.env.production.example` |
| Gateway E2E | `pnpm run test:e2e` | Requires a running local gateway and seeded demo data |
| Load baseline | `pnpm run test:load` | Uses k6 when installed; otherwise uses the built-in Node gateway baseline. Requires a running local gateway |

## Portfolio Verification

For a normal code/docs/media pass:

```bash
pnpm run verify:portfolio
```

For dependency advisories:

```bash
pnpm run security:audit
```

For the full local Docker demo:

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d
pnpm run db:migrate
pnpm run db:seed
pnpm run test:e2e
pnpm run test:load
```

`test:e2e` is a deterministic gateway-backed E2E suite. It writes unique demo
records for the current run and validates:

- gateway health
- proxy health
- admin, rider, driver, and merchant demo-account login
- protected route rejection without auth
- rider profile and saved addresses
- wallet balance, top-up, and transaction history
- restaurant discovery
- menu item lookup
- food order creation, restaurant order views, status progression, driver
  assignment, delivered lookup, and restaurant stats
- fare estimate, ride creation, driver accept, active ride views, status
  progression, rider history, and driver stats
- restaurant rating creation, reference lookup, aggregate lookup, and rater
  lookup
- notification creation, list, unread count, mark read, and mark all read
- chat room creation, message send/list, and room read state

## Load Tests

k6 scripts live under `tests/load/`. The default root command remains useful on
machines without k6: `pnpm run test:load` falls back to a conservative
Node-based gateway baseline for `tests/load/baseline-smoke.js`. The fallback
preserves the same local prerequisite, so it still fails if the gateway is not
running. On Windows, the root runner also detects
`C:\Program Files\k6\k6.exe` when k6 was just installed and the terminal PATH
has not refreshed.

```bash
pnpm run test:load
CRAB_LOAD_SCRIPTS=tests/load/ride-flow.js pnpm run test:load
CRAB_LOAD_SCRIPTS=tests/load/order-flow.js pnpm run test:load
```

PowerShell syntax:

```powershell
$env:CRAB_LOAD_SCRIPTS = "tests/load/baseline-smoke.js,tests/load/ride-flow.js,tests/load/order-flow.js"
pnpm run test:load
Remove-Item Env:CRAB_LOAD_SCRIPTS
```

The ride/order defaults are intentionally local-demo safe: 3 VUs with a short
ramp and 30-second steady state. Increase `CRAB_RIDE_TARGET_VUS`,
`CRAB_RIDE_DURATION`, `CRAB_ORDER_TARGET_VUS`, or `CRAB_ORDER_DURATION` for a
separate stress profile. Hitting the gateway throttle at higher concurrency is
expected unless the load environment is configured for stress testing.

Defaults use the seeded rider account:

- `rider@crab.app`
- `User123!`

If you provide `JWT_TOKEN`, also provide `RIDER_ID` so ride/order payloads can
use a real user id.

## Mobile Release Media

The public mobile screenshots are generated from
`apps/mobile/test/release_media_screenshots_test.dart`.

```bash
pnpm run mobile:screenshots
```

The GIF walkthrough is built from those screenshots and stored at
`docs/gifs/mobile-client-flow.gif`.

## Local Caveats

- `pnpm run test:e2e` and `pnpm run test:load` require the local stack to be
  running first.
- k6 v0.50+ is required for `ride-flow.js`, `order-flow.js`, and direct
  `k6 run ...` commands. The default `pnpm run test:load` baseline has a Node
  fallback when k6 is not installed.
- On Windows, stale file locks in `node_modules` can break installs; close
  editors/watchers and retry.
