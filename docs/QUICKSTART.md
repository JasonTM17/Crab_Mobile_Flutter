# Quickstart

<!-- QUICKSTART-EN:START -->
## English Quickstart

This guide gets Crab Super App running locally with the fewest moving parts. Use the production-like path when preparing a portfolio demo or validating a release candidate.

## Prerequisites

| Tool | Version | Notes |
| --- | --- | --- |
| Node.js | 20.x LTS | Required for pnpm workspaces and NestJS services |
| pnpm | 10.x | Managed through Corepack |
| Docker | 24+ with Compose v2 | Required for databases and containers |
| Flutter | 3.x stable | Required only for `apps/mobile` |
| Git | 2.40+ | Required for normal development workflow |

## 1. Install Dependencies

```bash
corepack enable
pnpm install --frozen-lockfile
```

If local `node_modules` is locked on Windows, close editors or terminals using the folder and retry. CI is the final authority for dependency resolution.

## 2. Start the Local Stack

The root compose file boots infrastructure, backend services, and web-admin.

```bash
docker compose up -d
docker compose ps
```

For the production-like portfolio demo, use the production compose file and seed demo data:

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d
pnpm run db:migrate
pnpm run db:seed
pnpm run test:e2e
```

Public entrypoints:

| Surface | URL |
| --- | --- |
| API Gateway | `http://localhost:3000/api/v1` |
| Gateway health | `http://localhost:3000/health` |
| Web Admin | `http://localhost:5173` |
| MinIO Console | `http://localhost:9001` |

Internal service ports are primarily container ports behind the gateway. Do not rely on direct host exposure as a production topology.

## 3. Run Services in Dev Mode

```bash
pnpm dev
```

To run one service:

```bash
pnpm --filter @crab/gateway dev
pnpm --filter @crab/auth-service dev
pnpm --filter @crab/web-admin dev
```

## 4. Run the Flutter App

Android emulator default:

```bash
node scripts/run-mobile-tool.js flutter pub get
pnpm --filter @crab/mobile lint
pnpm --filter @crab/mobile test
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

For a physical device, replace the host with your machine LAN IP.

## 5. Health Checks

```bash
curl http://localhost:3000/health
curl http://localhost:3000/healthz
curl http://localhost:3000/readyz
curl http://localhost:3000/metrics
```

Service health endpoints are outside `/api/v1` because the code excludes `health`, `healthz`, `readyz`, and `metrics` from the global API prefix.

## 6. Useful Verification

```bash
pnpm run package:check
pnpm run contract:check
pnpm --filter @crab/common-types build
pnpm --filter @crab/socket-events build
pnpm --filter @crab/web-admin build
pnpm --filter @crab/ride-service test -- drivers.service.spec.ts
pnpm run mobile:screenshots
pnpm run verify:portfolio
```

## 7. Stop the Stack

```bash
docker compose down
```

Remove local volumes only when you intentionally want to delete local data:

```bash
docker compose down -v
```

## Related

- [Environment](./ENVIRONMENT.md)
- [Docker Deployment](./DEPLOYMENT_DOCKER.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
<!-- QUICKSTART-EN:END -->

<!-- QUICKSTART-VI:START -->
## Vietnamese Quickstart

Hướng dẫn này giúp chạy Crab Super App trên máy local với số bước ít nhất. Dùng luồng production-like khi chuẩn bị demo portfolio hoặc kiểm tra release candidate.

## Yêu Cầu

| Công cụ | Phiên bản | Ghi chú |
| --- | --- | --- |
| Node.js | 20.x LTS | Cần cho pnpm workspaces và NestJS services |
| pnpm | 10.x | Quản lý qua Corepack |
| Docker | 24+ với Compose v2 | Cần cho database và container |
| Flutter | 3.x stable | Chỉ cần khi chạy `apps/mobile` |
| Git | 2.40+ | Cần cho quy trình phát triển thông thường |

## 1. Cài Dependencies

```bash
corepack enable
pnpm install --frozen-lockfile
```

Nếu Windows báo lock trong `node_modules`, đóng editor hoặc terminal đang dùng thư mục đó rồi thử lại. CI là nguồn xác nhận cuối cùng cho dependency resolution.

## 2. Khởi Động Local Stack

File compose ở root khởi động hạ tầng, backend services và web-admin.

```bash
docker compose up -d
docker compose ps
```

Với demo portfolio production-like, dùng production compose file và seed dữ liệu demo:

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d
pnpm run db:migrate
pnpm run db:seed
pnpm run test:e2e
```

Entrypoint public:

| Bề mặt | URL |
| --- | --- |
| API Gateway | `http://localhost:3000/api/v1` |
| Gateway health | `http://localhost:3000/health` |
| Web Admin | `http://localhost:5173` |
| MinIO Console | `http://localhost:9001` |

Port service nội bộ chủ yếu nằm sau gateway. Không xem host-exposed service port là topology production.

## 3. Chạy Services Ở Dev Mode

```bash
pnpm dev
```

Chạy một service riêng:

```bash
pnpm --filter @crab/gateway dev
pnpm --filter @crab/auth-service dev
pnpm --filter @crab/web-admin dev
```

## 4. Chạy Flutter App

Mặc định cho Android emulator:

```bash
node scripts/run-mobile-tool.js flutter pub get
pnpm --filter @crab/mobile lint
pnpm --filter @crab/mobile test
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

Với thiết bị thật, thay host bằng IP LAN của máy chạy backend.

## 5. Kiểm Tra Health

```bash
curl http://localhost:3000/health
curl http://localhost:3000/healthz
curl http://localhost:3000/readyz
curl http://localhost:3000/metrics
```

Các endpoint health nằm ngoài `/api/v1` vì code loại `health`, `healthz`, `readyz`, và `metrics` khỏi global API prefix.

## 6. Lệnh Kiểm Tra Hữu Ích

```bash
pnpm run package:check
pnpm run contract:check
pnpm --filter @crab/common-types build
pnpm --filter @crab/socket-events build
pnpm --filter @crab/web-admin build
pnpm --filter @crab/ride-service test -- drivers.service.spec.ts
pnpm run mobile:screenshots
pnpm run verify:portfolio
```

## 7. Dừng Stack

```bash
docker compose down
```

Chỉ xóa local volumes khi bạn thật sự muốn xóa dữ liệu local:

```bash
docker compose down -v
```

## Liên Quan

- [Environment](./ENVIRONMENT.md)
- [Docker Deployment](./DEPLOYMENT_DOCKER.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
<!-- QUICKSTART-VI:END -->
