<a id="readme-top"></a>

[![CI][ci-badge]][ci-url]
[![Docker][docker-badge]][docker-url]
[![GHCR][ghcr-badge]][ghcr-url]
[![License][license-badge]][license-url]
[![Issues][issues-badge]][issues-url]

<div align="center">
  <img src="docs/assets/crab-logo.svg" alt="Crab Super App logo" width="112" />
  <h1>Crab Super App</h1>
  <p>Production-like full-stack portfolio for ride-hailing, food delivery, wallet, realtime chat, and admin operations.</p>
  <p>
    <a href="#english-track">English</a> ·
    <a href="#vietnamese-track">Tiếng Việt</a> ·
    <a href="docs/PORTFOLIO_CASE_STUDY.md">Case Study</a> ·
    <a href="docs/INDEX.md">Docs</a> ·
    <a href="docs/QUICKSTART.md">Quickstart</a> ·
    <a href="docs/PACKAGES.md">Packages</a>
  </p>
</div>

---

<!-- EN:START -->
<a id="english-track"></a>
<a id="english-overview"></a>

## English Track

Crab is a Vietnam-first super-app portfolio project inspired by the product
category of Grab and Be. It keeps its own implementation, visual language, and
production-like local demo path. The repository demonstrates full-stack
engineering across Flutter mobile, React admin operations, NestJS
microservices, REST/Socket.IO contracts, Docker infrastructure, validation
scripts, security scans, and release media.

### Reviewer Fast Path

| Step | What to review | Evidence |
| --- | --- | --- |
| 1 | Read the case study with screenshots and validation evidence | [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md) |
| 2 | Check architecture, package, and artifact boundaries | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), [`docs/PACKAGES.md`](docs/PACKAGES.md) |
| 3 | Run local proof commands | `pnpm run verify:portfolio` |
| 4 | Review CI, security, load, and mobile gates | GitHub Actions, [`docs/CI_CD.md`](docs/CI_CD.md), [`docs/TESTING.md`](docs/TESTING.md) |

### Product Surface

| Area | Capability |
| --- | --- |
| Mobile | Flutter app for rider, driver, food, wallet, chat, notifications, and profile flows |
| Web Admin | React operations console for users, drivers, merchants, rides, orders, payments, promos, and broadcasts |
| Backend | NestJS microservices behind a Gateway with REST and Socket.IO |
| Data | PostgreSQL, MongoDB, Redis, and MinIO |
| Delivery | Docker Compose, Kubernetes manifests, CI/CD, scanners, SBOM, and release workflow |

### Architecture

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

The gateway is the public API and realtime entrypoint. Backend services own
their domain logic and expose health, readiness, and metrics endpoints outside
the `/api/v1` prefix.

### Feature Snapshot

| Area | Capability |
| --- | --- |
| Ride | Request lifecycle, driver matching, location updates, fare estimate, history, rating handoff |
| Food | Restaurant discovery, menu, cart, checkout, order status, delivery tracking |
| Wallet | Balance, top-up, transfer surface, transactions, promo validation model |
| Chat | Conversations, message threads, typing/read primitives, Socket.IO transport |
| Notifications | In-app notifications, unread counts, preferences, broadcast entrypoints |
| Admin | KPI dashboard, users, drivers, restaurants, rides, orders, payments, promos, notifications |
| Platform | Dockerized services, CI gates, Docker Hub/GHCR publish, scanners, K8s manifests, monitoring stack |

### Public Artifacts

