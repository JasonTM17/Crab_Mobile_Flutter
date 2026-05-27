# Packages And Release Artifacts

This document is intentionally split into separate English and Vietnamese
tracks. It explains why GitHub may show packages in the sidebar even though the
source packages remain private implementation packages.

Tài liệu này được tách riêng phần English và phần tiếng Việt. Nội dung giải
thích vì sao GitHub có thể hiển thị packages ở sidebar dù source packages vẫn
là package implementation private trong monorepo.

<!-- PACKAGES-EN:START -->

## English Packages And Release Artifacts

Crab is a private application monorepo. Source packages are internal
implementation packages and are not published to npm or pub.dev. Public
portfolio artifacts are container images, GitHub Releases, and mobile build
outputs produced outside version control.

### Public Package Visibility

GitHub's repository sidebar shows packages only after artifacts are published to
GitHub Packages. For this project, that package surface is GHCR container
images. Docker Hub remains the canonical external runtime namespace.

| Registry | Naming convention | Purpose |
| --- | --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` | Canonical external runtime image namespace |
| GitHub Packages | `ghcr.io/jasontm17/crab-mobile-<service>` | GitHub-visible package surface for portfolio review |
| GitHub Releases | `vX.Y.Z` | Versioned release notes and source snapshots |

The Docker publish workflow builds the same service images for both registries.
If Docker Hub secrets are missing, the workflow can still publish GHCR images
with `GITHUB_TOKEN`, which is enough for the GitHub Packages sidebar to show
real portfolio artifacts.

### Workspace Packages

| Package | Path | Runtime | Purpose | Published |
| --- | --- | --- | --- | --- |
| `crab-super-app` | `/` | Node 20, pnpm 10 | Workspace orchestration, CI scripts, verification, release commands | No, private root |
| `@crab/common-types` | `packages/common-types` | TypeScript | Shared DTOs, enums, interfaces | No, internal package |
| `@crab/socket-events` | `packages/socket-events` | TypeScript | Shared Socket.IO event contracts | No, internal package |
| `@crab/backend-shared` | `apps/backend/shared` | NestJS, TypeScript | Backend utilities shared by services | No, internal package |
| `@crab/gateway` | `apps/backend/gateway` | NestJS | Public API gateway and realtime entrypoint | Docker image only |
| `@crab/auth-service` | `apps/backend/auth-service` | NestJS | Authentication and JWT issuing | Docker image only |
| `@crab/user-service` | `apps/backend/user-service` | NestJS | User profiles, driver records, documents | Docker image only |
| `@crab/ride-service` | `apps/backend/ride-service` | NestJS | Ride request, matching, lifecycle | Docker image only |
| `@crab/food-service` | `apps/backend/food-service` | NestJS | Restaurants, menus, orders | Docker image only |
| `@crab/payment-service` | `apps/backend/payment-service` | NestJS | Wallet, payments, promos | Docker image only |
| `@crab/chat-service` | `apps/backend/chat-service` | NestJS | Conversations and messages | Docker image only |
| `@crab/notification-service` | `apps/backend/notification-service` | NestJS | Notifications and broadcasts | Docker image only |
| `@crab/rating-service` | `apps/backend/rating-service` | NestJS | Ratings and reviews | Docker image only |
| `@crab/web-admin` | `apps/web-admin` | React, Vite | Admin operations dashboard | Docker image only |
| `@crab/mobile` | `apps/mobile` | Flutter | Rider, driver, food, wallet mobile app | Store, APK, or AAB artifact only |

### Docker Images

Canonical Docker Hub image names follow:

```text
nguyenson1710/crab-mobile-<service>
```

GitHub Packages image names follow:

```text
ghcr.io/jasontm17/crab-mobile-<service>
```

| Service | Docker Hub | GitHub Packages | Dockerfile |
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

### Image Tags

| Tag | Meaning |
| --- | --- |
| `latest` | Latest successful push from `main` when registry secrets are configured |
| `sha-<short>` | Immutable commit-addressable image |
| `<semver>` | Release image built from tag `vX.Y.Z` |

### Mobile Artifacts

The Flutter app is intentionally private and declares `publish_to: 'none'` in
`apps/mobile/pubspec.yaml`.

| Artifact | Command | Notes |
| --- | --- | --- |
| Android debug APK | `flutter build apk --debug` | Local QA only |
| Android release APK | `flutter build apk --release` | Requires local signing config for distribution |
| Android App Bundle | `flutter build appbundle --release` | Play Store artifact |
| iOS archive | Xcode or `flutter build ipa` | Requires Apple signing outside this repo |

Do not commit generated APK, AAB, IPA, keystores, provisioning profiles, or
signing env files.

<!-- PACKAGES-EN:END -->

---

<!-- PACKAGES-VI:START -->

## Vietnamese Packages And Release Artifacts

Crab là monorepo ứng dụng private. Source packages là package nội bộ phục vụ
implementation, không publish lên npm hoặc pub.dev. Artifact public cho
portfolio là container image, GitHub Release và mobile build output được tạo
ngoài version control.

### Hiển Thị Packages Trên GitHub

Sidebar Packages của GitHub chỉ hiển thị sau khi artifact được publish lên
GitHub Packages. Với repo này, bề mặt package đó là container image trên GHCR.
Docker Hub vẫn là namespace runtime external chính.

| Registry | Quy ước đặt tên | Vai trò |
| --- | --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` | Namespace runtime image external chính |
| GitHub Packages | `ghcr.io/jasontm17/crab-mobile-<service>` | Package hiển thị trên GitHub để reviewer thấy artifact thật |
| GitHub Releases | `vX.Y.Z` | Release notes và source snapshot theo phiên bản |

