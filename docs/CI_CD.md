# CI/CD and Release

<!-- CICD-EN:START -->
## English CI/CD and Release

This document explains automated checks, release flow, Docker image publishing, security scanning, and dependency update policy for the portfolio-ready repository.

## Workflow Map

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `.github/workflows/ci.yml` | push/PR to `main`, `develop` | lint, build, contract check, tests, Flutter codegen/analyze/test |
| `.github/workflows/docker-publish.yml` | push to `main`, `v*`, manual | build Docker images; publish GHCR packages and optionally push Docker Hub when secrets are configured |
| `.github/workflows/release.yml` | `v*.*.*` tags | create GitHub Release with changelog |
| `.github/workflows/codeql.yml` | push/PR/schedule | static analysis |
| `.github/workflows/gitleaks.yml` | push/PR | secret scanning |
| `.github/workflows/trivy.yml` | push/PR | filesystem and image vulnerability scanning |
| `.github/workflows/sbom.yml` | push/PR/manual | SPDX SBOM artifact |

## CI Gates

The CI workflow runs these checks:

1. Install with `pnpm install --frozen-lockfile`.
2. Build shared packages first: `@crab/common-types`, `@crab/socket-events`, `@crab/backend-shared`.
3. Matrix lint/build for backend packages and web-admin.
4. Contract guardrails with `pnpm -w run contract:check`.
5. Backend package test matrix.
6. Flutter `pub get`, code generation, analyze, and tests.

Flutter codegen is intentional. Generated `*.g.dart` files stay ignored, so CI must run:

```bash
pnpm --filter @crab/mobile run codegen
```

## Local Verification

```bash
pnpm install --frozen-lockfile
pnpm run package:check
pnpm run contract:check
pnpm --filter @crab/web-admin build
pnpm run mobile:analyze
pnpm run mobile:test
pnpm run docker:config
pnpm run verify:portfolio
```

## Docker Publish And GitHub Packages

The Docker workflow publishes runtime images to GitHub Packages through GHCR so the repository sidebar can show real packages. It also pushes to Docker Hub when Docker Hub secrets are configured.

Canonical Docker Hub naming:

```text
nguyenson1710/crab-mobile-<service>
```

GitHub Packages and GHCR naming:

```text
ghcr.io/jasontm17/crab-mobile-<service>
```

Examples:

```text
nguyenson1710/crab-mobile-gateway
nguyenson1710/crab-mobile-auth-service
nguyenson1710/crab-mobile-web-admin
ghcr.io/jasontm17/crab-mobile-gateway
ghcr.io/jasontm17/crab-mobile-auth-service
ghcr.io/jasontm17/crab-mobile-web-admin
```

Tags include `latest`, short SHA, and semver tags when applicable. If Docker Hub secrets are missing, the workflow still publishes GHCR images with `GITHUB_TOKEN` and skips only Docker Hub tags.

## Required Secrets

| Secret | Purpose |
| --- | --- |
| `GITHUB_TOKEN` | Built-in token used for GHCR publishing through GitHub Actions |
| `DOCKERHUB_USERNAME` | Optional Docker Hub username/namespace |
| `DOCKERHUB_TOKEN` | Optional Docker Hub access token |

Never print these values in logs or documentation.

## Release Flow

1. Ensure `main` is green.
2. Run local verification if possible.
3. Create a semantic tag.
4. Push the tag.

```bash
git tag v1.2.3
git push origin v1.2.3
```

The release workflow creates the GitHub Release entry. The Docker workflow publishes images for tags matching `v*`.

## Dependency Update Policy

Dependabot is intentionally disabled in this repository to keep a single-contributor public history and avoid noisy automated contributor attribution.

Manual dependency updates should follow this process:

1. Update one logical group at a time.
2. Avoid risky major bumps in the same commit as docs or feature work.
3. Regenerate lockfiles with the package manager for that ecosystem.
4. Run targeted builds/tests.
5. Document skipped major upgrades as known follow-up work.

## Security Scans

- CodeQL: static analysis for JavaScript/TypeScript.
- Gitleaks: secret scanning.
- Trivy: filesystem/image vulnerability scanning.
- SBOM: Syft-generated SPDX artifact.

Treat scanner output as release evidence. Do not suppress findings without a documented reason.
<!-- CICD-EN:END -->

<!-- CICD-VI:START -->
## Vietnamese CI/CD and Release

Tài liệu này mô tả kiểm tra tự động, quy trình release, publish Docker image, security scanning và chính sách cập nhật dependency cho repo portfolio-ready.

## Bản Đồ Workflow

