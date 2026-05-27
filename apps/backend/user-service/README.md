# User Service

Manages user profile data for Crab customers, drivers, and admin views. It owns profile CRUD, saved addresses, preferences, avatar metadata, account deactivation, and driver profile records used by ride and admin workflows.

## Purpose

- Serve authenticated profile and preference reads/writes for the mobile app.
- Store saved addresses used by ride booking and delivery checkout.
- Provide admin-safe user lookups for operations workflows through the gateway.
- Keep driver profile metadata close to user account data while ride state remains in ride-service.

## Port: 3002

## Features

- User profile CRUD
- Avatar upload metadata and object-storage integration
- Address management for saved homes, offices, and delivery locations
- User preferences for notifications and account settings
- Account deactivation flow
- Driver profile management and verification metadata

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/me` | Get current user profile |
| PUT | `/users/me` | Update profile |
| PUT | `/users/me/avatar` | Upload avatar |
| GET | `/users/me/addresses` | Saved addresses |
| POST | `/users/me/addresses` | Add address |
| DELETE | `/users/me/addresses/:id` | Remove address |
| GET | `/users/me/preferences` | Get preferences |
| PUT | `/users/me/preferences` | Update preferences |
| POST | `/users/me/deactivate` | Deactivate account |
| GET | `/users/:id` | Get user by ID (admin) |

## Environment Variables

| Variable | Required | Default | Description |
| --- | --- | --- | --- |
| `PORT` | No | `3002` | HTTP port exposed by the service |
| `POSTGRES_HOST` | Yes | `localhost` | PostgreSQL host for user profile data |
| `POSTGRES_PORT` | No | `5432` | PostgreSQL port |
| `POSTGRES_USER` | Yes | `crab` | PostgreSQL username |
| `POSTGRES_PASSWORD` | Yes | - | PostgreSQL password |
| `POSTGRES_DB` | Yes | `crab` | PostgreSQL database name |
| `REDIS_HOST` | No | `localhost` | Redis host for cache/session-adjacent reads |
| `REDIS_PORT` | No | `6379` | Redis port |
| `MINIO_ENDPOINT` | No | `localhost` | Object storage endpoint for avatar files |
| `MINIO_ACCESS_KEY` | Yes | - | Object storage access key |
| `MINIO_SECRET_KEY` | Yes | - | Object storage secret key |
| `MINIO_BUCKET` | No | `crab-uploads` | Bucket for uploaded user media |

## Run Locally

```bash
pnpm --filter @crab/user-service dev
```

## Test

```bash
pnpm --filter @crab/user-service lint
pnpm --filter @crab/user-service test
```

## Docker

```bash
docker build -f apps/backend/user-service/Dockerfile -t nguyenson1710/crab-mobile-user-service .
docker run -p 3002:3002 --env-file .env nguyenson1710/crab-mobile-user-service
```

## Runbook

- Health check: `GET /health` inside the container or Kubernetes pod.
- Reset local profile data by recreating the local Postgres volume, not by deleting application files.
- Rotate object-storage credentials by updating the secret and restarting only user-service pods.
- For avatar upload issues, verify MinIO connectivity, bucket permissions, and uploaded object keys first.
