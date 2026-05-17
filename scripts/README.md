# Scripts

Utility scripts for database management and development.

## Database

```bash
# Run schema migration (creates tables)
pnpm ts-node scripts/migrate.ts

# Seed demo data
pnpm ts-node scripts/seed.ts

# Or with Docker
docker compose exec gateway npx ts-node /app/scripts/migrate.ts
docker compose exec gateway npx ts-node /app/scripts/seed.ts
```

## Demo Accounts (after seeding)

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@crab.app | Admin123! |
| Rider | rider@crab.app | User123! |
| Driver | driver@crab.app | Driver123! |
| Restaurant | restaurant@crab.app | User123! |

## Environment

Scripts read `DATABASE_URL` from environment. Default: `postgresql://crab:crab@localhost:5432/crab`
