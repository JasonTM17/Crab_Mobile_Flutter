<a id="readme-top"></a>

[![CI][ci-badge]][ci-url]
[![Docker][docker-badge]][docker-url]
[![GHCR][ghcr-badge]][ghcr-url]
[![License][license-badge]][license-url]
[![Issues][issues-badge]][issues-url]

<div align="center">
  <img src="docs/assets/crab-logo.svg" alt="Crab Super App logo" width="112" />
  <h1>Crab Super App</h1>
  <p><strong>English:</strong> Production-like full-stack portfolio for ride-hailing, food delivery, wallet, realtime chat, and admin operations.</p>
  <p><strong>Tiếng Việt:</strong> Portfolio full-stack production-like cho gọi xe, giao đồ ăn, ví, chat realtime và vận hành admin.</p>
  <p>
    <a href="#english-overview">English</a> ·
    <a href="#tong-quan-tieng-viet">Tiếng Việt</a> ·
    <a href="docs/PORTFOLIO_CASE_STUDY.md">Case Study / Hồ Sơ</a> ·
    <a href="docs/INDEX.md">Docs / Tài Liệu</a> ·
    <a href="docs/QUICKSTART.md">Quickstart / Chạy Nhanh</a> ·
    <a href="docs/PACKAGES.md">Packages / Artifact</a>
  </p>
</div>

---

<a id="english-overview"></a>

## English Overview

Crab is a Vietnam-first super-app portfolio project inspired by the product category of Grab and Be. It keeps its own implementation, visual language, and production-like local demo path. The repository is designed to demonstrate end-to-end engineering depth across Flutter mobile, React admin operations, NestJS microservices, REST/Socket.IO contracts, Docker infrastructure, validation scripts, security scans, and release media.

| Reviewer signal | What to look for | Evidence |
| --- | --- | --- |
| Product breadth | Ride, food, wallet, chat, notifications, ratings, admin | Screenshots, GIFs, feature docs |
| Engineering depth | Mobile, web admin, backend services, contracts, data stores | `apps/`, `packages/`, `docs/ARCHITECTURE.md` |
| Production-like delivery | Local Docker demo, CI, Docker Hub, GHCR, scanners, SBOM | GitHub Actions, `docs/PACKAGES.md`, `docs/CI_CD.md` |
| Repeatable proof | E2E, load, mobile analyze/test, portfolio verification | `pnpm run verify:portfolio` |

<a id="tong-quan-tieng-viet"></a>

## Tổng Quan Tiếng Việt

Crab là dự án portfolio super-app ưu tiên bối cảnh Việt Nam, lấy cảm hứng ở cấp độ ngành sản phẩm từ Grab và Be. Dự án có implementation, visual language và luồng demo production-like riêng. Repository được xây để thể hiện năng lực kỹ thuật full-stack từ đầu tới cuối: Flutter mobile, React admin vận hành, NestJS microservices, contract REST/Socket.IO, Docker infrastructure, validation scripts, security scans và release media.

| Tín hiệu review | Cần xem gì | Bằng chứng |
| --- | --- | --- |
| Độ rộng sản phẩm | Gọi xe, đồ ăn, ví, chat, thông báo, đánh giá, admin | Screenshot, GIF, tài liệu tính năng |
| Độ sâu kỹ thuật | Mobile, web admin, backend services, contract, data stores | `apps/`, `packages/`, `docs/ARCHITECTURE.md` |
| Khả năng giao hàng production-like | Demo Docker local, CI, Docker Hub, GHCR, scanner, SBOM | GitHub Actions, `docs/PACKAGES.md`, `docs/CI_CD.md` |
| Bằng chứng lặp lại được | E2E, load test, mobile analyze/test, portfolio verification | `pnpm run verify:portfolio` |

## Reviewer Fast Path / Lộ Trình Review Nhanh

| Step | English | Tiếng Việt |
| --- | --- | --- |
| 1 | Read the polished case study with screenshots and validation evidence | Đọc case study có screenshot và bằng chứng kiểm chứng |
| 2 | Scan the architecture and package/artifact catalog | Xem kiến trúc và catalog package/artifact |
| 3 | Run the local Docker demo path if you want proof beyond screenshots | Chạy demo Docker local nếu muốn kiểm chứng ngoài screenshot |
| 4 | Review CI, security scans, E2E, load tests, and mobile checks | Review CI, security scan, E2E, load test và mobile checks |

