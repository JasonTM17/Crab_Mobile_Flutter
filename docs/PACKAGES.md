# Packages and Release Artifacts

Crab is a private monorepo. Source packages are private implementation packages and are not published to npm or pub.dev; public runtime artifacts are Docker images, GitHub Releases, and signed mobile build outputs.

## Workspace Packages

| Package | Path | Runtime | Purpose | Published? |
| --- | --- | --- | --- | --- |
| `crab-super-app` | `/` | Node 20 / pnpm 10 | Workspace orchestration, CI scripts, release commands | No |
| `@crab/common-types` | `packages/common-types` | TypeScript | Shared DTOs, enums, interfaces | No |
| `@crab/socket-events` | `packages/socket-events` | TypeScript | Shared Socket.IO event contracts | No |
| `@crab/backend-shared` | `apps/backend/shared` | NestJS / TypeScript | Backend utilities shared by services | No |
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

## Docker Images

Public image names follow:

```text
nguyenson1710/crab-mobile-<service>
```

| Image | Dockerfile |
| --- | --- |
| `nguyenson1710/crab-mobile-gateway` | `apps/backend/gateway/Dockerfile` |
| `nguyenson1710/crab-mobile-auth-service` | `apps/backend/auth-service/Dockerfile` |
| `nguyenson1710/crab-mobile-user-service` | `apps/backend/user-service/Dockerfile` |
| `nguyenson1710/crab-mobile-ride-service` | `apps/backend/ride-service/Dockerfile` |
| `nguyenson1710/crab-mobile-food-service` | `apps/backend/food-service/Dockerfile` |
| `nguyenson1710/crab-mobile-payment-service` | `apps/backend/payment-service/Dockerfile` |
| `nguyenson1710/crab-mobile-chat-service` | `apps/backend/chat-service/Dockerfile` |
| `nguyenson1710/crab-mobile-notification-service` | `apps/backend/notification-service/Dockerfile` |
| `nguyenson1710/crab-mobile-rating-service` | `apps/backend/rating-service/Dockerfile` |
| `nguyenson1710/crab-mobile-web-admin` | `apps/web-admin/Dockerfile` |

Tags:

| Tag | Meaning |
| --- | --- |
| `latest` | Latest successful push from `main` when Docker Hub secrets are configured |
| `sha-<short>` | Immutable commit-addressable image |
| `<semver>` | Release image built from tag `vX.Y.Z` |

## Mobile Artifacts

The Flutter app is intentionally private and declares `publish_to: 'none'` in `apps/mobile/pubspec.yaml`.

Expected release outputs:

| Artifact | Command | Notes |
| --- | --- | --- |
| Android debug APK | `flutter build apk --debug` | Local QA only |
| Android release APK | `flutter build apk --release` | Requires local signing config for distribution |
| Android App Bundle | `flutter build appbundle --release` | Play Store artifact |
| iOS archive | Xcode / `flutter build ipa` | Requires Apple signing outside this repo |

Do not commit generated APK, AAB, IPA, keystores, provisioning profiles, or signing env files.
