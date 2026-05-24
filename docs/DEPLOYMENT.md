# Deployment Guide

## Overview

This repository ships three kinds of release artifacts:

1. **GitHub release** created by `.github/workflows/release.yml` on semantic tags like `v1.2.3`
2. **Docker images** published by `.github/workflows/docker-publish.yml` to Docker Hub
3. **Deployable runtime configs** for Docker Compose and Kubernetes under repo root / `infra/k8s/`

The public Docker Hub namespace for this project is:

- `nguyenson1710`

Image naming follows this convention:

- `nguyenson1710/crab-mobile-gateway`
- `nguyenson1710/crab-mobile-auth-service`
- `nguyenson1710/crab-mobile-user-service`
- `nguyenson1710/crab-mobile-ride-service`
- `nguyenson1710/crab-mobile-food-service`
- `nguyenson1710/crab-mobile-payment-service`
- `nguyenson1710/crab-mobile-chat-service`
- `nguyenson1710/crab-mobile-notification-service`
- `nguyenson1710/crab-mobile-rating-service`
- `nguyenson1710/crab-mobile-web-admin`

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
| `DOCKERHUB_USERNAME` | yes | Docker Hub username; expected value: `nguyenson1710` |
| `DOCKERHUB_TOKEN` | yes | Docker Hub access token used by docker publish workflow |

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

### 2. Docker Publish

File: `.github/workflows/docker-publish.yml`

Runs on:

- pushes to `main`
- tags matching `v*`
- manual workflow dispatch

What it does:

- logs in to Docker Hub
- builds all backend service images plus web-admin
- publishes images to `nguyenson1710/crab-mobile-<service>`
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
pnpm -w run lint
pnpm -w run build
pnpm -w run contract:check
pnpm -w run test
```

For mobile:

```bash
cd apps/mobile
flutter pub get
flutter analyze
flutter test
```

### Known Local Caveat

On some Windows environments, local workspace verification may be blocked by:

- `pnpm install` hitting `EACCES` inside `node_modules`
- `@crab/auth-service` tests failing before assertions because `bcrypt_lib.node` cannot be loaded locally

If this happens, treat CI on a clean runner as the authority after confirming the diff is otherwise sound.

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
docker compose -f docker-compose.prod.yml config
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

Important: if `admin.crab.example.com` is enabled in ingress, a matching `web-admin` Deployment/Service must exist in `infra/k8s/` or the admin host will route to a missing backend.

Before applying to a real cluster:

1. replace placeholder secrets management with your real secret source
2. verify ingress / DNS / TLS
3. confirm image tags point to the intended SHA or release tag
4. validate probes and resource limits in the target environment

## Release Checklist

Use this checklist before tagging a release:

- [ ] `pnpm -w run lint` is green
- [ ] `pnpm -w run build` is green
- [ ] `pnpm -w run contract:check` is green
- [ ] `pnpm -w run test` is green, or environment-only local blocker is understood and CI is green
- [ ] `flutter analyze` is green
- [ ] `flutter test` is green
- [ ] `docker compose -f docker-compose.prod.yml config` is green
- [ ] required GitHub Actions secrets are present
- [ ] Android release signing material is configured locally / in CI as needed
- [ ] release endpoints use HTTPS/WSS
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