Primary reading path:

```text
README -> docs/PORTFOLIO_CASE_STUDY.md -> docs/INDEX.md -> docs/QUICKSTART.md
```

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

| Area | English capability | Tính năng tiếng Việt |
| --- | --- | --- |
| Ride | Request lifecycle, driver matching, location updates, fare estimate, history, rating handoff | Đặt xe, matching tài xế, cập nhật vị trí, ước tính giá, lịch sử, chuyển sang đánh giá |
| Food | Restaurant discovery, menu, cart, checkout, order status, delivery tracking | Tìm nhà hàng, menu, giỏ hàng, checkout, trạng thái đơn, theo dõi giao hàng |
| Wallet | Balance, top-up, transfer surface, transactions, promo validation model | Số dư, nạp ví, giao diện chuyển tiền, lịch sử giao dịch, kiểm tra mã khuyến mãi |
| Chat | Conversations, message threads, typing/read primitives, Socket.IO transport | Hội thoại, luồng tin nhắn, typing/read state, realtime qua Socket.IO |
| Notifications | In-app notifications, unread counts, preferences, broadcast entrypoints | Thông báo trong app, đếm chưa đọc, tùy chọn nhận thông báo, broadcast từ admin |
| Admin | KPI dashboard, users, drivers, restaurants, rides, orders, payments, promos, notifications | Dashboard KPI, quản lý users, drivers, restaurants, rides, orders, payments, promos, notifications |
| Platform | Dockerized services, CI gates, Docker Hub/GHCR publish, scanners, K8s manifests, monitoring stack | Services đóng gói Docker, CI gates, publish Docker Hub/GHCR, scanner, K8s manifests, monitoring stack |

## Packages & Public Artifacts / Gói & Artifact Public

GitHub's sidebar only shows packages published to GitHub Packages. Crab now publishes container images to GHCR for GitHub visibility and keeps Docker Hub as the canonical external namespace.

Sidebar Packages trên GitHub chỉ hiện artifact được publish lên GitHub Packages. Crab hiện publish container image lên GHCR để GitHub hiển thị package, đồng thời vẫn giữ Docker Hub là namespace external chính.

