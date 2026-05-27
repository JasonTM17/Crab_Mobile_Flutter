<a id="readme-top"></a>

[![CI][ci-badge]][ci-url]
[![Docker][docker-badge]][docker-url]
[![License][license-badge]][license-url]
[![Issues][issues-badge]][issues-url]

<div align="center">
  <h1>Crab Super App</h1>
  <p><strong>Ride-hailing, food delivery, wallet, chat, and admin operations in one production-minded monorepo.</strong></p>
  <p><strong>Super app gọi xe, giao đồ ăn, ví, chat và vận hành admin trong một monorepo hướng production.</strong></p>
  <p>
    <a href="docs/PORTFOLIO_CASE_STUDY.md">Portfolio Case Study</a> ·
    <a href="docs/INDEX.md">Documentation</a> ·
    <a href="docs/QUICKSTART.md">Quickstart</a> ·
    <a href="docs/API.md">API</a> ·
    <a href="docs/DEPLOYMENT.md">Deployment</a> ·
    <a href="docs/MOBILE.md">Mobile</a>
  </p>
</div>

---

## About / Giới Thiệu

Crab is a full-stack super-app platform inspired by Grab and Be. It separates the Flutter mobile client, React admin dashboard, and NestJS backend services so each surface can be developed, tested, deployed, and scaled independently.

Crab là nền tảng super-app full-stack lấy cảm hứng từ Grab và Be. Hệ thống tách riêng Flutter mobile, React admin dashboard và các NestJS backend services để từng phần có thể phát triển, kiểm thử, triển khai và mở rộng độc lập.

GitHub About suggestion: `Flutter + React admin + NestJS microservices monorepo for a ride-hailing and food-delivery super app.`

Suggested topics: `flutter`, `nestjs`, `react`, `vite`, `typescript`, `microservices`, `ride-hailing`, `food-delivery`, `docker`, `socket-io`, `postgresql`, `mongodb`, `redis`.

| Area | English | Tiếng Việt |
| --- | --- | --- |
| Mobile | Flutter app for rider, driver, food, wallet, chat, notifications, and profile flows | Ứng dụng Flutter cho người dùng, tài xế, đồ ăn, ví, chat, thông báo và hồ sơ |
| Web Admin | React operations console for users, drivers, merchants, rides, orders, payments, promos, and broadcasts | Bảng điều khiển React cho users, drivers, merchants, rides, orders, payments, promos và broadcasts |
| Backend | NestJS microservices behind a Gateway with REST and Socket.IO | NestJS microservices phía sau Gateway, hỗ trợ REST và Socket.IO |
| Data | PostgreSQL, MongoDB, Redis, and MinIO | PostgreSQL, MongoDB, Redis và MinIO |
| Delivery | Docker Compose, Kubernetes manifests, CI/CD, scanners, SBOM, and release workflow | Docker Compose, Kubernetes manifests, CI/CD, scanners, SBOM và release workflow |

## Architecture / Kiến Trúc

```text
Flutter Mobile / React Admin
            |
            | HTTPS + WSS
            v
API Gateway :3000  -- JWT, rate limit, proxy, Socket.IO namespaces
            |
            v
Auth :3001 | User :3002 | Ride :3003 | Food :3004 | Payment :3005
Chat :3006 | Notification :3007 | Rating :3008
            |
            v
PostgreSQL | MongoDB | Redis | MinIO
```

The gateway is the public API and realtime entrypoint. Backend services own their domain logic and expose health/ready/metrics endpoints outside the `/api/v1` prefix.

Gateway là điểm vào public cho API và realtime. Mỗi backend service sở hữu domain logic riêng và expose health/ready/metrics bên ngoài prefix `/api/v1`.

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full service catalog, data ownership model, and deployment topology.

## Feature Snapshot / Tính Năng Chính

| Product area | Current capabilities |
| --- | --- |
| Ride | Ride request lifecycle, driver matching, location updates, fare estimate, history, rating handoff |
| Food | Restaurant discovery, menu, cart, checkout, order status, delivery tracking |
| Wallet | Wallet balance, top-up, transfer surface, transactions, promo validation model |
| Chat | Conversations, message threads, typing/read primitives, Socket.IO transport |
| Notifications | In-app notifications, unread counts, preferences, broadcast entrypoints |
| Admin | KPI dashboard, users, drivers, restaurants, rides, orders, payments, promos, notifications |
| Platform | Dockerized services, CI gates, Docker Hub publish, scanners, K8s manifests, monitoring stack |

## Packages / Gói Workspace

This repository does not publish public npm packages or a public Flutter package. The root package and workspace packages are private implementation packages used inside the monorepo, while runtime artifacts are distributed through Docker images and GitHub Releases. See [`docs/PACKAGES.md`](docs/PACKAGES.md) for the full package and artifact catalog.

Repo này không publish npm package hoặc Flutter package public. Root package và workspace packages là package private dùng trong monorepo; runtime artifacts được phát hành qua Docker images và GitHub Releases. Xem [`docs/PACKAGES.md`](docs/PACKAGES.md) để biết catalog package và artifact đầy đủ.