| Registry or artifact | Public name | Purpose |
| --- | --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` | Canonical public runtime images |
| GitHub Packages / GHCR | `ghcr.io/jasontm17/crab-mobile-<service>` | GitHub-visible container packages for portfolio review |
| GitHub Releases | `vX.Y.Z` | Versioned release notes and source snapshots |
| Mobile artifacts | APK/AAB/IPA local outputs | Store/distribution artifacts, never committed |

This repository does not publish public npm packages or a public Flutter
package. The root package and workspace packages are private implementation
packages used inside the monorepo.

### Release Media

Admin and client screenshots are curated under
[`docs/screenshots/`](docs/screenshots/). They show populated success states,
not 404 pages, raw loading screens, or temporary proof/current/emulator
captures.

| Surface | Preview | Notes |
| --- | --- | --- |
| Admin login | ![Admin login](docs/screenshots/admin-01-login.png) | Auth entrypoint for operations staff |
| Admin dashboard | ![Admin dashboard](docs/screenshots/admin-02-dashboard.png) | KPI cards, charts, and sidebar navigation |
| Admin users | ![Admin users](docs/screenshots/admin-03-users.png) | User table with status and role tags |
| Admin mobile dashboard | ![Admin mobile dashboard](docs/screenshots/admin-mobile-01-dashboard.png) | Responsive admin viewport |
| Mobile onboarding | ![Mobile onboarding](docs/screenshots/mobile-01-onboarding.png) | Verified Flutter onboarding screenshot |
| Mobile login | ![Mobile client login](docs/screenshots/mobile-client-01-login.png) | Real Flutter auth capture |
| Mobile home | ![Mobile client home](docs/screenshots/mobile-client-02-home.png) | Signed-in user home surface |
| Mobile ride booking | ![Mobile ride booking](docs/screenshots/mobile-client-03-ride-booking.png) | Route, ETA, fare, vehicle choice, CTA |
| Mobile food discovery | ![Mobile food discovery](docs/screenshots/mobile-client-04-food.png) | Restaurants, ratings, ETA, categories |
| Mobile wallet/profile | ![Mobile wallet profile](docs/screenshots/mobile-client-05-wallet-profile.png) | Wallet balance, transactions, trust cues |
| Admin release flow | ![Admin release flow](docs/gifs/admin-release-flow.gif) | Login-to-dashboard walkthrough |
| Mobile client flow | ![Mobile client flow](docs/gifs/mobile-client-flow.gif) | Onboarding, auth, ride, food, wallet |

### Local Demo

```bash
corepack enable
pnpm install --frozen-lockfile
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

### Documentation

| Document | Purpose |
| --- | --- |
| [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md) | Portfolio narrative with screenshots, architecture, validation, and scorecard |
| [`docs/INDEX.md`](docs/INDEX.md) | Documentation hub and reading order |
| [`docs/QUICKSTART.md`](docs/QUICKSTART.md) | Local setup and first run |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | System design, service catalog, data flow |
| [`docs/API.md`](docs/API.md) | REST API reference |
| [`docs/WEBSOCKET_EVENTS.md`](docs/WEBSOCKET_EVENTS.md) | Socket.IO event reference |
| [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) | Environment variable matrix |
| [`docs/CI_CD.md`](docs/CI_CD.md) | CI/CD, releases, scanners, dependency policy |
| [`docs/OPERATIONS_RUNBOOK.md`](docs/OPERATIONS_RUNBOOK.md) | Operations, rollback, backup, incident triage |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Common local/CI failures and fixes |
| [`docs/MOBILE.md`](docs/MOBILE.md) | Flutter architecture, BLoC, DI, routing, feature map |

