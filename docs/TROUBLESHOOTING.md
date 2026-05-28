# Troubleshooting

<!-- TROUBLESHOOTING-EN:START -->
## English Troubleshooting

## pnpm Install Fails On Windows

Symptom:

```text
EACCES: permission denied, open node_modules/...
```

Fix:

1. Close editors, terminals, watchers, and test processes using the repo.
2. Retry `pnpm install --frozen-lockfile`.
3. If needed, remove local `node_modules` and reinstall.

The usual cause is a local file lock, not necessarily a lockfile issue.

## Flutter Missing Generated Files

Run the wrapper-backed mobile checks; they run code generation before analyze/test:

```bash
pnpm --filter @crab/mobile lint
pnpm --filter @crab/mobile test
```

Generated `*.g.dart` files are intentionally ignored; CI also runs codegen.

## Mobile Cannot Reach Backend

Android emulator uses `10.0.2.2` for the host machine:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

Physical devices must use your machine LAN IP.

## Health Endpoint Returns 404

Use `/health`, `/healthz`, `/readyz`, or `/metrics`, not `/api/v1/health`.

## Web-admin API Calls Fail Locally

Check that the gateway is running:

```bash
curl http://localhost:3000/health
```

Vite dev proxy routes `/api/*` to `http://localhost:3000`.

## Docker Compose Cannot Find Network

Start the main stack before monitoring:

```bash
docker compose up -d
docker compose -f docker-compose.monitoring.yml up -d
```

Monitoring expects the app network to exist.

## Native Bcrypt Binding Fails

This can happen when Node/native packages were installed under a different runtime.

Fix:

```bash
pnpm install --frozen-lockfile
pnpm --filter @crab/auth-service test
```

If local Windows remains blocked, confirm on CI or a clean Linux container.

## OpenAPI Or Docs Drift

Run:

```bash
pnpm run contract:check
```

Then inspect `docs/API.md`, `docs/openapi.yaml`, `packages/common-types`, and `packages/socket-events` together.
<!-- TROUBLESHOOTING-EN:END -->

<!-- TROUBLESHOOTING-VI:START -->
## Vietnamese Troubleshooting

## pnpm Install Lỗi Trên Windows

Triệu chứng:

```text
EACCES: permission denied, open node_modules/...
```

Cách xử lý:

1. Đóng editors, terminals, watchers và test process đang dùng repo.
2. Chạy lại `pnpm install --frozen-lockfile`.
3. Nếu cần, xóa local `node_modules` và cài lại.

Nguyên nhân thường là file lock local, không nhất thiết là lỗi lockfile.

## Flutter Thiếu File Generated

Chạy mobile checks qua wrapper; các lệnh này chạy code generation trước analyze/test:

```bash
pnpm --filter @crab/mobile lint
pnpm --filter @crab/mobile test
```

Các file `*.g.dart` được ignore có chủ đích; CI cũng chạy codegen.

## Mobile Không Gọi Được Backend

Android emulator dùng `10.0.2.2` để trỏ về host machine:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

Thiết bị thật phải dùng IP LAN của máy chạy backend.

## Health Endpoint Trả 404

Dùng `/health`, `/healthz`, `/readyz`, hoặc `/metrics`, không dùng `/api/v1/health`.

## Web-admin Gọi API Lỗi Local

Kiểm tra gateway đang chạy:

```bash
curl http://localhost:3000/health
```

Vite dev proxy chuyển `/api/*` tới `http://localhost:3000`.

## Docker Compose Thiếu Network

Khởi động main stack trước monitoring:

```bash
docker compose up -d
docker compose -f docker-compose.monitoring.yml up -d
```

Monitoring cần network của app tồn tại trước.

## Native Bcrypt Binding Lỗi

Lỗi này có thể xảy ra khi native package được cài dưới runtime khác.

Cách xử lý:

```bash
pnpm install --frozen-lockfile
pnpm --filter @crab/auth-service test
```

Nếu Windows local vẫn lỗi, xác nhận bằng CI hoặc Linux container sạch.

## OpenAPI Hoặc Docs Lệch Contract

Chạy:

```bash
pnpm run contract:check
```

Sau đó kiểm tra đồng thời `docs/API.md`, `docs/openapi.yaml`, `packages/common-types` và `packages/socket-events`.
<!-- TROUBLESHOOTING-VI:END -->