Workflow Docker publish build cùng bộ service image cho cả hai registry. Nếu
thiếu Docker Hub secrets, workflow vẫn có thể publish GHCR image bằng
`GITHUB_TOKEN`, đủ để GitHub Packages sidebar hiển thị artifact portfolio thật.

### Workspace Packages

| Package | Đường dẫn | Runtime | Vai trò | Publish |
| --- | --- | --- | --- | --- |
| `crab-super-app` | `/` | Node 20, pnpm 10 | Điều phối workspace, CI scripts, verification, release commands | Không, private root |
| `@crab/common-types` | `packages/common-types` | TypeScript | DTO, enum và interface dùng chung | Không, package nội bộ |
| `@crab/socket-events` | `packages/socket-events` | TypeScript | Contract event Socket.IO dùng chung | Không, package nội bộ |
| `@crab/backend-shared` | `apps/backend/shared` | NestJS, TypeScript | Utility backend dùng chung giữa services | Không, package nội bộ |
| `@crab/gateway` | `apps/backend/gateway` | NestJS | API gateway public và entrypoint realtime | Chỉ Docker image |
| `@crab/auth-service` | `apps/backend/auth-service` | NestJS | Xác thực và phát hành JWT | Chỉ Docker image |
| `@crab/user-service` | `apps/backend/user-service` | NestJS | Hồ sơ user, hồ sơ tài xế, giấy tờ | Chỉ Docker image |
| `@crab/ride-service` | `apps/backend/ride-service` | NestJS | Đặt xe, matching, lifecycle | Chỉ Docker image |
| `@crab/food-service` | `apps/backend/food-service` | NestJS | Nhà hàng, menu, đơn hàng | Chỉ Docker image |
| `@crab/payment-service` | `apps/backend/payment-service` | NestJS | Ví, thanh toán, khuyến mãi | Chỉ Docker image |
| `@crab/chat-service` | `apps/backend/chat-service` | NestJS | Hội thoại và tin nhắn | Chỉ Docker image |
| `@crab/notification-service` | `apps/backend/notification-service` | NestJS | Thông báo và broadcast | Chỉ Docker image |
| `@crab/rating-service` | `apps/backend/rating-service` | NestJS | Rating và review | Chỉ Docker image |
| `@crab/web-admin` | `apps/web-admin` | React, Vite | Dashboard vận hành admin | Chỉ Docker image |
| `@crab/mobile` | `apps/mobile` | Flutter | Ứng dụng mobile cho rider, driver, food, wallet | Chỉ Store, APK hoặc AAB artifact |

### Docker Images

Tên Docker Hub chính:

```text
nguyenson1710/crab-mobile-<service>
```

Tên GitHub Packages:

```text
ghcr.io/jasontm17/crab-mobile-<service>
```

| Service | Docker Hub | GitHub Packages | Dockerfile |
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

### Image Tags

| Tag | Ý nghĩa |
| --- | --- |
| `latest` | Bản push thành công mới nhất từ `main` khi registry secrets đã cấu hình |
| `sha-<short>` | Image cố định theo commit |
| `<semver>` | Image release build từ tag `vX.Y.Z` |

### Mobile Artifacts

Flutter app là ứng dụng private và khai báo `publish_to: 'none'` trong
`apps/mobile/pubspec.yaml`.

| Artifact | Lệnh | Ghi chú |
| --- | --- | --- |
| Android debug APK | `flutter build apk --debug` | Chỉ dùng QA local |
| Android release APK | `flutter build apk --release` | Cần signing config local để phân phối |
| Android App Bundle | `flutter build appbundle --release` | Artifact cho Play Store |
| iOS archive | Xcode hoặc `flutter build ipa` | Cần Apple signing ngoài repo |

Không commit APK, AAB, IPA, keystore, provisioning profile hoặc signing env
file được generate.

<!-- PACKAGES-VI:END -->