### Validation

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
pnpm run admin:screenshots
pnpm run docker:config
pnpm run verify:portfolio
```

### Release and Security

- Local full stack: `docker compose up -d`
- Production-like portfolio stack: `docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d`
- Production-like compose validation: `docker compose --env-file .env.production.example -f docker-compose.prod.yml config`
- Kubernetes manifests: `kubectl apply -f infra/k8s/`
- Docker images: `nguyenson1710/crab-mobile-<service>`
- GitHub Packages: `ghcr.io/jasontm17/crab-mobile-<service>`

Do not commit secrets, private keys, keystores, local env files, or real
production credentials. Use only placeholder examples in public docs. Report
vulnerabilities through [`SECURITY.md`](SECURITY.md).

<!-- EN:END -->

---

<!-- VI:START -->
<a id="vietnamese-track"></a>
<a id="tong-quan-tieng-viet"></a>

## Vietnamese Track

Crab là dự án portfolio super-app ưu tiên bối cảnh Việt Nam, lấy cảm hứng ở
cấp độ ngành sản phẩm từ Grab và Be. Dự án có implementation, visual language
và luồng demo production-like riêng. Repository thể hiện năng lực full-stack
qua Flutter mobile, React admin vận hành, NestJS microservices, contract
REST/Socket.IO, Docker infrastructure, validation scripts, security scans và
release media.

### Lộ Trình Review Nhanh

| Bước | Cần xem gì | Bằng chứng |
| --- | --- | --- |
| 1 | Đọc case study có screenshot và bằng chứng kiểm chứng | [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md) |
| 2 | Xem kiến trúc, package và artifact boundary | [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md), [`docs/PACKAGES.md`](docs/PACKAGES.md) |
| 3 | Chạy command local để kiểm chứng | `pnpm run verify:portfolio` |
| 4 | Review CI, security, load test và mobile gates | GitHub Actions, [`docs/CI_CD.md`](docs/CI_CD.md), [`docs/TESTING.md`](docs/TESTING.md) |

### Bề Mặt Sản Phẩm

| Khu vực | Năng lực |
| --- | --- |
| Mobile | Ứng dụng Flutter cho người dùng, tài xế, đồ ăn, ví, chat, thông báo và hồ sơ |
| Web Admin | Console vận hành React cho users, drivers, merchants, rides, orders, payments, promos và broadcasts |
| Backend | NestJS microservices phía sau Gateway, hỗ trợ REST và Socket.IO |
| Data | PostgreSQL, MongoDB, Redis và MinIO |
| Delivery | Docker Compose, Kubernetes manifests, CI/CD, scanners, SBOM và release workflow |

### Kiến Trúc

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

Gateway là điểm vào public cho API và realtime. Mỗi backend service sở hữu
domain logic riêng và expose health, readiness, metrics endpoints bên ngoài
prefix `/api/v1`.

### Tính Năng Chính

| Khu vực | Năng lực |
| --- | --- |
| Ride | Đặt xe, matching tài xế, cập nhật vị trí, ước tính giá, lịch sử, chuyển sang đánh giá |
| Food | Tìm nhà hàng, menu, giỏ hàng, checkout, trạng thái đơn, theo dõi giao hàng |
| Wallet | Số dư, nạp ví, giao diện chuyển tiền, lịch sử giao dịch, mô hình kiểm tra mã khuyến mãi |
| Chat | Hội thoại, luồng tin nhắn, typing/read state, realtime qua Socket.IO |
| Notifications | Thông báo trong app, đếm chưa đọc, tùy chọn nhận thông báo, broadcast từ admin |
| Admin | Dashboard KPI, quản lý users, drivers, restaurants, rides, orders, payments, promos, notifications |
| Platform | Services đóng gói Docker, CI gates, publish Docker Hub/GHCR, scanners, K8s manifests, monitoring stack |

### Artifact Public

| Registry hoặc artifact | Tên public | Vai trò |
| --- | --- | --- |
| Docker Hub | `nguyenson1710/crab-mobile-<service>` | Runtime image public chính |
| GitHub Packages / GHCR | `ghcr.io/jasontm17/crab-mobile-<service>` | Container package để GitHub hiển thị trong portfolio |
| GitHub Releases | `vX.Y.Z` | Release notes và source snapshot theo phiên bản |
| Mobile artifacts | APK/AAB/IPA local outputs | Artifact phân phối mobile, không commit vào repository |

Repo này không publish npm package hoặc Flutter package public. Root package và
workspace packages là package private dùng trong monorepo.

### Hình Ảnh Và GIF

Ảnh admin và client được chọn lọc trong [`docs/screenshots/`](docs/screenshots/).
Ảnh public phải thể hiện trạng thái có dữ liệu, không dùng 404, loading thô
hoặc proof/current/emulator capture tạm.

| Bề mặt | Preview | Ghi chú |
| --- | --- | --- |
| Admin login | ![Admin login](docs/screenshots/admin-01-login.png) | Màn đăng nhập cho nhân sự vận hành |
| Admin dashboard | ![Admin dashboard](docs/screenshots/admin-02-dashboard.png) | KPI cards, biểu đồ và sidebar điều hướng |
| Admin users | ![Admin users](docs/screenshots/admin-03-users.png) | Bảng user có trạng thái và role tag |
| Admin mobile dashboard | ![Admin mobile dashboard](docs/screenshots/admin-mobile-01-dashboard.png) | Kiểm tra admin trên viewport mobile |
| Mobile onboarding | ![Mobile onboarding](docs/screenshots/mobile-01-onboarding.png) | Screenshot onboarding Flutter đã kiểm chứng |
| Mobile login | ![Mobile client login](docs/screenshots/mobile-client-01-login.png) | Màn đăng nhập Flutter thật |
| Mobile home | ![Mobile client home](docs/screenshots/mobile-client-02-home.png) | Home sau đăng nhập của user demo |
| Mobile ride booking | ![Mobile ride booking](docs/screenshots/mobile-client-03-ride-booking.png) | Tuyến đường, ETA, giá, chọn xe, CTA |
| Mobile food discovery | ![Mobile food discovery](docs/screenshots/mobile-client-04-food.png) | Nhà hàng, rating, ETA, danh mục |
| Mobile wallet/profile | ![Mobile wallet profile](docs/screenshots/mobile-client-05-wallet-profile.png) | Số dư ví, giao dịch, tín hiệu tin cậy |
| Admin release flow | ![Admin release flow](docs/gifs/admin-release-flow.gif) | GIF đăng nhập và vào dashboard admin |
| Mobile client flow | ![Mobile client flow](docs/gifs/mobile-client-flow.gif) | GIF onboarding, auth, gọi xe, đồ ăn, ví |

### Demo Local

```bash
corepack enable
pnpm install --frozen-lockfile
docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d
pnpm run db:migrate
pnpm run db:seed
pnpm run test:e2e
pnpm run test:load
pnpm run verify:portfolio
```

Tài khoản demo:

| Role | Email | Password |
| --- | --- | --- |
| Admin | `admin@crab.app` | `Admin123!` |
| Rider | `rider@crab.app` | `User123!` |
| Driver | `driver@crab.app` | `Driver123!` |
| Merchant | `merchant@crab.app` | `User123!` |

### Tài Liệu

| Tài liệu | Mục đích |
| --- | --- |
| [`docs/PORTFOLIO_CASE_STUDY.md`](docs/PORTFOLIO_CASE_STUDY.md) | Hồ sơ portfolio có screenshot, kiến trúc, kiểm chứng và bảng tự chấm |
| [`docs/INDEX.md`](docs/INDEX.md) | Mục lục tài liệu và lộ trình đọc |
| [`docs/QUICKSTART.md`](docs/QUICKSTART.md) | Setup local và lần chạy đầu |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Thiết kế hệ thống, service catalog, luồng dữ liệu |
| [`docs/API.md`](docs/API.md) | Tài liệu REST API |
| [`docs/WEBSOCKET_EVENTS.md`](docs/WEBSOCKET_EVENTS.md) | Tài liệu event Socket.IO |
| [`docs/ENVIRONMENT.md`](docs/ENVIRONMENT.md) | Bảng biến môi trường |
| [`docs/CI_CD.md`](docs/CI_CD.md) | CI/CD, release, scanner, chính sách dependency |
| [`docs/OPERATIONS_RUNBOOK.md`](docs/OPERATIONS_RUNBOOK.md) | Vận hành, rollback, backup, xử lý sự cố |
| [`docs/TROUBLESHOOTING.md`](docs/TROUBLESHOOTING.md) | Lỗi local/CI thường gặp và cách xử lý |
| [`docs/MOBILE.md`](docs/MOBILE.md) | Kiến trúc Flutter, BLoC, DI, routing, bản đồ tính năng |

### Kiểm Tra

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
pnpm run admin:screenshots
pnpm run docker:config
pnpm run verify:portfolio
```

### Phát Hành Và Bảo Mật

- Local full stack: `docker compose up -d`
- Production-like portfolio stack: `docker compose --env-file .env.production.example -f docker-compose.prod.yml up -d`
- Kiểm tra compose production-like: `docker compose --env-file .env.production.example -f docker-compose.prod.yml config`
- Kubernetes manifests: `kubectl apply -f infra/k8s/`
- Docker images: `nguyenson1710/crab-mobile-<service>`
- GitHub Packages: `ghcr.io/jasontm17/crab-mobile-<service>`

Không commit secrets, private keys, keystores, local env files hoặc credentials
production thật. Tài liệu public chỉ dùng placeholder. Báo cáo lỗ hổng qua
[`SECURITY.md`](SECURITY.md).

<!-- VI:END -->

---

## License

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
