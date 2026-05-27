# Deployment Guide

## Overview

This repository ships four kinds of release artifacts:

1. **GitHub release** created by `.github/workflows/release.yml` on semantic tags like `v1.2.3`
2. **Container images** published by `.github/workflows/docker-publish.yml` to GHCR and Docker Hub
3. **Deployable runtime configs** for Docker Compose and Kubernetes under repo root / `infra/k8s/`
4. **Release media** under `docs/screenshots/` and `docs/gifs/`, using verified screenshots and regenerated GIFs

Repo này phát hành bốn nhóm artifact chính:

1. **GitHub release** được tạo bởi `.github/workflows/release.yml` khi push semantic tag như `v1.2.3`
2. **Container images** được publish lên GHCR và Docker Hub bởi `.github/workflows/docker-publish.yml`
3. **Runtime configs** cho Docker Compose và Kubernetes ở repo root / `infra/k8s/`
4. **Release media** trong `docs/screenshots/` và `docs/gifs/`, dùng screenshots đã xác minh và GIF được tạo lại

The public Docker Hub namespace for this project is:

- `nguyenson1710`

GitHub Packages / GHCR uses the repository owner namespace:

- `ghcr.io/jasontm17`

Image naming follows these conventions:

- Docker Hub: `nguyenson1710/crab-mobile-<service>`
- GHCR: `ghcr.io/jasontm17/crab-mobile-<service>`

## Packages and Images

This repository does not publish public npm packages or a public Flutter package:

- the root `package.json` is private
- pnpm workspace packages such as `@crab/common-types`, `@crab/socket-events`, and `@crab/backend-shared` are internal packages
- `apps/mobile/pubspec.yaml` uses `publish_to: 'none'`

Runtime services are published as container images under
`nguyenson1710/crab-mobile-<service>` and
`ghcr.io/jasontm17/crab-mobile-<service>`.

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

Set these at:

`Settings -> Secrets and variables -> Actions`

| Secret | Required | Purpose |
|---|---:|---|
| `GITHUB_TOKEN` | yes, built in | GitHub Actions token used to publish GHCR packages |
| `DOCKERHUB_USERNAME` | no for GHCR-only publish, yes for Docker Hub pushing | Docker Hub username; expected value: `nguyenson1710` |
| `DOCKERHUB_TOKEN` | no for GHCR-only publish, yes for Docker Hub pushing | Docker Hub access token used by docker publish workflow |

Do **not** commit credentials, keystores, or private env files to the repo.

## CI and Release Workflows

### 1. CI

File: `.github/workflows/ci.yml`

Runs on pushes to `main`, `develop`, and pull requests.

What it checks:

- per-package lint/build matrix for backend packages and web-admin
- contract drift guardrails via `pnpm -w run contract:check`
- backend package tests matrix
- Flutter analyze
- Flutter tests

### 2. Docker Publish and GitHub Packages

File: `.github/workflows/docker-publish.yml`

Runs on:

- pushes to `main`
- tags matching `v*`
- manual workflow dispatch

What it does:

- logs in to GitHub Container Registry
- logs in to Docker Hub when optional Docker Hub secrets exist
- builds all backend service images plus web-admin
- publishes images to `ghcr.io/jasontm17/crab-mobile-<service>` so GitHub Packages is populated
- publishes images to `nguyenson1710/crab-mobile-<service>` when Docker Hub secrets are configured
- emits tags including:
  - `latest` on default branch
  - short git SHA
  - semver tag when release tag is pushed

### 3. GitHub Release

File: `.github/workflows/release.yml`

Runs on semantic tags:

- `vX.Y.Z`

What it does:

- generates changelog content from git history
- creates a GitHub release entry

Note: this workflow creates the GitHub release entry; Docker images are published by the separate docker publish workflow.

### 4. Security Workflows

Files:

- `.github/workflows/codeql.yml`
- `.github/workflows/gitleaks.yml`
- `.github/workflows/trivy.yml`
- `.github/workflows/sbom.yml`

