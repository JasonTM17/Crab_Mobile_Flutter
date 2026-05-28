# Deployment Guide

<!-- DEPLOYMENT-EN:START -->
## English Deployment Guide

This guide explains Crab Super App release artifacts, local production-like validation, Docker image publishing, mobile release requirements, Kubernetes notes, and the release checklist.

## Overview

This repository ships four kinds of release artifacts:

1. **GitHub releases** created by `.github/workflows/release.yml` on semantic tags such as `v1.2.3`.
2. **Container images** published by `.github/workflows/docker-publish.yml` to GHCR and Docker Hub.
3. **Deployable runtime configs** for Docker Compose and Kubernetes under the repo root and `infra/k8s/`.
4. **Release media** under `docs/screenshots/` and `docs/gifs/`, using verified screenshots and regenerated GIFs.

Image naming follows these conventions:

| Registry | Namespace |
| --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` |
| GitHub Packages / GHCR | `ghcr.io/jasontm17/crab-mobile-<service>` |

## Packages And Images

This repository does not publish public npm packages or a public Flutter package:

- the root `package.json` is private
- pnpm workspace packages such as `@crab/common-types`, `@crab/socket-events`, and `@crab/backend-shared` are internal packages
- `apps/mobile/pubspec.yaml` uses `publish_to: 'none'`

Runtime services are published as container images under `nguyenson1710/crab-mobile-<service>` and `ghcr.io/jasontm17/crab-mobile-<service>`.

Docker tags use these semantics:

| Tag | Meaning |
| --- | --- |
| `latest` | Latest successful build from the default branch |
| `sha-<short>` | Commit-addressable image for a specific source revision |
| `<semver>` | Release image produced from a version tag such as `v1.2.3` |

## Prerequisites

For local verification and deployment work:

- Docker 24+ with Compose v2
- Node.js 20.x
- pnpm 10.x
- Flutter 3.x stable for `apps/mobile`
- Git 2.40+

For CI/CD:

- GitHub Actions enabled
- Docker Hub repository access for `nguyenson1710/*`
- Required GitHub Actions secrets configured

## Required GitHub Actions Secrets

Set these at `Settings -> Secrets and variables -> Actions`.

| Secret | Required | Purpose |
| --- | ---: | --- |
| `GITHUB_TOKEN` | yes, built in | GitHub Actions token used to publish GHCR packages |
| `DOCKERHUB_USERNAME` | no for GHCR-only publish, yes for Docker Hub pushing | Docker Hub username; expected value: `nguyenson1710` |
| `DOCKERHUB_TOKEN` | no for GHCR-only publish, yes for Docker Hub pushing | Docker Hub access token used by the Docker publish workflow |

Do **not** commit credentials, keystores, or private env files to the repo.

## CI And Release Workflows

### CI

File: `.github/workflows/ci.yml`

Runs on pushes to `main`, `develop`, and pull requests.

Checks:

- per-package lint/build matrix for backend packages and web-admin
- contract drift guardrails via `pnpm -w run contract:check`
- backend package tests matrix
- Flutter analyze
- Flutter tests

### Docker Publish And GitHub Packages

File: `.github/workflows/docker-publish.yml`

Runs on:

- pushes to `main`
- tags matching `v*`
- manual workflow dispatch

The workflow:

- logs in to GitHub Container Registry
- logs in to Docker Hub when optional Docker Hub secrets exist
- builds all backend service images plus web-admin
- publishes images to `ghcr.io/jasontm17/crab-mobile-<service>` so GitHub Packages is populated
- publishes images to `nguyenson1710/crab-mobile-<service>` when Docker Hub secrets are configured
- emits tags including `latest`, short git SHA, and semver tags

### GitHub Release

File: `.github/workflows/release.yml`

Runs on semantic tags matching `vX.Y.Z`.

The workflow generates changelog content from git history and creates a GitHub Release entry. Docker images are published by the separate Docker publish workflow.

### Security Workflows

Files:

- `.github/workflows/codeql.yml`
- `.github/workflows/gitleaks.yml`
- `.github/workflows/trivy.yml`
- `.github/workflows/sbom.yml`

These provide SAST via CodeQL, secret scanning via Gitleaks, vulnerability scanning via Trivy, and SBOM generation via Syft.

## Local Verification Before Release

From repo root:

```bash
pnpm install --frozen-lockfile
pnpm run verify:portfolio
```

For full local Docker smoke evidence:

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d
pnpm run db:migrate
pnpm run db:seed
pnpm run test:e2e
```

On Windows development machines, file locks or native module resolution can affect local verification:

- `pnpm install` may hit `EACCES` inside `node_modules` if another process holds a file lock.
- `@crab/auth-service` tests can fail before assertions if the native bcrypt binding is unavailable in the local runtime.

Use a clean CI runner as the final authority after confirming the working tree and targeted local checks are otherwise sound.

## Docker Compose

Use `docker-compose.yml` for local multi-service development orchestration.

```bash
docker compose up -d
docker compose ps
docker compose logs -f gateway
```

Internal backend services are intended to sit behind the gateway. If a compose profile or local override exposes service ports directly, treat that as a development-only escape hatch and not a release-safe topology.

For production-like validation, use `docker-compose.prod.yml` with required environment variables supplied.

Required variables include at least:

- `POSTGRES_PASSWORD`
- `MONGO_PASSWORD`
- `RABBITMQ_PASSWORD`
- `MINIO_PASSWORD`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `CORS_ORIGIN`
- `WS_CORS_ORIGIN`

Example config validation:

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml config
```

## Mobile Release Notes

The Android app uses:

- package / application ID: `com.jasontm17.crab`
- release-safe cleartext handling via manifest placeholders
- secure URL enforcement in release mode for API and sockets

Release signing is configured through local `android/key.properties` and a keystore. The expected local file is not committed:

```text
apps/mobile/android/key.properties
```

Expected values inside `key.properties`:

- `storeFile`
- `storePassword`
- `keyAlias`
- `keyPassword`

If no release keystore is configured, the build logs a clear warning instead of silently using debug signing.

Release mobile builds must use secure endpoints:

- API: `https://.../api/v1`
- Socket: `wss://...`

Do not ship release builds that rely on emulator HTTP defaults.

## Kubernetes

Manifests live under `infra/k8s/`.

Current hardening in the deployable manifests includes:

- `runAsNonRoot: true`
- `seccompProfile.type: RuntimeDefault`
- `allowPrivilegeEscalation: false`
- image refs aligned to `nguyenson1710/crab-mobile-*`

When enabling a dedicated admin host, keep the `web-admin` Deployment/Service and ingress routes in sync so the static dashboard and same-origin `/api/` proxy both resolve correctly.

Before applying to a real cluster:

1. Replace placeholder secret management with your real secret source.
2. Verify ingress, DNS, and TLS.
3. Confirm image tags point to the intended SHA or release tag.
4. Validate probes and resource limits in the target environment.

## Release Checklist

Use this checklist before tagging a release:

- [ ] `pnpm -w run lint` is green.
- [ ] `pnpm -w run build` is green.
- [ ] `pnpm run package:check` is green.
- [ ] `pnpm -w run contract:check` is green.
- [ ] `pnpm -w run test` is green, or an environment-only local blocker is understood and CI is green.
- [ ] `pnpm --filter @crab/mobile lint` is green.
- [ ] `pnpm --filter @crab/mobile test` is green.
- [ ] `pnpm run mobile:screenshots` regenerated release media.
- [ ] `pnpm run verify:portfolio` is green.
- [ ] `docker compose --env-file .env.production.example -f docker-compose.prod.yml config` is green.
- [ ] Local Docker smoke is green after `pnpm run db:migrate && pnpm run db:seed && pnpm run test:e2e`.
- [ ] Required GitHub Actions secrets are present.
- [ ] Android release signing material is configured locally or in CI as needed.
- [ ] Release endpoints use HTTPS/WSS.
- [ ] Release media uses verified screenshots under `docs/screenshots/` and regenerated GIFs under `docs/gifs/`.
- [ ] Old proof/current/emulator screenshots are not presented as primary release media.
- [ ] `CHANGELOG.md` and release notes are acceptable.
- [ ] Internal backend services are not unintentionally exposed outside the gateway boundary.

## Creating A Release

```bash
git tag v1.2.3
git push origin v1.2.3
```

Expected result:

1. GitHub Release workflow creates a release entry.
2. Docker publish workflow builds and pushes images tagged for the release.
3. Security workflows continue to run on normal branch activity and pull requests.

## Troubleshooting

### `pnpm install` fails with `EACCES`

Likely a local Windows file lock under `node_modules`.

Safest next steps:

1. Close editors, terminals, and watchers touching the repo.
2. Rerun `pnpm install --frozen-lockfile`.
3. If it still fails, identify the locking process.

### Docker build validation cannot run locally

If Docker daemon is unavailable, you can still validate compose config parsing, workflow syntax, Dockerfile structure, and workspace build prerequisites.

Final image-build confidence should come from a machine with a working Docker daemon or CI.

### Auth-service tests fail before assertions

If the failure is a missing `bcrypt_lib.node`, treat it as local environment/runtime setup rather than an immediate code regression, then confirm behavior in CI.
<!-- DEPLOYMENT-EN:END -->

<!-- DEPLOYMENT-VI:START -->
## Vietnamese Deployment Guide

Tài liệu này mô tả release artifacts, kiểm tra local production-like, publish Docker image, yêu cầu release mobile, ghi chú Kubernetes và checklist release cho Crab Super App.

## Tổng Quan

Repo này phát hành bốn nhóm artifact chính:

1. **GitHub release** được tạo bởi `.github/workflows/release.yml` khi push semantic tag như `v1.2.3`.
2. **Container images** được publish lên GHCR và Docker Hub bởi `.github/workflows/docker-publish.yml`.
3. **Runtime configs** cho Docker Compose và Kubernetes ở repo root và `infra/k8s/`.
4. **Release media** trong `docs/screenshots/` và `docs/gifs/`, dùng screenshots đã xác minh và GIF được tạo lại.

Quy ước tên image:

| Registry | Namespace |
| --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` |
| GitHub Packages / GHCR | `ghcr.io/jasontm17/crab-mobile-<service>` |

## Packages Và Images

Repo này không publish npm package public hoặc Flutter package public:

- root `package.json` là private
- pnpm workspace packages như `@crab/common-types`, `@crab/socket-events` và `@crab/backend-shared` là internal packages
- `apps/mobile/pubspec.yaml` dùng `publish_to: 'none'`

Runtime services được publish thành container images dưới `nguyenson1710/crab-mobile-<service>` và `ghcr.io/jasontm17/crab-mobile-<service>`.

Ý nghĩa Docker tags:

| Tag | Ý nghĩa |
| --- | --- |
| `latest` | Build thành công mới nhất từ default branch |
| `sha-<short>` | Image gắn với một source revision cụ thể |
| `<semver>` | Release image tạo từ version tag như `v1.2.3` |

## Yêu Cầu

Cho kiểm tra local và deployment work:

- Docker 24+ với Compose v2
- Node.js 20.x
- pnpm 10.x
- Flutter 3.x stable cho `apps/mobile`
- Git 2.40+

Cho CI/CD:

- GitHub Actions đã bật
- Quyền truy cập Docker Hub repository cho `nguyenson1710/*`
- GitHub Actions secrets cần thiết đã cấu hình

## GitHub Actions Secrets Bắt Buộc

Thiết lập tại `Settings -> Secrets and variables -> Actions`.

| Secret | Bắt buộc | Mục đích |
| --- | ---: | --- |
| `GITHUB_TOKEN` | có, tích hợp sẵn | Token GitHub Actions dùng để publish GHCR packages |
| `DOCKERHUB_USERNAME` | không bắt buộc nếu chỉ publish GHCR, bắt buộc nếu push Docker Hub | Docker Hub username; expected value: `nguyenson1710` |
| `DOCKERHUB_TOKEN` | không bắt buộc nếu chỉ publish GHCR, bắt buộc nếu push Docker Hub | Docker Hub access token cho Docker publish workflow |

Không commit credentials, keystores hoặc private env files vào repo.

## CI Và Release Workflows

### CI

File: `.github/workflows/ci.yml`

Chạy khi push vào `main`, `develop` và khi có pull request.

Kiểm tra:

- per-package lint/build matrix cho backend packages và web-admin
- contract drift guardrails qua `pnpm -w run contract:check`
- backend package tests matrix
- Flutter analyze
- Flutter tests

### Docker Publish Và GitHub Packages

File: `.github/workflows/docker-publish.yml`

Chạy khi:

- push vào `main`
- tag khớp `v*`
- manual workflow dispatch

Workflow này:

- đăng nhập GitHub Container Registry
- đăng nhập Docker Hub khi có optional Docker Hub secrets
- build toàn bộ backend service images và web-admin
- publish images lên `ghcr.io/jasontm17/crab-mobile-<service>` để GitHub Packages được populate
- publish images lên `nguyenson1710/crab-mobile-<service>` khi Docker Hub secrets đã cấu hình
- tạo tags gồm `latest`, short git SHA và semver tags

### GitHub Release

File: `.github/workflows/release.yml`

Chạy trên semantic tags khớp `vX.Y.Z`.

Workflow tạo changelog từ git history và tạo GitHub Release entry. Docker images được publish bởi Docker publish workflow riêng.

### Security Workflows

Files:

- `.github/workflows/codeql.yml`
- `.github/workflows/gitleaks.yml`
- `.github/workflows/trivy.yml`
- `.github/workflows/sbom.yml`

Các workflow này cung cấp SAST bằng CodeQL, secret scanning bằng Gitleaks, vulnerability scanning bằng Trivy và SBOM bằng Syft.

## Kiểm Tra Local Trước Release

Từ repo root:

```bash
pnpm install --frozen-lockfile
pnpm run verify:portfolio
```

Để có bằng chứng full local Docker smoke:

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d
pnpm run db:migrate
pnpm run db:seed
pnpm run test:e2e
```

Trên máy Windows, file lock hoặc native module resolution có thể ảnh hưởng kiểm tra local:

- `pnpm install` có thể gặp `EACCES` trong `node_modules` nếu process khác giữ file lock.
- Test `@crab/auth-service` có thể fail trước assertion nếu native bcrypt binding không có trong local runtime.

Dùng clean CI runner làm nguồn xác nhận cuối cùng sau khi đã kiểm tra working tree và targeted local checks.

## Docker Compose

Dùng `docker-compose.yml` cho orchestration local nhiều service.

```bash
docker compose up -d
docker compose ps
docker compose logs -f gateway
```

Backend services nội bộ nên nằm sau gateway. Nếu compose profile hoặc local override expose service port trực tiếp, xem đó là escape hatch cho development, không phải topology release-safe.

Với kiểm tra production-like, dùng `docker-compose.prod.yml` cùng các biến môi trường bắt buộc.

Các biến tối thiểu gồm:

- `POSTGRES_PASSWORD`
- `MONGO_PASSWORD`
- `RABBITMQ_PASSWORD`
- `MINIO_PASSWORD`
- `JWT_SECRET`
- `JWT_REFRESH_SECRET`
- `CORS_ORIGIN`
- `WS_CORS_ORIGIN`

Ví dụ kiểm tra config:

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml config
```

## Ghi Chú Release Mobile

Android app dùng:

- package / application ID: `com.jasontm17.crab`
- release-safe cleartext handling qua manifest placeholders
- secure URL enforcement trong release mode cho API và sockets

Release signing cấu hình qua local `android/key.properties` và keystore. File local kỳ vọng không được commit:

```text
apps/mobile/android/key.properties
```

Giá trị cần có trong `key.properties`:

- `storeFile`
- `storePassword`
- `keyAlias`
- `keyPassword`

Nếu chưa cấu hình release keystore, build log cảnh báo rõ ràng thay vì âm thầm dùng debug signing.

Release mobile builds phải dùng secure endpoints:

- API: `https://.../api/v1`
- Socket: `wss://...`

Không ship release builds phụ thuộc emulator HTTP defaults.

## Kubernetes

Manifests nằm trong `infra/k8s/`.

Hardening hiện có trong manifests:

- `runAsNonRoot: true`
- `seccompProfile.type: RuntimeDefault`
- `allowPrivilegeEscalation: false`
- image refs đồng bộ với `nguyenson1710/crab-mobile-*`

Khi bật dedicated admin host, giữ `web-admin` Deployment/Service và ingress routes đồng bộ để static dashboard và same-origin `/api/` proxy đều resolve đúng.

Trước khi apply vào cluster thật:

1. Thay placeholder secret management bằng secret source thật.
2. Kiểm tra ingress, DNS và TLS.
3. Xác nhận image tags trỏ tới SHA hoặc release tag mong muốn.
4. Kiểm tra probes và resource limits trong target environment.

## Checklist Release

Dùng checklist này trước khi tag release:

- [ ] `pnpm -w run lint` xanh.
- [ ] `pnpm -w run build` xanh.
- [ ] `pnpm run package:check` xanh.
- [ ] `pnpm -w run contract:check` xanh.
- [ ] `pnpm -w run test` xanh, hoặc blocker local chỉ do môi trường đã được hiểu rõ và CI xanh.
- [ ] `pnpm --filter @crab/mobile lint` xanh.
- [ ] `pnpm --filter @crab/mobile test` xanh.
- [ ] `pnpm run mobile:screenshots` đã regenerate release media.
- [ ] `pnpm run verify:portfolio` xanh.
- [ ] `docker compose --env-file .env.production.example -f docker-compose.prod.yml config` xanh.
- [ ] Local Docker smoke xanh sau `pnpm run db:migrate && pnpm run db:seed && pnpm run test:e2e`.
- [ ] GitHub Actions secrets bắt buộc đã có.
- [ ] Android release signing material đã cấu hình local hoặc trong CI khi cần.
- [ ] Release endpoints dùng HTTPS/WSS.
- [ ] Release media dùng screenshots đã xác minh trong `docs/screenshots/` và GIF đã regenerate trong `docs/gifs/`.
- [ ] Ảnh proof/current/emulator cũ không được dùng làm primary release media.
- [ ] `CHANGELOG.md` và release notes chấp nhận được.
- [ ] Internal backend services không bị expose ngoài gateway boundary ngoài ý muốn.

## Tạo Release

```bash
git tag v1.2.3
git push origin v1.2.3
```

Kết quả kỳ vọng:

1. GitHub Release workflow tạo release entry.
2. Docker publish workflow build và push images gắn tag cho release.
3. Security workflows tiếp tục chạy trên branch activity và pull request thông thường.

## Xử Lý Lỗi

### `pnpm install` lỗi `EACCES`

Khả năng cao là file lock local trong `node_modules`.

Bước xử lý an toàn:

1. Đóng editors, terminals và watchers đang chạm repo.
2. Chạy lại `pnpm install --frozen-lockfile`.
3. Nếu vẫn lỗi, xác định process đang lock file.

### Không chạy được Docker build validation ở local

Nếu Docker daemon không khả dụng, bạn vẫn có thể kiểm tra compose config parsing, workflow syntax, Dockerfile structure và workspace build prerequisites.

Niềm tin cuối cùng cho image build nên đến từ máy có Docker daemon hoạt động hoặc CI.

### Auth-service tests fail trước assertion

Nếu lỗi là thiếu `bcrypt_lib.node`, xem đó là vấn đề setup local environment/runtime, không vội kết luận là code regression, rồi xác nhận lại trên CI.
<!-- DEPLOYMENT-VI:END -->
