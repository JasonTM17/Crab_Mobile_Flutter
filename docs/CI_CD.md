# CI/CD and Release / CI/CD và Phát Hành

This document explains the automated checks, release flow, Docker image publishing, security scanning, and dependency update policy.

Tài liệu này mô tả các kiểm tra tự động, release flow, publish Docker image, security scanning và chính sách cập nhật dependencies.

## Workflow Map / Bản Đồ Workflow

| Workflow | Trigger | Purpose |
| --- | --- | --- |
| `.github/workflows/ci.yml` | push/PR to `main`, `develop` | lint, build, contract check, tests, Flutter codegen/analyze/test |
| `.github/workflows/docker-publish.yml` | push to `main`, `v*`, manual | build Docker images; push only when Docker Hub secrets are configured |
| `.github/workflows/release.yml` | `v*.*.*` tags | create GitHub Release with changelog |
| `.github/workflows/codeql.yml` | push/PR/schedule | static analysis |
| `.github/workflows/gitleaks.yml` | push/PR | secret scanning |
| `.github/workflows/trivy.yml` | push/PR | filesystem and image vulnerability scanning |
| `.github/workflows/sbom.yml` | push/PR/manual | SPDX SBOM artifact |

## CI Gates / Cổng Kiểm Tra

The CI workflow runs these checks:

CI chạy các nhóm kiểm tra sau:

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

## Local Verification / Kiểm Tra Local

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

## Docker Publish / Publish Docker

Docker images are published to Docker Hub using this naming convention:

Docker images được publish lên Docker Hub theo quy ước:

```text
nguyenson1710/crab-mobile-<service>
```

Examples:

```text
nguyenson1710/crab-mobile-gateway
nguyenson1710/crab-mobile-auth-service
nguyenson1710/crab-mobile-web-admin
```

Tags include `latest`, short SHA, branch/tag refs, and semver tags when applicable. If Docker Hub secrets are missing, the workflow still builds every image but skips pushing so CI can remain green on public repos.

## Required Secrets / Secrets Bắt Buộc

| Secret | Purpose |
| --- | --- |
| `DOCKERHUB_USERNAME` | Docker Hub username/namespace |
| `DOCKERHUB_TOKEN` | Docker Hub access token |

Never print these values in logs or documentation.

Không in các giá trị này ra log hoặc tài liệu.

## Release Flow / Quy Trình Release

1. Ensure `main` is green.
2. Run local verification if possible.
3. Create a semantic tag.
4. Push the tag.

```bash
git tag v1.2.3
git push origin v1.2.3
```

The release workflow creates the GitHub Release entry. The Docker workflow publishes images for tags matching `v*`.

## Dependency Update Policy / Chính Sách Cập Nhật Dependency

Dependabot is intentionally disabled in this repository to keep a single-contributor public history and avoid noisy automated contributor attribution.

Dependabot được tắt có chủ đích để giữ lịch sử public một contributor và tránh attribution tự động gây nhiễu.

Manual dependency updates should follow this process:

1. Update one logical group at a time.
2. Avoid risky major bumps in the same commit as docs or feature work.
3. Regenerate lockfiles with the package manager for that ecosystem.
4. Run targeted builds/tests.
5. Document skipped major upgrades as known follow-up work.

## Security Scans / Quét Bảo Mật

- CodeQL: static analysis for JavaScript/TypeScript.
- Gitleaks: secret scanning.
- Trivy: filesystem/image vulnerability scanning.
- SBOM: Syft-generated SPDX artifact.

Treat scanner output as release evidence. Do not suppress findings without a documented reason.

Xem kết quả scanner là bằng chứng release. Không suppress findings nếu không có lý do được ghi rõ.
