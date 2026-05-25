# Troubleshooting / Xử Lý Lỗi Thường Gặp

## pnpm install fails on Windows / pnpm install lỗi trên Windows

Symptom:

```text
EACCES: permission denied, open node_modules/...
```

Fix:

1. Close editors, terminals, watchers, and test processes using the repo.
2. Retry `pnpm install --frozen-lockfile`.
3. If needed, remove local `node_modules` and reinstall.

Nguyên nhân thường là file lock local, không nhất thiết là lỗi lockfile.

## Flutter missing generated files / Flutter thiếu file generated

Run code generation before analyze/test:

```bash
cd apps/mobile
flutter pub get
flutter analyze
```

Generated `*.g.dart` files are intentionally ignored; CI also runs codegen.

Các file `*.g.dart` được ignore có chủ đích; CI cũng chạy codegen.

## Mobile cannot reach backend / Mobile không gọi được backend

Android emulator uses `10.0.2.2` for the host machine:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

Physical devices must use your machine LAN IP.

Thiết bị thật phải dùng IP LAN của máy chạy backend.

## Health endpoint returns 404 / Health endpoint trả 404

Use `/health`, `/healthz`, `/readyz`, or `/metrics`, not `/api/v1/health`.

Dùng `/health`, `/healthz`, `/readyz`, hoặc `/metrics`, không dùng `/api/v1/health`.

## Web-admin API calls fail locally / Web-admin gọi API lỗi local

Check that the gateway is running:

```bash
curl http://localhost:3000/health
```

Vite dev proxy routes `/api/*` to `http://localhost:3000`.

Vite dev proxy chuyển `/api/*` tới `http://localhost:3000`.

## Docker compose cannot find network / Docker compose thiếu network

Start the main stack before monitoring:

```bash
docker compose up -d
docker compose -f docker-compose.monitoring.yml up -d
```

Monitoring expects the app network to exist.

Monitoring cần network của app tồn tại trước.

## Native bcrypt binding fails / bcrypt native binding lỗi

This can happen when Node/native packages were installed under a different runtime.

Điều này có thể xảy ra khi native package được cài dưới runtime khác.

Fix:

```bash
pnpm install --frozen-lockfile
pnpm --filter @crab/auth-service test
```

If local Windows remains blocked, confirm on CI or a clean Linux container.

Nếu Windows local vẫn lỗi, xác nhận bằng CI hoặc Linux container sạch.

## OpenAPI/docs drift / Docs lệch contract

Run:

```bash
pnpm run contract:check
```

Then inspect `docs/API.md`, `docs/openapi.yaml`, `packages/common-types`, and `packages/socket-events` together.

Sau đó kiểm tra đồng thời `docs/API.md`, `docs/openapi.yaml`, `packages/common-types` và `packages/socket-events`.