| Registry / Artifact | Public name | English purpose | Vai trò tiếng Việt |
| --- | --- | --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` | Canonical public runtime images | Runtime image public chính |
| GitHub Packages / GHCR | `ghcr.io/jasontm17/crab-mobile-<service>` | GitHub-visible container packages for portfolio review | Package container để GitHub hiển thị trong sidebar |
| GitHub Releases | `vX.Y.Z` | Versioned release notes and source snapshots | Ghi chú phát hành và source snapshot theo phiên bản |
| Mobile artifacts | APK/AAB/IPA local outputs | Store/distribution artifacts, never committed | Artifact mobile để phân phối, không commit vào repo |

This repository does not publish public npm packages or a public Flutter package. The root package and workspace packages are private implementation packages used inside the monorepo. See [`docs/PACKAGES.md`](docs/PACKAGES.md) for the full package, image, and release artifact catalog.

Repo này không publish npm package hoặc Flutter package public. Root package và workspace packages là package private dùng trong monorepo. Xem [`docs/PACKAGES.md`](docs/PACKAGES.md) để biết catalog package, image và artifact phát hành đầy đủ.

| Workspace Package | Path | English role | Vai trò tiếng Việt |
| --- | --- | --- | --- |
| `crab-super-app` | `/` | Root pnpm workspace, CI, verification, release scripts | Workspace root, CI, script kiểm chứng và release |
| `@crab/common-types` | `packages/common-types` | Shared DTOs, enums, interfaces | DTO, enum và interface dùng chung |
| `@crab/socket-events` | `packages/socket-events` | Shared Socket.IO event names and payload contracts | Tên event Socket.IO và payload contract dùng chung |
| `@crab/backend-shared` | `apps/backend/shared` | Internal NestJS utilities shared by services | Utility NestJS nội bộ dùng chung giữa services |
| `@crab/gateway` | `apps/backend/gateway` | Public REST and Socket.IO gateway | Gateway REST và Socket.IO public |
| `@crab/auth-service` | `apps/backend/auth-service` | Auth, OTP, JWT, refresh token, sessions | Xác thực, OTP, JWT, refresh token, session |
| `@crab/user-service` | `apps/backend/user-service` | Profiles, addresses, preferences, driver records | Hồ sơ, địa chỉ, tùy chọn, hồ sơ tài xế |
| `@crab/ride-service` | `apps/backend/ride-service` | Booking, fare estimate, matching, tracking | Đặt xe, ước tính giá, matching, theo dõi chuyến |
| `@crab/food-service` | `apps/backend/food-service` | Restaurants, menus, carts, orders | Nhà hàng, menu, giỏ hàng, đơn đồ ăn |
| `@crab/payment-service` | `apps/backend/payment-service` | Wallet, top-up, transactions, promos | Ví, nạp tiền, giao dịch, mã khuyến mãi |
| `@crab/chat-service` | `apps/backend/chat-service` | Conversations, messages, receipts, presence | Hội thoại, tin nhắn, trạng thái đã đọc, presence |
| `@crab/notification-service` | `apps/backend/notification-service` | Notifications, unread counts, broadcasts | Thông báo, đếm chưa đọc, broadcast |
| `@crab/rating-service` | `apps/backend/rating-service` | Ratings, reviews, aggregate scores | Đánh giá, review, điểm tổng hợp |
| `@crab/web-admin` | `apps/web-admin` | Private React/Vite operations dashboard | Dashboard vận hành React/Vite private |
| `@crab/mobile` | `apps/mobile` | Flutter app with `publish_to: none` | Ứng dụng Flutter, không publish pub.dev |

## Release Media / Hình Ảnh & GIF

Admin and client screenshots are curated under [`docs/screenshots/`](docs/screenshots/). They should show populated success states, not 404 pages, raw loading screens, or temporary proof/current/emulator captures.

Ảnh admin và client được chọn lọc trong [`docs/screenshots/`](docs/screenshots/). Ảnh public phải thể hiện trạng thái có dữ liệu, không dùng 404, loading thô hoặc proof/current/emulator capture tạm.

Refresh mobile release screenshots with `pnpm run mobile:screenshots`.

| Surface | Preview | English notes | Ghi chú tiếng Việt |
| --- | --- | --- | --- |
| Admin login | ![Admin login](docs/screenshots/admin-01-login.png) | Auth entrypoint for operations staff | Màn đăng nhập cho nhân sự vận hành |
| Admin dashboard | ![Admin dashboard](docs/screenshots/admin-02-dashboard.png) | KPI cards and sidebar navigation | KPI cards và sidebar điều hướng |
| Admin users | ![Admin users](docs/screenshots/admin-03-users.png) | User table with status and role tags | Bảng user có trạng thái và role tag |
| Admin mobile dashboard | ![Admin mobile dashboard](docs/screenshots/admin-mobile-01-dashboard.png) | Responsive admin viewport | Kiểm tra admin trên viewport mobile |
| Mobile onboarding | ![Mobile onboarding](docs/screenshots/mobile-01-onboarding.png) | Verified Flutter onboarding screenshot | Screenshot onboarding Flutter đã kiểm chứng |
| Mobile login | ![Mobile client login](docs/screenshots/mobile-client-01-login.png) | Real Flutter auth capture | Màn đăng nhập Flutter thật |
| Mobile home | ![Mobile client home](docs/screenshots/mobile-client-02-home.png) | Signed-in user home surface | Home sau đăng nhập của user demo |
| Mobile ride booking | ![Mobile ride booking](docs/screenshots/mobile-client-03-ride-booking.png) | Route, ETA, fare, vehicle choice, CTA | Tuyến đường, ETA, giá, chọn xe, CTA |
| Mobile food discovery | ![Mobile food discovery](docs/screenshots/mobile-client-04-food.png) | Restaurants, ratings, ETA, categories | Nhà hàng, rating, ETA, danh mục |
| Mobile wallet/profile | ![Mobile wallet profile](docs/screenshots/mobile-client-05-wallet-profile.png) | Wallet balance, transactions, trust cues | Số dư ví, giao dịch, tín hiệu tin cậy |
| Admin release flow | ![Admin release flow](docs/gifs/admin-release-flow.gif) | Login to dashboard walkthrough | GIF đăng nhập và vào dashboard admin |
| Mobile client flow | ![Mobile client flow](docs/gifs/mobile-client-flow.gif) | Onboarding, auth, ride, food, wallet | GIF onboarding, auth, gọi xe, đồ ăn, ví |

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

Demo portfolio production-like chạy bằng Docker local, không phải cloud launch. Demo dùng Docker Compose, tài khoản seed, release media và các command kiểm chứng có thể chạy lặp lại.

Read the detailed bilingual portfolio narrative, screenshot gallery, validation evidence, and repository self-review scorecard in [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md).

Đọc hồ sơ portfolio song ngữ chi tiết, gallery screenshot, bằng chứng kiểm chứng và bảng tự chấm repo tại [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md).

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

| Document | English purpose | Mục đích tiếng Việt |
| --- | --- | --- |
| [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md) | Portfolio case study with screenshots, architecture, validation, scorecard | Hồ sơ portfolio có screenshot, kiến trúc, kiểm chứng, bảng tự chấm |
| [`docs/INDEX.md`](docs/INDEX.md) | Documentation hub and reading order | Mục lục tài liệu và lộ trình đọc |
| [`docs/QUICKSTART.md`](docs/QUICKSTART.md) | Local setup and first run | Setup local và lần chạy đầu |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | System design, service catalog, data flow | Thiết kế hệ thống, service catalog, luồng dữ liệu |
| [`docs/API.md`](docs/API.md) | REST API reference | Tài liệu REST API |
| [`docs/WEBSOCKET_EVENTS.md`](docs/WEBSOCKET_EVENTS.md) | Socket.IO event reference | Tài liệu event Socket.IO |
| [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) | Environment variable matrix | Bảng biến môi trường |
| [`docs/CI_CD.md`](docs/CI_CD.md) | CI/CD, releases, scanners, dependency policy | CI/CD, release, scanner, chính sách dependency |
| [`docs/OPERATIONS_RUNBOOK.md`](docs/OPERATIONS_RUNBOOK.md) | Operations, rollback, backup, incident triage | Vận hành, rollback, backup, xử lý sự cố |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Common local/CI failures and fixes | Lỗi local/CI thường gặp và cách xử lý |
| [`docs/MOBILE.md`](docs/MOBILE.md) | Flutter architecture, BLoC, DI, routing, feature map | Kiến trúc Flutter, BLoC, DI, routing, bản đồ tính năng |

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
- GitHub Packages: `ghcr.io/jasontm17/crab-mobile-<service>`

Release tags use the `vX.Y.Z` format. `.github/workflows/release.yml` creates the GitHub Release entry, while `.github/workflows/docker-publish.yml` publishes service images with `latest`, `sha-<short>`, and semver tags.

Tag phát hành dùng format `vX.Y.Z`. `.github/workflows/release.yml` tạo GitHub Release, còn `.github/workflows/docker-publish.yml` publish service images với tag `latest`, `sha-<short>` và semver.

See [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md), [`docs/DEPLOYMENT_DOCKER.md`](docs/DEPLOYMENT_DOCKER.md), and [`docs/DEPLOYMENT_KUBERNETES.md`](docs/DEPLOYMENT_KUBERNETES.md).

## Repository Metadata / Metadata Repo

| Field | English | Tiếng Việt |
| --- | --- | --- |
| GitHub About | `Flutter + React admin + NestJS microservices monorepo for a ride-hailing and food-delivery super app.` | Mô tả ngắn cho GitHub About của repo |
| Suggested topics | `flutter`, `nestjs`, `react`, `typescript`, `microservices`, `ride-hailing`, `food-delivery`, `docker`, `socket-io` | Topic gợi ý để repo dễ tìm và đúng ngữ cảnh portfolio |

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
[ghcr-badge]: https://img.shields.io/badge/GHCR-GitHub%20Packages-24292F?style=for-the-badge&logo=github&logoColor=white
[ghcr-url]: docs/PACKAGES.md
[license-badge]: https://img.shields.io/badge/License-MIT-2ea44f?style=for-the-badge
[license-url]: LICENSE
[issues-badge]: https://img.shields.io/github/issues/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[issues-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/issues
