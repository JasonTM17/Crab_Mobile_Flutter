# Environment Reference

<!-- ENVIRONMENT-EN:START -->
## English Environment Reference

This document lists public-safe environment variables used by local, production-like, and CI workflows. Values shown here are placeholders only.

## Rules

- Never commit `.env`, `.env.local`, `.env.*.local`, keystores, private keys, real tokens, or production credentials.
- Public examples must use fake values.
- `.env.example`, `.env.production.example`, `.env.test.example`, and service `.env.example` files are templates.

## Template Files

| File | Purpose |
| --- | --- |
| `.env.example` | Local development defaults and service URLs |
| `.env.production.example` | Production-like compose placeholders |
| `.env.test.example` | Dummy test values; copy locally if a runner requires `.env.test` |
| `apps/backend/gateway/.env.example` | Gateway-only local template |

## Core Infrastructure

| Variable | Example | Used by | Notes |
| --- | --- | --- | --- |
| `POSTGRES_HOST` | `postgres` | Compose/services | Container DNS name |
| `POSTGRES_PORT` | `5432` | Compose/services | PostgreSQL port |
| `POSTGRES_DB` | `crab` | Compose/services | Local database name |
| `POSTGRES_USER` | `crab` | Compose/services | Local user placeholder |
| `POSTGRES_PASSWORD` | `<postgres-password>` | Prod compose | Required in production-like config |
| `DATABASE_URL` | `postgresql://crab:<password>@postgres:5432/crab` | Backend services | Preferred URL form where supported |
| `MONGODB_URI` | `mongodb://mongo:<password>@mongodb:27017/crab` | Mongo-backed services | Use per-service DB names where needed |
| `REDIS_URL` | `redis://redis:6379` | Gateway/services | Sessions, cache, Socket.IO adapter, Bull queues |
| `MINIO_ROOT_USER` | `<minio-user>` | MinIO | Placeholder only |
| `MINIO_ROOT_PASSWORD` | `<minio-password>` | MinIO | Never commit real value |

## Security

| Variable | Example | Used by | Notes |
| --- | --- | --- | --- |
| `JWT_SECRET` | `<jwt-secret>` | Gateway/Auth/services | Long random value in production |
| `JWT_REFRESH_SECRET` | `<jwt-refresh-secret>` | Auth | Must differ from access secret |
| `CORS_ORIGIN` | `https://admin.example.com` | Gateway/services | Browser origins |
| `WS_CORS_ORIGIN` | `https://admin.example.com` | Gateway sockets | WebSocket CORS origin |
| `FCM_PROJECT_ID` | `<firebase-project-id>` | Notification service | Optional when FCM is disabled locally |
| `FCM_CLIENT_EMAIL` | `<firebase-client-email>` | Notification service | Do not commit real service-account data |
| `FCM_PRIVATE_KEY` | `<firebase-private-key>` | Notification service | Use a secret store in production |

## Downstream Service URLs

| Variable | Local value |
| --- | --- |
| `AUTH_SERVICE_URL` | `http://auth-service:3001` |
| `USER_SERVICE_URL` | `http://user-service:3002` |
| `RIDE_SERVICE_URL` | `http://ride-service:3003` |
| `FOOD_SERVICE_URL` | `http://food-service:3004` |
| `PAYMENT_SERVICE_URL` | `http://payment-service:3005` |
| `CHAT_SERVICE_URL` | `http://chat-service:3006` |
| `NOTIFICATION_SERVICE_URL` | `http://notification-service:3007` |
| `RATING_SERVICE_URL` | `http://rating-service:3008` |

## Mobile Build Defines

| Dart define | Debug default | Release requirement |
| --- | --- | --- |
| `API_BASE_URL` | `http://10.0.2.2:3000/api/v1` | HTTPS URL ending in `/api/v1` |
| `SOCKET_URL` | `http://10.0.2.2:3000` | HTTPS/WSS-capable gateway URL |

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

## Web Admin

| Variable | Default | Notes |
| --- | --- | --- |
| `VITE_API_URL` | `/api/v1` or dev proxy | Vite embeds this at build time |

## CI/CD Secrets

Set these in GitHub Actions secrets, never in repository files:

| Secret | Purpose |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub login and namespace |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

## Test Environment

`.env.test.example` contains dummy values for local tests. If a runner needs `.env.test`, copy it locally:

```bash
cp .env.test.example .env.test
```

Do not commit the copied `.env.test` file.
<!-- ENVIRONMENT-EN:END -->

<!-- ENVIRONMENT-VI:START -->
## Vietnamese Environment Reference

