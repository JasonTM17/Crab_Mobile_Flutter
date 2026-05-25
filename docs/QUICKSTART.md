# Quickstart / Chạy Nhanh

This guide gets Crab Super App running locally with the fewest moving parts.

Hướng dẫn này giúp chạy Crab Super App trên máy local với số bước ít nhất.

## Prerequisites / Yêu Cầu

| Tool | Version | Notes |
| --- | --- | --- |
| Node.js | 20.x LTS | Required for pnpm workspaces and NestJS services |
| pnpm | 10.x | Managed through Corepack |
| Docker | 24+ with Compose v2 | Required for databases and containers |
| Flutter | 3.x stable | Required only for `apps/mobile` |
| Git | 2.40+ | Required for normal development workflow |

## 1. Install Dependencies / Cài Dependencies

```bash
corepack enable
pnpm install --frozen-lockfile
```

If local `node_modules` is locked on Windows, close editors/terminals using the folder and retry. CI is the final authority for dependency resolution.

Nếu Windows báo lock trong `node_modules`, đóng editor/terminal đang dùng thư mục đó rồi thử lại. CI là nguồn xác nhận cuối cùng cho dependency resolution.

## 2. Start the Local Stack / Khởi Động Local Stack

The root compose file boots infrastructure plus backend services and web-admin.

File compose ở root khởi động hạ tầng, backend services và web-admin.

```bash
docker compose up -d
docker compose ps
```

Public entrypoints:

| Surface | URL |
| --- | --- |
| API Gateway | `http://localhost:3000/api/v1` |
| Gateway health | `http://localhost:3000/health` |
| Web Admin | `http://localhost:5173` |
| MinIO Console | `http://localhost:9001` |

Internal service ports are primarily container ports behind the gateway. Do not rely on direct host exposure for production.

Port service nội bộ chủ yếu nằm sau gateway. Không xem host-exposed service port là topology production.

## 3. Run Services in Dev Mode / Chạy Dev Mode

```bash
pnpm dev
```

To run one service:

```bash
pnpm --filter @crab/gateway dev
pnpm --filter @crab/auth-service dev
pnpm --filter @crab/web-admin dev
```

## 4. Run the Flutter App / Chạy Flutter App

Android emulator default:

```bash
cd apps/mobile
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter analyze
flutter test
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

For a physical device, replace the host with your machine LAN IP.

Với thiết bị thật, thay host bằng IP LAN của máy chạy backend.

## 5. Health Checks / Kiểm Tra Health

```bash
curl http://localhost:3000/health
curl http://localhost:3000/healthz
curl http://localhost:3000/readyz
curl http://localhost:3000/metrics
```

Service health endpoints are outside `/api/v1` because the code excludes `health`, `healthz`, `readyz`, and `metrics` from the global API prefix.

Các endpoint health nằm ngoài `/api/v1` vì code exclude `health`, `healthz`, `readyz`, `metrics` khỏi global API prefix.

## 6. Useful Verification / Lệnh Kiểm Tra Hữu Ích

```bash
pnpm run contract:check
pnpm --filter @crab/common-types build
pnpm --filter @crab/socket-events build
pnpm --filter @crab/web-admin build
pnpm --filter @crab/ride-service test -- drivers.service.spec.ts
```

Full verification:

```bash
pnpm run verify
```

## 7. Stop the Stack / Dừng Stack

```bash
docker compose down
```

Remove local volumes only when you intentionally want to delete local data:

```bash
docker compose down -v
```

Chỉ dùng `-v` khi muốn xóa dữ liệu local.

## Related / Liên Quan

- [Environment](./ENVIRONMENT.md)
- [Docker Deployment](./DEPLOYMENT_DOCKER.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