| Workflow | Trigger | Mục đích |
| --- | --- | --- |
| `.github/workflows/ci.yml` | push/PR vào `main`, `develop` | lint, build, contract check, tests, Flutter codegen/analyze/test |
| `.github/workflows/docker-publish.yml` | push vào `main`, `v*`, manual | build Docker images; publish GHCR packages và tùy chọn push Docker Hub khi có secrets |
| `.github/workflows/release.yml` | tag `v*.*.*` | tạo GitHub Release với changelog |
| `.github/workflows/codeql.yml` | push/PR/schedule | static analysis |
| `.github/workflows/gitleaks.yml` | push/PR | secret scanning |
| `.github/workflows/trivy.yml` | push/PR | quét vulnerability cho filesystem và image |
| `.github/workflows/sbom.yml` | push/PR/manual | tạo artifact SPDX SBOM |

## Cổng Kiểm Tra CI

CI chạy các nhóm kiểm tra sau:

1. Cài dependency bằng `pnpm install --frozen-lockfile`.
2. Build shared packages trước: `@crab/common-types`, `@crab/socket-events`, `@crab/backend-shared`.
3. Matrix lint/build cho backend packages và web-admin.
4. Contract guardrails với `pnpm -w run contract:check`.
5. Backend package test matrix.
6. Flutter `pub get`, code generation, analyze và tests.

Flutter codegen là chủ đích. Generated `*.g.dart` được ignore, nên CI phải chạy:

```bash
pnpm --filter @crab/mobile run codegen
```

## Kiểm Tra Local

```bash
pnpm install --frozen-lockfile
pnpm run package:check
pnpm run contract:check
pnpm --filter @crab/web-admin build
pnpm run mobile:analyze
pnpm run mobile:test
pnpm run docker:config
pnpm run verify:portfolio
```

## Docker Publish Và GitHub Packages

Docker workflow publish runtime images lên GitHub Packages qua GHCR để sidebar repo hiển thị package thật. Workflow cũng push Docker Hub khi Docker Hub secrets đã được cấu hình.

Tên Docker Hub chính thức:

```text
nguyenson1710/crab-mobile-<service>
```

Tên GitHub Packages và GHCR:

```text
ghcr.io/jasontm17/crab-mobile-<service>
```

Ví dụ:

```text
nguyenson1710/crab-mobile-gateway
nguyenson1710/crab-mobile-auth-service
nguyenson1710/crab-mobile-web-admin
ghcr.io/jasontm17/crab-mobile-gateway
ghcr.io/jasontm17/crab-mobile-auth-service
ghcr.io/jasontm17/crab-mobile-web-admin
```

Tag gồm `latest`, short SHA và semver tag khi phù hợp. Nếu thiếu Docker Hub secrets, workflow vẫn publish GHCR image bằng `GITHUB_TOKEN` và chỉ bỏ qua Docker Hub tags.

## Secrets Bắt Buộc

| Secret | Mục đích |
| --- | --- |
| `GITHUB_TOKEN` | Token tích hợp sẵn dùng để publish GHCR qua GitHub Actions |
| `DOCKERHUB_USERNAME` | Docker Hub username/namespace, tùy chọn |
| `DOCKERHUB_TOKEN` | Docker Hub access token, tùy chọn |

Không in các giá trị này ra log hoặc tài liệu.

## Quy Trình Release

1. Đảm bảo `main` đang xanh.
2. Chạy local verification nếu có thể.
3. Tạo semantic tag.
4. Push tag.

```bash
git tag v1.2.3
git push origin v1.2.3
```

Release workflow tạo GitHub Release. Docker workflow publish images cho các tag khớp `v*`.

## Chính Sách Cập Nhật Dependency

Dependabot được tắt có chủ đích để giữ lịch sử public một contributor và tránh attribution tự động gây nhiễu.

Quy trình cập nhật dependency thủ công:

1. Cập nhật một nhóm logic mỗi lần.
2. Tránh major bump rủi ro trong cùng commit với docs hoặc feature work.
3. Regenerate lockfile bằng package manager của ecosystem tương ứng.
4. Chạy build/test có mục tiêu.
5. Ghi lại major upgrade bị hoãn như follow-up work.

## Quét Bảo Mật

- CodeQL: static analysis cho JavaScript/TypeScript.
- Gitleaks: secret scanning.
- Trivy: quét vulnerability cho filesystem/image.
- SBOM: artifact SPDX tạo bằng Syft.

Xem kết quả scanner là bằng chứng release. Không suppress finding nếu không có lý do được ghi rõ.
<!-- CICD-VI:END -->