Tài liệu này liệt kê các biến môi trường an toàn cho public được dùng bởi local, production-like và CI workflows. Giá trị bên dưới chỉ là placeholder.

## Quy Tắc

- Không commit `.env`, `.env.local`, `.env.*.local`, keystores, private keys, token thật hoặc production credentials.
- Ví dụ public chỉ dùng giá trị giả.
- `.env.example`, `.env.production.example`, `.env.test.example` và service `.env.example` là template.

## File Template

| File | Mục đích |
| --- | --- |
| `.env.example` | Default local development và service URLs |
| `.env.production.example` | Placeholder cho production-like compose |
| `.env.test.example` | Giá trị giả cho test; copy local nếu runner cần `.env.test` |
| `apps/backend/gateway/.env.example` | Template local riêng cho Gateway |

## Hạ Tầng Chính

| Biến | Ví dụ | Nơi dùng | Ghi chú |
| --- | --- | --- | --- |
| `POSTGRES_HOST` | `postgres` | Compose/services | Container DNS name |
| `POSTGRES_PORT` | `5432` | Compose/services | PostgreSQL port |
| `POSTGRES_DB` | `crab` | Compose/services | Tên database local |
| `POSTGRES_USER` | `crab` | Compose/services | Placeholder user local |
| `POSTGRES_PASSWORD` | `<postgres-password>` | Prod compose | Bắt buộc trong production-like config |
| `DATABASE_URL` | `postgresql://crab:<password>@postgres:5432/crab` | Backend services | URL form ưu tiên khi service hỗ trợ |
| `MONGODB_URI` | `mongodb://mongo:<password>@mongodb:27017/crab` | Mongo-backed services | Dùng DB riêng cho từng service khi cần |
| `REDIS_URL` | `redis://redis:6379` | Gateway/services | Sessions, cache, Socket.IO adapter, Bull queues |
| `MINIO_ROOT_USER` | `<minio-user>` | MinIO | Chỉ là placeholder |
| `MINIO_ROOT_PASSWORD` | `<minio-password>` | MinIO | Không commit giá trị thật |

## Bảo Mật

| Biến | Ví dụ | Nơi dùng | Ghi chú |
| --- | --- | --- | --- |
| `JWT_SECRET` | `<jwt-secret>` | Gateway/Auth/services | Giá trị random dài trong production |
| `JWT_REFRESH_SECRET` | `<jwt-refresh-secret>` | Auth | Phải khác access secret |
| `CORS_ORIGIN` | `https://admin.example.com` | Gateway/services | Browser origins |
| `WS_CORS_ORIGIN` | `https://admin.example.com` | Gateway sockets | WebSocket CORS origin |
| `FCM_PROJECT_ID` | `<firebase-project-id>` | Notification service | Tùy chọn khi local tắt FCM |
| `FCM_CLIENT_EMAIL` | `<firebase-client-email>` | Notification service | Không commit service-account data thật |
| `FCM_PRIVATE_KEY` | `<firebase-private-key>` | Notification service | Dùng secret store trong production |

## URL Service Nội Bộ

| Biến | Giá trị local |
| --- | --- |
| `AUTH_SERVICE_URL` | `http://auth-service:3001` |
| `USER_SERVICE_URL` | `http://user-service:3002` |
| `RIDE_SERVICE_URL` | `http://ride-service:3003` |
| `FOOD_SERVICE_URL` | `http://food-service:3004` |
| `PAYMENT_SERVICE_URL` | `http://payment-service:3005` |
| `CHAT_SERVICE_URL` | `http://chat-service:3006` |
| `NOTIFICATION_SERVICE_URL` | `http://notification-service:3007` |
| `RATING_SERVICE_URL` | `http://rating-service:3008` |

## Biến Build Mobile

| Dart define | Debug default | Yêu cầu release |
| --- | --- | --- |
| `API_BASE_URL` | `http://10.0.2.2:3000/api/v1` | HTTPS URL kết thúc bằng `/api/v1` |
| `SOCKET_URL` | `http://10.0.2.2:3000` | Gateway URL hỗ trợ HTTPS/WSS |

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

## Admin Web

| Biến | Default | Ghi chú |
| --- | --- | --- |
| `VITE_API_URL` | `/api/v1` hoặc dev proxy | Vite embed giá trị này lúc build |

## Secrets Cho CI/CD

Thiết lập trong GitHub Actions secrets, không đặt trong repo:

| Secret | Mục đích |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub login và namespace |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

## Môi Trường Test

`.env.test.example` chứa giá trị giả cho test local. Nếu runner cần `.env.test`, copy local:

```bash
cp .env.test.example .env.test
```

Không commit file `.env.test` đã copy.
<!-- ENVIRONMENT-VI:END -->
