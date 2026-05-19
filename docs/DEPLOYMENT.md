# Deployment Guide

## Prerequisites

- Docker 24+ & Docker Compose v2
- Node.js 20 LTS (for local development)
- pnpm 8+
- Git

## Quick Start (Docker)

```bash
# Clone the repository
git clone https://github.com/JasonTM17/Crab_Mobile_Flutter.git
cd Crab_Mobile_Flutter

# Copy environment file
cp .env.example .env

# Start all services
docker compose up -d

# Verify services are running
docker compose ps
```

All services will be available at:
- Gateway: http://localhost:3000
- Web Admin: http://localhost:8080
- PostgreSQL: localhost:5432
- MongoDB: localhost:27017
- Redis: localhost:6379

## Local Development

```bash
# Install dependencies
pnpm install

# Start infrastructure only (databases + redis)
docker compose -f docker/docker-compose.dev.yml up -d

# Start all services in dev mode
pnpm dev

# Or start individual services
pnpm --filter @crab/gateway dev
pnpm --filter @crab/auth-service dev
pnpm --filter @crab/web-admin dev
```

## Environment Variables

### Required Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Environment mode | `development` |
| `JWT_SECRET` | Secret for JWT signing | (required) |
| `JWT_REFRESH_SECRET` | Secret for refresh tokens | (required) |
| `DATABASE_URL` | PostgreSQL connection string | `postgresql://crab:crab@localhost:5432/crab` |
| `MONGODB_URI` | MongoDB connection string | `mongodb://crab:crab@localhost:27017/crab` |
| `REDIS_URL` | Redis connection string | `redis://localhost:6379` |

### Optional Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `PORT` | Gateway port | `3000` |
| `RATE_LIMIT_TTL` | Rate limit window (seconds) | `60` |
| `RATE_LIMIT_MAX` | Max requests per window | `100` |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging key | - |
| `GOOGLE_MAPS_API_KEY` | Google Maps API key | - |
| `MOMO_PARTNER_CODE` | MoMo payment partner code | - |
| `ZALOPAY_APP_ID` | ZaloPay application ID | - |

## Docker Production Build

```bash
# Build all service images
docker compose build

# Build specific service
docker compose build gateway
docker compose build auth-service

# Run in production mode
docker compose -f docker-compose.yml up -d
```

### Image Registry (GHCR)

Images are automatically built and pushed via GitHub Actions on tag:

```bash
# Tag a release
git tag v1.0.0
git push origin v1.0.0

# Images published to:
# ghcr.io/jasontm17/crab-gateway:v1.0.0
# ghcr.io/jasontm17/crab-auth-service:v1.0.0
# ghcr.io/jasontm17/crab-user-service:v1.0.0
# ... (all 9 services + web-admin)
```

## Database Setup

### PostgreSQL

The database is auto-created by Docker. For manual setup:

```sql
CREATE DATABASE crab;
CREATE USER crab WITH PASSWORD 'crab';
GRANT ALL PRIVILEGES ON DATABASE crab TO crab;
```

Migrations run automatically on service startup via TypeORM synchronize (dev) or migrations (prod).

### MongoDB

```bash
# MongoDB is used by chat-service and notification-service
# Collections are auto-created on first write
# Indexes are created via Mongoose schema definitions
```

### Redis

Redis requires no schema setup. Used for:
- Session storage
- Rate limiting counters
- Socket.IO adapter (pub/sub)
- Cache layer

## Health Checks

Every service exposes a health endpoint:

```bash
# Check individual service
curl http://localhost:3000/health  # Gateway
curl http://localhost:3001/health  # Auth
curl http://localhost:3002/health  # User
# ... etc

# Check all services
for port in 3000 3001 3002 3003 3004 3005 3006 3007 3008; do
  echo "Port $port: $(curl -s http://localhost:$port/health | jq -r .status)"
done
```

Expected response:
```json
{ "status": "ok", "service": "gateway", "uptime": 3600, "timestamp": "2024-01-01T00:00:00Z" }
```

## Scaling

### Horizontal Scaling with Docker

```bash
# Scale specific services
docker compose up -d --scale ride-service=3 --scale food-service=2

# Gateway handles load balancing via Docker DNS
```

### Production Recommendations

| Service | Min Replicas | CPU | Memory |
|---------|-------------|-----|--------|
| Gateway | 2 | 0.5 | 512MB |
| Auth | 2 | 0.25 | 256MB |
| User | 1 | 0.25 | 256MB |
| Ride | 3 | 0.5 | 512MB |
| Food | 2 | 0.5 | 512MB |
| Payment | 2 | 0.25 | 256MB |
| Chat | 2 | 0.5 | 512MB |
| Notification | 2 | 0.25 | 256MB |
| Rating | 1 | 0.25 | 256MB |

## Troubleshooting

### Services won't start

```bash
# Check logs
docker compose logs -f gateway
docker compose logs -f auth-service

# Verify databases are ready
docker compose exec postgres pg_isready
docker compose exec mongodb mongosh --eval "db.runCommand({ping:1})"
docker compose exec redis redis-cli ping
```

### Port conflicts

```bash
# Check what's using a port
lsof -i :3000

# Override ports in .env
GATEWAY_PORT=4000
```

### Database connection issues

```bash
# Reset databases
docker compose down -v  # WARNING: destroys all data
docker compose up -d
```

### Memory issues

```bash
# Increase Docker memory limit (Docker Desktop)
# Settings > Resources > Memory > 4GB minimum

# Check container resource usage
docker stats
```

## CI/CD Pipeline

### GitHub Actions Workflows

1. **CI** (`.github/workflows/ci.yml`)
   - Triggers: push to main, pull requests
   - Steps: lint, test, build all services
   - Matrix build for all 9 backend services + web-admin

2. **Release** (`.github/workflows/release.yml`)
   - Triggers: tag push (v*)
   - Steps: build Docker images, push to GHCR, create GitHub release

### Manual Deployment

```bash
# Pull latest images
docker compose pull

# Rolling update (zero downtime)
docker compose up -d --no-deps --build gateway
docker compose up -d --no-deps --build auth-service
# ... repeat for each service
```