| Package / Artifact | Path | Purpose |
| --- | --- | --- |
| `crab-super-app` | `/` | Root pnpm workspace, CI, verification, and release scripts |
| `@crab/common-types` | `packages/common-types` | Shared DTOs, enums, and interfaces used by backend, admin, and clients |
| `@crab/socket-events` | `packages/socket-events` | Shared Socket.IO event names and payload contracts |
| `@crab/backend-shared` | `apps/backend/shared` | Internal NestJS utilities shared by backend services |
| `@crab/gateway` | `apps/backend/gateway` | Public REST and Socket.IO gateway |
| `@crab/auth-service` | `apps/backend/auth-service` | Auth, OTP, JWT, refresh token, and session flows |
| `@crab/user-service` | `apps/backend/user-service` | User profiles, saved addresses, preferences, avatars, and driver records |
| `@crab/ride-service` | `apps/backend/ride-service` | Ride booking, fare estimate, matching, tracking, and lifecycle |
| `@crab/food-service` | `apps/backend/food-service` | Restaurants, menus, carts, orders, and delivery tracking |
| `@crab/payment-service` | `apps/backend/payment-service` | Wallet balance, top-up, transactions, payments, refunds, and promos |
| `@crab/chat-service` | `apps/backend/chat-service` | Realtime conversations, messages, receipts, typing, and presence |
| `@crab/notification-service` | `apps/backend/notification-service` | In-app notifications, unread counts, preferences, and broadcasts |
| `@crab/rating-service` | `apps/backend/rating-service` | Ratings, reviews, aggregate scores, replies, and reports |
| `@crab/web-admin` | `apps/web-admin` | Private React/Vite operations dashboard |
| `@crab/mobile` | `apps/mobile` | Flutter app with `publish_to: none`; not a pub.dev package |

## Release Media / Hình Ảnh & GIF

Admin and client screenshots are curated under [`docs/screenshots/`](docs/screenshots/). They should show populated success states, not 404 pages, raw loading screens, or temporary proof/current/emulator captures.

Ảnh admin và client được chọn lọc trong [`docs/screenshots/`](docs/screenshots/). Ảnh public phải thể hiện trạng thái có dữ liệu, không dùng 404, loading thô hoặc proof/current/emulator capture tạm.

Refresh mobile release screenshots with `pnpm run mobile:screenshots`.

| Surface | Preview | Notes |
| --- | --- | --- |
| Admin login | ![Admin login](docs/screenshots/admin-01-login.png) | Auth entrypoint for operations staff |
| Admin dashboard | ![Admin dashboard](docs/screenshots/admin-02-dashboard.png) | KPI cards and sidebar navigation |
| Admin users | ![Admin users](docs/screenshots/admin-03-users.png) | User table with status and role tags |
| Admin mobile dashboard | ![Admin mobile dashboard](docs/screenshots/admin-mobile-01-dashboard.png) | Responsive admin viewport after the mobile layout fix |
| Mobile onboarding | ![Mobile onboarding](docs/screenshots/mobile-01-onboarding.png) | Verified Flutter onboarding screenshot from the current widget tree |
| Mobile login | ![Mobile client login](docs/screenshots/mobile-client-01-login.png) | Real Flutter login screen capture for user auth |
| Mobile home | ![Mobile client home](docs/screenshots/mobile-client-02-home.png) | Real Flutter signed-in user home screen capture |
| Mobile ride booking | ![Mobile ride booking](docs/screenshots/mobile-client-03-ride-booking.png) | Stitch-guided booking flow with route, ETA, fare, vehicle choice, and CTA |
| Mobile food discovery | ![Mobile food discovery](docs/screenshots/mobile-client-04-food.png) | Stitch-guided restaurant discovery with ratings, ETA, categories, and delivery fee |
| Mobile wallet/profile | ![Mobile wallet profile](docs/screenshots/mobile-client-05-wallet-profile.png) | Wallet balance, transactions, and trust cues for the seeded demo account |
| Admin release flow | ![Admin release flow](docs/gifs/admin-release-flow.gif) | Login to dashboard and core operations walkthrough |
| Mobile client flow | ![Mobile client flow](docs/gifs/mobile-client-flow.gif) | Onboarding, auth, home, ride, food, and wallet walkthrough |

## Quickstart / Chạy Nhanh

Use the full stack compose file for the fastest local path.

Dùng compose full stack để chạy local nhanh nhất.

```bash
corepack enable
pnpm install --frozen-lockfile
docker compose up -d
pnpm dev
```

Mobile development:

```bash
node scripts/run-mobile-tool.js flutter pub get
pnpm --filter @crab/mobile lint
pnpm --filter @crab/mobile test
cd apps/mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1 --dart-define=SOCKET_URL=http://10.0.2.2:3000
```

More setup details: [`docs/QUICKSTART.md`](docs/QUICKSTART.md).

## Portfolio Demo / Demo Portfolio

The production-like portfolio target is a local Docker demo, not a cloud launch. It uses Docker Compose, seeded demo accounts, release media, and repeatable validation commands.

