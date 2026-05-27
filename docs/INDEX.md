# Documentation Index / Mục Lục Tài Liệu

Crab documentation is organized by reading path: start with quick setup, then architecture, contracts, deployment, operations, and product surfaces.

Tài liệu Crab được sắp xếp theo lộ trình đọc: bắt đầu từ setup nhanh, sau đó tới kiến trúc, contract, deployment, vận hành và các bề mặt sản phẩm.

## Start Here / Bắt Đầu Từ Đây

| Document | English | Tiếng Việt |
| --- | --- | --- |
| [English README](../README.md#english-overview) | English portfolio overview, reviewer signals, and proof path | Bản tổng quan tiếng Anh cho reviewer |
| [README Tiếng Việt](../README.md#tong-quan-tieng-viet) | Vietnamese overview with the same portfolio proof path | Bản tổng quan tiếng Việt cùng lộ trình kiểm chứng |
| [Portfolio Case Study](./PORTFOLIO_CASE_STUDY.md) | Bilingual portfolio narrative with screenshots, architecture, demo path, validation evidence, and self-review scorecard | Hồ sơ portfolio song ngữ có screenshot, kiến trúc, luồng demo, bằng chứng kiểm chứng và bảng tự chấm điểm |
| [Quickstart](./QUICKSTART.md) | Run the full stack locally | Chạy full stack trên máy local |
| [Environment](./ENVIRONMENT.md) | Env variable matrix and safe placeholders | Bảng env variables và placeholder an toàn |
| [Packages](./PACKAGES.md) | Workspace package catalog, Docker Hub images, GHCR packages, mobile artifacts | Catalog package workspace, Docker Hub images, GHCR packages và mobile artifacts |
| [Release Media](./screenshots/README.md) | Verified screenshots and GIF gallery | Bộ screenshot và GIF đã xác minh |
| [Brand Logo](./assets/crab-logo.svg) | Public Crab Super App logo used in the README and portfolio docs | Logo public của Crab Super App dùng trong README và tài liệu portfolio |
| [Troubleshooting](./TROUBLESHOOTING.md) | Common local/CI failures and fixes | Lỗi thường gặp và cách xử lý |

## Architecture & Contracts / Kiến Trúc & Contract

| Document | English | Tiếng Việt |
| --- | --- | --- |
| [Architecture](./ARCHITECTURE.md) | Service boundaries, data ownership, flows | Ranh giới service, dữ liệu sở hữu, luồng hệ thống |
| [API Reference](./API.md) | REST endpoints and examples | REST endpoints và ví dụ request/response |
| [OpenAPI](./openapi.yaml) | Static OpenAPI contract | Contract OpenAPI tĩnh |
| [Database](./DATABASE.md) | PostgreSQL, MongoDB, Redis schemas | Schema PostgreSQL, MongoDB, Redis |
| [Realtime](./REALTIME.md) | Socket.IO topology and reliability model | Kiến trúc Socket.IO và độ tin cậy |
| [WebSocket Events](./WEBSOCKET_EVENTS.md) | Wire-level event names and payloads | Event và payload ở tầng wire |

## Domain Guides / Hướng Dẫn Nghiệp Vụ

| Document | English | Tiếng Việt |
| --- | --- | --- |
| [Ride Matching](./RIDE_MATCHING.md) | Ride lifecycle, matching, surge, rematch | Vòng đời chuyến xe, matching, surge, rematch |
| [Food Delivery](./FOOD_DELIVERY.md) | Restaurant, menu, order, delivery states | Nhà hàng, menu, order, trạng thái giao hàng |
| [Rating](./RATING.md) | Rating model and aggregate updates | Model rating và cập nhật aggregate |

## Apps / Ứng Dụng

| Document | English | Tiếng Việt |
| --- | --- | --- |
| [Mobile App](./MOBILE.md) | Flutter architecture and feature map | Kiến trúc Flutter và bản đồ tính năng |
| [Mobile UI/UX Redesign](./MOBILE_UI_UX_REDESIGN.md) | A-Z customer mobile redesign plan, accessibility gates, and release media checklist | Kế hoạch hoàn thiện UI/UX mobile user, accessibility và release media |
| [Admin Dashboard](./ADMIN.md) | React admin architecture and pages | Kiến trúc và trang của React admin |
| [Screenshots](./screenshots/README.md) | Curated admin and client gallery | Bộ ảnh admin và client đã chọn lọc |

## Release, Deployment & Operations / Phát Hành, Triển Khai & Vận Hành

| Document | English | Tiếng Việt |
| --- | --- | --- |
| [Release & Deployment](./DEPLOYMENT.md) | Release artifacts, images, tags, mobile requirements, and checklist | Artifacts phát hành, images, tags, yêu cầu mobile và checklist |
| [Docker Deployment](./DEPLOYMENT_DOCKER.md) | Compose files and local/prod stack | Compose files và stack local/prod |
| [Kubernetes Deployment](./DEPLOYMENT_KUBERNETES.md) | K8s manifests, ingress, HPA, rollout | K8s manifests, ingress, HPA, rollout |
| [CI/CD](./CI_CD.md) | GitHub Actions, scanners, release flow | GitHub Actions, scanners, release flow |
| [Operations Runbook](./OPERATIONS_RUNBOOK.md) | Health, logs, backup, rollback, incidents | Health, logs, backup, rollback, sự cố |
| [Observability](./OBSERVABILITY.md) | Metrics, logs, traces, dashboards | Metrics, logs, traces, dashboards |
| [Testing](./TESTING.md) | Unit, integration, load, mobile tests | Unit, integration, load, mobile tests |
| [Packages](./PACKAGES.md) | Package and release artifact catalog | Catalog package và artifact phát hành |

## Repository & Community / Repo & Cộng Đồng

| Document | English | Tiếng Việt |
| --- | --- | --- |
| [Contributing](../CONTRIBUTING.md) | Setup, branch, commit, PR rules | Setup, branch, commit, quy tắc PR |
| [Security](../SECURITY.md) | Vulnerability reporting and policy | Báo cáo lỗ hổng và chính sách bảo mật |
| [Code of Conduct](../CODE_OF_CONDUCT.md) | Community standards | Quy tắc cộng đồng |
| [Changelog](../CHANGELOG.md) | Versioned change history | Lịch sử thay đổi theo phiên bản |
| [License](../LICENSE) | MIT license | Giấy phép MIT |

## Canonical Runtime Constants / Hằng Số Runtime Chính

| Item | Value |
| --- | --- |
| REST base path | `/api/v1` |
| Gateway dev URL | `http://localhost:3000/api/v1` |
| Flutter emulator API URL | `http://10.0.2.2:3000/api/v1` |
| Socket.IO namespaces | `/ride`, `/food`, `/chat`, `/notification` |
| Health endpoints | `/health`, `/healthz`, `/readyz`, `/metrics` outside `/api/v1` |
| Docker image prefix | `nguyenson1710/crab-mobile-<service>` |
| GitHub Packages image prefix | `ghcr.io/jasontm17/crab-mobile-<service>` |
| Portfolio verification | `pnpm run verify:portfolio` |
| Local smoke | `pnpm run test:e2e` after Docker + seed |
| Demo seed path | `pnpm run db:migrate && pnpm run db:seed` |

## Canonical Status Vocabulary / Bộ Trạng Thái Chuẩn

Ride status:

```text
REQUESTED -> MATCHED -> PICKUP -> IN_PROGRESS -> COMPLETED
any non-terminal state -> CANCELLED
```

Order status:

```text
PLACED -> CONFIRMED -> PREPARING -> READY -> PICKED_UP -> DELIVERED
any non-terminal state -> CANCELLED
```

## Project Structure / Cấu Trúc Dự Án

```text
Crab_Mobile_Flutter/
├── apps/
│   ├── backend/          NestJS gateway, services, shared backend utilities
│   ├── mobile/           Flutter mobile app
│   └── web-admin/        React admin dashboard
├── packages/
│   ├── common-types/     Shared DTOs, enums, interfaces
│   └── socket-events/    Shared Socket.IO event contracts
├── docs/                 Public documentation and release media
├── infra/k8s/            Kubernetes manifests
├── monitoring/           Monitoring configs retained for canonicalization/reference
├── tests/e2e/            Root E2E test harness and fixtures
├── tests/load/           Load test scenarios
└── .github/workflows/    CI/CD, scanners, SBOM, releases
```

## Documentation Rules / Quy Tắc Tài Liệu

- Public docs must not contain secrets, private keys, real tokens, production credentials, private emails, phone numbers, or payment details.
- Tài liệu public không được chứa secrets, private keys, tokens thật, credentials production, email/số điện thoại/thanh toán thật.
- Screenshots must show successful populated states unless the document explicitly explains an empty/error state.
- Ảnh chụp phải thể hiện trạng thái thành công có dữ liệu, trừ khi tài liệu đang giải thích empty/error state.
- Private planning files live under `.kilo/` or ignored private patterns and must not be committed.
- File kế hoạch/private notes nằm trong `.kilo/` hoặc pattern private đã ignore và không được commit.
