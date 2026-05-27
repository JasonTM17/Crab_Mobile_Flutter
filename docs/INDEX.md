# Documentation Index

This index is intentionally split into two complete reading tracks. Read the
English track first, or jump to the Vietnamese track. The two languages are not
mixed inside the same tables or section headings.

Tài liệu này được tách thành hai đường đọc hoàn chỉnh. Bạn có thể đọc phần
English trước, hoặc chuyển thẳng xuống phần tiếng Việt. Hai ngôn ngữ không được
trộn trong cùng bảng hoặc heading.

<!-- INDEX-EN:START -->

## English Documentation Index

Use this track when reviewing the project in English. Start with the portfolio
overview and case study, then move into architecture, operations, and product
surface docs as needed.

### Start Here

| Document | Use |
| --- | --- |
| [English README](../README.md#english-track) | Portfolio overview, reviewer path, media, demo accounts, and validation commands |
| [Portfolio Case Study](./PORTFOLIO_CASE_STUDY.md#english-case-study) | Polished portfolio narrative with screenshots, architecture, evidence, and scorecard |
| [Quickstart](./QUICKSTART.md) | Local setup and service startup path |
| [Environment](./ENVIRONMENT.md) | Environment variable matrix and safe placeholders |
| [Packages](./PACKAGES.md#english-packages-and-release-artifacts) | Workspace packages, Docker Hub images, GHCR packages, and mobile artifacts |
| [Release Media](./screenshots/README.md#english-screenshots-gallery) | Verified screenshot and GIF gallery |
| [Brand Logo](./assets/crab-logo.svg) | Public Crab Super App logo used by README and portfolio docs |
| [Troubleshooting](./TROUBLESHOOTING.md) | Common local and CI failures with fixes |

### Architecture And Contracts

| Document | Use |
| --- | --- |
| [Architecture](./ARCHITECTURE.md) | Service boundaries, data ownership, and system flows |
| [API Reference](./API.md) | REST endpoints and request examples |
| [OpenAPI](./openapi.yaml) | Static OpenAPI contract |
| [Database](./DATABASE.md) | PostgreSQL, MongoDB, and Redis schemas |
| [Realtime](./REALTIME.md) | Socket.IO topology and reliability model |
| [WebSocket Events](./WEBSOCKET_EVENTS.md) | Wire-level event names and payloads |

### Domain Guides

| Document | Use |
| --- | --- |
| [Ride Matching](./RIDE_MATCHING.md) | Ride lifecycle, matching, surge, and rematch behavior |
| [Food Delivery](./FOOD_DELIVERY.md) | Restaurant, menu, order, and delivery state behavior |
| [Rating](./RATING.md) | Rating model and aggregate updates |

### Apps

| Document | Use |
| --- | --- |
| [Mobile App](./MOBILE.md) | Flutter architecture and feature map |
| [Mobile UI/UX Redesign](./MOBILE_UI_UX_REDESIGN.md) | Customer mobile redesign plan, accessibility gates, and release media checklist |
| [Admin Dashboard](./ADMIN.md) | React admin architecture and operations pages |
| [Screenshots](./screenshots/README.md#english-screenshots-gallery) | Curated admin and client gallery |

### Release Deployment And Operations

| Document | Use |
| --- | --- |
| [Release And Deployment](./DEPLOYMENT.md) | Release artifacts, images, tags, mobile requirements, and checklist |
| [Docker Deployment](./DEPLOYMENT_DOCKER.md) | Compose files and local or production-like stack |
| [Kubernetes Deployment](./DEPLOYMENT_KUBERNETES.md) | Kubernetes manifests, ingress, HPA, and rollout notes |
| [CI/CD](./CI_CD.md) | GitHub Actions, scanners, and release flow |
| [Operations Runbook](./OPERATIONS_RUNBOOK.md) | Health checks, logs, backups, rollback, and incidents |
| [Observability](./OBSERVABILITY.md) | Metrics, logs, traces, and dashboards |
| [Testing](./TESTING.md) | Unit, integration, load, and mobile tests |
| [Packages](./PACKAGES.md#english-packages-and-release-artifacts) | Package and release artifact catalog |

### Repository And Community

| Document | Use |
| --- | --- |
| [Contributing](../CONTRIBUTING.md) | Setup, branch, commit, and PR rules |
| [Security](../SECURITY.md) | Vulnerability reporting policy |
| [Code of Conduct](../CODE_OF_CONDUCT.md) | Community standards |
| [Changelog](../CHANGELOG.md) | Versioned change history |
| [License](../LICENSE) | MIT license |

### Canonical Runtime Constants

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
| Local smoke | `pnpm run test:e2e` after Docker and seed |
| Demo seed path | `pnpm run db:migrate && pnpm run db:seed` |

### Canonical Status Vocabulary

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

### Project Structure

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
├── monitoring/           Monitoring configs retained for reference
├── tests/e2e/            Root E2E test harness and fixtures
├── tests/load/           Load test scenarios
└── .github/workflows/    CI/CD, scanners, SBOM, releases
```

### Documentation Rules

- Public docs must not contain secrets, private keys, real tokens, production
  credentials, private emails, phone numbers, or payment details.
- Screenshots must show successful populated states unless a document explicitly
  explains an empty or error state.
- Private planning files live under ignored private patterns and must not be
  committed.
- Main portfolio docs must keep English and Vietnamese in separate reading
  tracks instead of mixed tables or slash headings.

<!-- INDEX-EN:END -->

---

<!-- INDEX-VI:START -->

## Vietnamese Documentation Index

Dùng đường đọc này khi review dự án bằng tiếng Việt. Bắt đầu từ README và case
study, sau đó đi tiếp vào kiến trúc, vận hành và tài liệu từng bề mặt sản phẩm
khi cần.

### Bắt Đầu Từ Đây

| Tài liệu | Mục đích |
| --- | --- |
| [README tiếng Việt](../README.md#vietnamese-track) | Tổng quan portfolio, lộ trình review, media, tài khoản demo và lệnh kiểm chứng |
| [Hồ sơ portfolio](./PORTFOLIO_CASE_STUDY.md#vietnamese-case-study) | Bản trình bày portfolio có screenshot, kiến trúc, bằng chứng và bảng tự chấm điểm |
| [Chạy nhanh](./QUICKSTART.md) | Thiết lập local và khởi động service |
| [Biến môi trường](./ENVIRONMENT.md) | Ma trận biến môi trường và placeholder an toàn |
| [Gói và artifact](./PACKAGES.md#vietnamese-packages-and-release-artifacts) | Workspace packages, Docker Hub images, GHCR packages và mobile artifacts |
| [Release media](./screenshots/README.md#vietnamese-screenshots-gallery) | Bộ screenshot và GIF đã kiểm chứng |
| [Logo thương hiệu](./assets/crab-logo.svg) | Logo public của Crab Super App dùng trong README và tài liệu portfolio |
| [Xử lý lỗi](./TROUBLESHOOTING.md) | Lỗi local hoặc CI thường gặp và cách xử lý |

### Kiến Trúc Và Contract

| Tài liệu | Mục đích |
| --- | --- |
| [Kiến trúc](./ARCHITECTURE.md) | Ranh giới service, dữ liệu sở hữu và luồng hệ thống |
| [API Reference](./API.md) | REST endpoints và ví dụ request |
| [OpenAPI](./openapi.yaml) | Contract OpenAPI tĩnh |
| [Database](./DATABASE.md) | Schema PostgreSQL, MongoDB và Redis |
| [Realtime](./REALTIME.md) | Kiến trúc Socket.IO và mô hình độ tin cậy |
| [WebSocket Events](./WEBSOCKET_EVENTS.md) | Tên event và payload ở tầng wire |

### Hướng Dẫn Nghiệp Vụ

| Tài liệu | Mục đích |
| --- | --- |
| [Ride Matching](./RIDE_MATCHING.md) | Vòng đời chuyến xe, matching, surge và rematch |
| [Food Delivery](./FOOD_DELIVERY.md) | Nhà hàng, menu, order và trạng thái giao hàng |
| [Rating](./RATING.md) | Model đánh giá và cập nhật aggregate |

### Ứng Dụng

| Tài liệu | Mục đích |
| --- | --- |
| [Mobile App](./MOBILE.md) | Kiến trúc Flutter và bản đồ tính năng |
| [Mobile UI/UX Redesign](./MOBILE_UI_UX_REDESIGN.md) | Kế hoạch hoàn thiện mobile user, accessibility và release media |
| [Admin Dashboard](./ADMIN.md) | Kiến trúc React admin và các trang vận hành |
| [Screenshots](./screenshots/README.md#vietnamese-screenshots-gallery) | Bộ ảnh admin và client đã chọn lọc |

### Phát Hành Triển Khai Và Vận Hành

| Tài liệu | Mục đích |
| --- | --- |
| [Release và Deployment](./DEPLOYMENT.md) | Artifacts phát hành, images, tags, yêu cầu mobile và checklist |
| [Docker Deployment](./DEPLOYMENT_DOCKER.md) | Compose files và stack local hoặc production-like |
| [Kubernetes Deployment](./DEPLOYMENT_KUBERNETES.md) | Kubernetes manifests, ingress, HPA và rollout |
| [CI/CD](./CI_CD.md) | GitHub Actions, scanners và release flow |
| [Operations Runbook](./OPERATIONS_RUNBOOK.md) | Health check, logs, backup, rollback và incident |
| [Observability](./OBSERVABILITY.md) | Metrics, logs, traces và dashboards |
| [Testing](./TESTING.md) | Unit, integration, load và mobile tests |
| [Packages](./PACKAGES.md#vietnamese-packages-and-release-artifacts) | Catalog package và release artifact |

### Repo Và Cộng Đồng

| Tài liệu | Mục đích |
| --- | --- |
| [Contributing](../CONTRIBUTING.md) | Setup, branch, commit và quy tắc PR |
| [Security](../SECURITY.md) | Chính sách báo cáo lỗ hổng |
| [Code of Conduct](../CODE_OF_CONDUCT.md) | Quy tắc cộng đồng |
| [Changelog](../CHANGELOG.md) | Lịch sử thay đổi theo phiên bản |
| [License](../LICENSE) | Giấy phép MIT |

### Hằng Số Runtime Chính

| Hạng mục | Giá trị |
| --- | --- |
| REST base path | `/api/v1` |
| Gateway dev URL | `http://localhost:3000/api/v1` |
| Flutter emulator API URL | `http://10.0.2.2:3000/api/v1` |
| Socket.IO namespaces | `/ride`, `/food`, `/chat`, `/notification` |
| Health endpoints | `/health`, `/healthz`, `/readyz`, `/metrics` ngoài `/api/v1` |
| Docker image prefix | `nguyenson1710/crab-mobile-<service>` |
| GitHub Packages image prefix | `ghcr.io/jasontm17/crab-mobile-<service>` |
| Portfolio verification | `pnpm run verify:portfolio` |
| Local smoke | `pnpm run test:e2e` sau khi Docker và seed đã sẵn sàng |
| Demo seed path | `pnpm run db:migrate && pnpm run db:seed` |

### Bộ Trạng Thái Chuẩn

Trạng thái chuyến xe:

```text
REQUESTED -> MATCHED -> PICKUP -> IN_PROGRESS -> COMPLETED
any non-terminal state -> CANCELLED
```

Trạng thái đơn đồ ăn:

```text
PLACED -> CONFIRMED -> PREPARING -> READY -> PICKED_UP -> DELIVERED
any non-terminal state -> CANCELLED
```

### Cấu Trúc Dự Án

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
├── monitoring/           Monitoring configs retained for reference
├── tests/e2e/            Root E2E test harness and fixtures
├── tests/load/           Load test scenarios
└── .github/workflows/    CI/CD, scanners, SBOM, releases
```

### Quy Tắc Tài Liệu

- Tài liệu public không được chứa secret, private key, token thật, credential
  production, email riêng, số điện thoại hoặc thông tin thanh toán thật.
- Screenshot phải thể hiện trạng thái thành công có dữ liệu, trừ khi tài liệu
  đang giải thích riêng một trạng thái rỗng hoặc lỗi.
- File kế hoạch private nằm trong các pattern đã ignore và không được commit.
- Tài liệu portfolio chính phải tách English và Vietnamese thành hai đường đọc
  riêng, không dùng bảng trộn hoặc heading kiểu gạch chéo.

<!-- INDEX-VI:END -->