These provide:

- SAST via CodeQL
- secret scanning via Gitleaks
- vulnerability scanning via Trivy
- SBOM generation via Syft

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

### Local Verification Notes

On Windows development machines, file locks or native module resolution can affect local verification:

- `pnpm install` may hit `EACCES` inside `node_modules` if another process holds a file lock.
- `@crab/auth-service` tests can fail before assertions if the native bcrypt binding is unavailable in the local runtime.

Use a clean CI runner as the final authority after confirming the working tree and targeted local checks are otherwise sound.

## Docker Compose

### Development

Use `docker-compose.yml` for local multi-service orchestration.

```bash
docker compose up -d
docker compose ps
docker compose logs -f gateway
```

Note: internal backend services are intended to sit behind the gateway. If a compose profile or local override exposes service ports directly, treat that as a development-only escape hatch and not a release-safe topology.

### Production-like Validation

Use `docker-compose.prod.yml` with required environment variables supplied.

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

### Android

The Android app now uses:

- package / application ID: `com.jasontm17.crab`
- release-safe cleartext handling via manifest placeholders
- secure URL enforcement in release mode for API and sockets

Release signing is configured through local `android/key.properties` and a keystore.

Expected local file (not committed):

- `apps/mobile/android/key.properties`

Expected values inside `key.properties`:

- `storeFile`
- `storePassword`
- `keyAlias`
- `keyPassword`

If no release keystore is configured, the build logs a clear warning instead of silently using debug signing.

### Mobile Runtime Requirements

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

1. replace placeholder secrets management with your real secret source
2. verify ingress / DNS / TLS
3. confirm image tags point to the intended SHA or release tag
4. validate probes and resource limits in the target environment

## Release Checklist

Use this checklist before tagging a release:

- [ ] `pnpm -w run lint` is green
- [ ] `pnpm -w run build` is green
- [ ] `pnpm run package:check` is green
- [ ] `pnpm -w run contract:check` is green
- [ ] `pnpm -w run test` is green, or environment-only local blocker is understood and CI is green
- [ ] `pnpm --filter @crab/mobile lint` is green
- [ ] `pnpm --filter @crab/mobile test` is green
- [ ] `pnpm run mobile:screenshots` regenerated release media
- [ ] `pnpm run verify:portfolio` is green
- [ ] `docker compose --env-file .env.production.example -f docker-compose.prod.yml config` is green
- [ ] local Docker smoke is green after `pnpm run db:migrate && pnpm run db:seed && pnpm run test:e2e`
- [ ] required GitHub Actions secrets are present
- [ ] Android release signing material is configured locally / in CI as needed
- [ ] release endpoints use HTTPS/WSS
- [ ] release media uses verified screenshots under `docs/screenshots/` and regenerated GIFs under `docs/gifs/`
- [ ] old proof/current/emulator screenshots are not presented as primary release media
- [ ] `CHANGELOG.md` / release notes are acceptable
- [ ] internal backend services are not unintentionally exposed outside the gateway boundary

## Creating a Release

```bash
git tag v1.2.3
git push origin v1.2.3
```

Expected result:

1. GitHub Release workflow creates a release entry
2. Docker publish workflow builds and pushes images tagged for the release
3. security workflows continue to run on normal branch activity / PRs

## Troubleshooting

### `pnpm install` fails with `EACCES`

Likely a local Windows file lock under `node_modules`.

Safest next steps:

1. close editors / terminals / watchers touching the repo
2. rerun `pnpm install --frozen-lockfile`
3. if it still fails, identify the locking process

### Docker build validation cannot run locally

If Docker daemon is unavailable, you can still validate:

- compose config parsing
- workflow syntax
- Dockerfile structure
- workspace build prerequisites

But final image-build confidence should come from a machine with a working Docker daemon or CI.

### Auth-service tests fail before assertions

If the failure is a missing `bcrypt_lib.node`, treat it as local environment/runtime setup rather than an immediate code regression, then confirm behavior in CI.
