# Packages and Release Artifacts / Gói và Artifact Phát Hành

Crab is a private application monorepo. Source packages are internal
implementation packages and are not published to npm or pub.dev. Public
portfolio artifacts are container images, GitHub Releases, and mobile build
outputs produced outside version control.

Crab là monorepo ứng dụng private. Các source package là package nội bộ phục vụ
implementation, không publish lên npm hoặc pub.dev. Artifact public cho
portfolio là container image, GitHub Release và mobile build output được tạo
ngoài version control.

## Public Package Visibility / Hiển Thị Packages Trên GitHub

GitHub's repository sidebar shows packages only after artifacts are published to
GitHub Packages. For this project, that means GHCR container images.

Sidebar Packages của GitHub chỉ hiển thị sau khi artifact được publish lên
GitHub Packages. Với repo này, artifact đó là GHCR container image.

| Registry | Naming Convention | Purpose |
| --- | --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` | Canonical external runtime image namespace |
| GitHub Packages / GHCR | `ghcr.io/jasontm17/crab-mobile-<service>` | GitHub-visible package surface for portfolio review |
| GitHub Releases | `vX.Y.Z` | Versioned release notes and source snapshots |

The Docker publish workflow builds the same service images for both registries.
If Docker Hub secrets are missing, the workflow still publishes GHCR images with
`GITHUB_TOKEN` so the GitHub Packages sidebar can show real artifacts.

Workflow Docker publish build cùng bộ service image cho cả hai registry. Nếu
thiếu Docker Hub secrets, workflow vẫn publish GHCR image bằng `GITHUB_TOKEN` để
sidebar GitHub Packages có artifact thật.

## Workspace Packages / Gói Workspace

| Package | Path | Runtime | Purpose | Published? |
| --- | --- | --- | --- | --- |
| `crab-super-app` | `/` | Node 20 / pnpm 10 | Workspace orchestration, CI scripts, release commands | No, private monorepo root |
| `@crab/common-types` | `packages/common-types` | TypeScript | Shared DTOs, enums, interfaces | No, internal package |
| `@crab/socket-events` | `packages/socket-events` | TypeScript | Shared Socket.IO event contracts | No, internal package |
| `@crab/backend-shared` | `apps/backend/shared` | NestJS / TypeScript | Backend utilities shared by services | No, internal package |
| `@crab/gateway` | `apps/backend/gateway` | NestJS | Public API gateway and realtime entrypoint | Docker only |
| `@crab/auth-service` | `apps/backend/auth-service` | NestJS | Authentication and JWT issuing | Docker only |
| `@crab/user-service` | `apps/backend/user-service` | NestJS | User profiles, driver records, documents | Docker only |
| `@crab/ride-service` | `apps/backend/ride-service` | NestJS | Ride request, matching, lifecycle | Docker only |
| `@crab/food-service` | `apps/backend/food-service` | NestJS | Restaurants, menus, orders | Docker only |
| `@crab/payment-service` | `apps/backend/payment-service` | NestJS | Wallet, payments, promos | Docker only |
| `@crab/chat-service` | `apps/backend/chat-service` | NestJS | Conversations and messages | Docker only |
| `@crab/notification-service` | `apps/backend/notification-service` | NestJS | Notifications and broadcasts | Docker only |
| `@crab/rating-service` | `apps/backend/rating-service` | NestJS | Ratings and reviews | Docker only |
| `@crab/web-admin` | `apps/web-admin` | React / Vite | Admin operations dashboard | Docker only |
| `@crab/mobile` | `apps/mobile` | Flutter | Rider, driver, food, wallet mobile app | Store/APK/AAB only |

## Docker Images / Container Images

Canonical Docker Hub image names follow:

```text
nguyenson1710/crab-mobile-<service>
```

GitHub Packages / GHCR image names follow:

```text
ghcr.io/jasontm17/crab-mobile-<service>
```

| Service | Docker Hub | GHCR | Dockerfile |
| --- | --- | --- | --- |
| Gateway | `nguyenson1710/crab-mobile-gateway` | `ghcr.io/jasontm17/crab-mobile-gateway` | `apps/backend/gateway/Dockerfile` |
| Auth | `nguyenson1710/crab-mobile-auth-service` | `ghcr.io/jasontm17/crab-mobile-auth-service` | `apps/backend/auth-service/Dockerfile` |
| User | `nguyenson1710/crab-mobile-user-service` | `ghcr.io/jasontm17/crab-mobile-user-service` | `apps/backend/user-service/Dockerfile` |
| Ride | `nguyenson1710/crab-mobile-ride-service` | `ghcr.io/jasontm17/crab-mobile-ride-service` | `apps/backend/ride-service/Dockerfile` |
| Food | `nguyenson1710/crab-mobile-food-service` | `ghcr.io/jasontm17/crab-mobile-food-service` | `apps/backend/food-service/Dockerfile` |
| Payment | `nguyenson1710/crab-mobile-payment-service` | `ghcr.io/jasontm17/crab-mobile-payment-service` | `apps/backend/payment-service/Dockerfile` |
| Chat | `nguyenson1710/crab-mobile-chat-service` | `ghcr.io/jasontm17/crab-mobile-chat-service` | `apps/backend/chat-service/Dockerfile` |
| Notification | `nguyenson1710/crab-mobile-notification-service` | `ghcr.io/jasontm17/crab-mobile-notification-service` | `apps/backend/notification-service/Dockerfile` |
| Rating | `nguyenson1710/crab-mobile-rating-service` | `ghcr.io/jasontm17/crab-mobile-rating-service` | `apps/backend/rating-service/Dockerfile` |
| Web Admin | `nguyenson1710/crab-mobile-web-admin` | `ghcr.io/jasontm17/crab-mobile-web-admin` | `apps/web-admin/Dockerfile` |

Tags:

| Tag | Meaning |
| --- | --- |
| `latest` | Latest successful push from `main` when Docker Hub secrets are configured |
| `sha-<short>` | Immutable commit-addressable image |
| `<semver>` | Release image built from tag `vX.Y.Z` |

## Mobile Artifacts / Artifact Mobile

The Flutter app is intentionally private and declares `publish_to: 'none'` in `apps/mobile/pubspec.yaml`.

Expected release outputs:

| Artifact | Command | Notes |
| --- | --- | --- |
| Android debug APK | `flutter build apk --debug` | Local QA only |
| Android release APK | `flutter build apk --release` | Requires local signing config for distribution |
| Android App Bundle | `flutter build appbundle --release` | Play Store artifact |
| iOS archive | Xcode / `flutter build ipa` | Requires Apple signing outside this repo |

Do not commit generated APK, AAB, IPA, keystores, provisioning profiles, or signing env files.

Không commit APK, AAB, IPA, keystore, provisioning profile hoặc signing env file.
