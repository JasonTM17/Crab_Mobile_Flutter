# Docker

Development-only Docker Compose configuration for running infrastructure services (databases, cache, object storage) without the application services.

## Usage

```bash
# Start infrastructure only (for local development)
docker compose -f docker/docker-compose.infra.yml up -d

# Then run services locally
pnpm dev
```

## Services

| Service | Port | Purpose |
|---------|------|---------|
| PostgreSQL | 5432 | Primary relational database |
| MongoDB | 27017 | Document store for chat/notifications |
| Redis | 6379 | Cache, sessions, Socket.IO adapter |

## Credentials (dev only)

- PostgreSQL: `crab:crab` / database: `crab`
- MongoDB: `crab:crab`
- Redis: no auth

For full-stack Docker deployment, use the root `docker-compose.yml`. For the backend-focused development stack that builds app services, use the root `docker-compose.dev.yml`.