Read the detailed bilingual portfolio narrative, screenshot gallery, validation evidence, and repository self-review scorecard in [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md).

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d
pnpm run db:migrate
pnpm run db:seed
pnpm run test:e2e
pnpm run test:load
pnpm run verify:portfolio
```

Demo accounts:

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@crab.app` | `Admin123!` |
| Rider | `rider@crab.app` | `User123!` |
| Driver | `driver@crab.app` | `Driver123!` |
| Merchant | `merchant@crab.app` | `User123!` |

## Repository Map / Cấu Trúc Repo

```text
apps/backend/           NestJS gateway, services, shared backend utilities
apps/mobile/            Flutter app, BLoC, GetIt, GoRouter, Dio, Socket.IO
apps/web-admin/         React 18, Vite, TypeScript, Tailwind, shadcn/ui
packages/common-types/  Shared DTOs, enums, and interfaces
packages/socket-events/ Shared Socket.IO event contracts
docs/                   Public technical documentation and release media
infra/k8s/              Kubernetes manifests and deployment helper
monitoring/             Monitoring configs kept for reference/canonicalization
scripts/portfolio-smoke.js
                        Root gateway E2E runner for demo auth, wallet, food, ride, ratings, notifications, and chat
tests/e2e/              Legacy deeper E2E fixtures kept for future expansion
tests/load/             Load test scenarios
.github/workflows/      CI, Docker publish, release, scanner, SBOM workflows
```

## Documentation / Tài Liệu

Start here:

| Document | Purpose |
| --- | --- |
| [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md) | Bilingual portfolio case study with screenshots, architecture, demo path, validation evidence, and repo scorecard |
| [`docs/INDEX.md`](docs/INDEX.md) | Documentation hub and reading order |
| [`docs/QUICKSTART.md`](docs/QUICKSTART.md) | Local setup and first run |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | System design, service catalog, data flow |
| [`docs/API.md`](docs/API.md) | REST API reference |
| [`docs/WEBSOCKET_EVENTS.md`](docs/WEBSOCKET_EVENTS.md) | Socket.IO event reference |
| [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) | Environment variable matrix |
| [`docs/CI_CD.md`](docs/CI_CD.md) | CI/CD, releases, scanners, dependency policy |
| [`docs/OPERATIONS_RUNBOOK.md`](docs/OPERATIONS_RUNBOOK.md) | Operations, rollback, backup, incident triage |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Common local/dev failures and fixes |
| [`docs/MOBILE.md`](docs/MOBILE.md) | Flutter architecture, BLoC, DI, routing, and feature map |

## Validation / Kiểm Tra

Run the relevant checks before claiming a change is done.

Chạy các kiểm tra phù hợp trước khi kết luận hoàn tất.

```bash
pnpm install --frozen-lockfile
pnpm run package:check
pnpm run contract:check
pnpm run test:e2e
pnpm run test:load
pnpm --filter @crab/web-admin build
pnpm run mobile:analyze
pnpm run mobile:test
pnpm run mobile:screenshots
pnpm run docker:config
pnpm run verify:portfolio
```

## Release & Deployment / Phát Hành & Triển Khai

- Local full stack: `docker compose up -d`
- Production-like portfolio stack: `docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d`
- Production-like compose validation: `docker compose --env-file .env.production.example -f docker-compose.prod.yml config`
- Kubernetes manifests: `kubectl apply -f infra/k8s/`
- Docker images: `nguyenson1710/crab-mobile-<service>`

Release tags use the `vX.Y.Z` format. `.github/workflows/release.yml` creates the GitHub Release entry, while `.github/workflows/docker-publish.yml` publishes service images with `latest`, `sha-<short>`, and semver tags.

Tag phát hành dùng format `vX.Y.Z`. `.github/workflows/release.yml` tạo GitHub Release, còn `.github/workflows/docker-publish.yml` publish service images với tag `latest`, `sha-<short>` và semver.

See [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md), [`docs/DEPLOYMENT_DOCKER.md`](docs/DEPLOYMENT_DOCKER.md), and [`docs/DEPLOYMENT_KUBERNETES.md`](docs/DEPLOYMENT_KUBERNETES.md).

## Security / Bảo Mật

Do not commit secrets, private keys, keystores, local env files, or real production credentials. Use only placeholder examples in public docs.

Không commit secrets, private keys, keystores, local env files hoặc credentials thật. Tài liệu public chỉ dùng placeholder.

Report vulnerabilities through [`SECURITY.md`](SECURITY.md).

## License / Giấy Phép

MIT. See [`LICENSE`](LICENSE).

<div align="center">
  <p>Crab Super App · Built and maintained by <a href="https://github.com/JasonTM17">Nguyen Tien Son</a></p>
</div>

[ci-badge]: https://img.shields.io/github/actions/workflow/status/JasonTM17/Crab_Mobile_Flutter/ci.yml?style=for-the-badge&label=CI
[ci-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/actions
[docker-badge]: https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white
[docker-url]: docs/DEPLOYMENT.md
[license-badge]: https://img.shields.io/github/license/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[license-url]: LICENSE
[issues-badge]: https://img.shields.io/github/issues/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[issues-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/issues
