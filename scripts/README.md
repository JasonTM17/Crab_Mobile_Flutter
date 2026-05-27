# Scripts

Utility scripts for local production-like portfolio validation.

## Database

The canonical local demo path uses Postgres SQL so it works without local
`ts-node`, TypeORM, or native bcrypt bindings.

```bash
# Requires the postgres container to be running, unless DATABASE_URL + psql exist locally.
pnpm run db:migrate
pnpm run db:seed
```

`db:migrate` applies `scripts/schema.sql`.
`db:seed` applies `scripts/seed.sql`.

The runner prefers `DATABASE_URL` with local `psql` when available. Otherwise it
executes `psql` inside the `postgres` service from `docker-compose.prod.yml`,
using `.env.production` when present and `.env.production.example` as fallback.

## Demo Accounts

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@crab.app` | `Admin123!` |
| Rider | `rider@crab.app` | `User123!` |
| Driver | `driver@crab.app` | `Driver123!` |
| Merchant | `merchant@crab.app` | `User123!` |

## E2E And Load

```bash
pnpm run test:e2e
pnpm run test:load
```

`test:e2e` runs `scripts/portfolio-smoke.js` against the local gateway and
checks the seeded production-like demo path: gateway/proxy health, all demo
account logins, protected-route rejection, profile and addresses, wallet top-up
and transactions, food order lifecycle, ride lifecycle, ratings,
notifications, and chat.

`test:load` runs the default gateway baseline through k6 when available. On
Windows, the runner also checks `C:\Program Files\k6\k6.exe` so a newly
installed k6 can be used before the terminal PATH refreshes. If k6 is not
installed, it falls back to a built-in Node baseline for the default
`tests/load/baseline-smoke.js` script. Override `CRAB_LOAD_SCRIPTS` with a
comma-separated list to run `ride-flow.js` and `order-flow.js`; those deeper
scenarios require k6.

## Security

```bash
pnpm run security:audit
```

`security:audit` runs `pnpm audit --audit-level moderate` so the command fails
on moderate, high, or critical dependency advisories.
