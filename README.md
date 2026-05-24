<!-- Back-to-top anchor -->
<a id="readme-top"></a>

---

<!-- BADGES -->
[![CI][ci-badge]][ci-url]
[![Docker][docker-badge]][docker-url]
[![License][license-badge]][license-url]
[![Stars][stars-badge]][stars-url]
[![Issues][issues-badge]][issues-url]

<!-- LOGO + TITLE -->
<br />
<div align="center">
  <a href="https://github.com/JasonTM17/Crab_Mobile_Flutter">
    <img src="docs/assets/logo.png" alt="Crab Logo" width="120" height="120">
  </a>

  <h1 align="center">Crab Super App</h1>

  <p align="center">
    A ride-hailing and food delivery super app built with Flutter, React, and NestJS microservices
    <br />
    <a href="docs/"><strong>Explore the docs »</strong></a>
    <br /><br />
    <a href="#screenshots">View Screenshots</a>
    &middot;
    <a href="https://github.com/JasonTM17/Crab_Mobile_Flutter/issues/new?labels=bug">Report Bug</a>
    &middot;
    <a href="https://github.com/JasonTM17/Crab_Mobile_Flutter/issues/new?labels=enhancement">Request Feature</a>
  </p>
</div>

---

<!-- 30-SECOND REVIEWER BRIEF -->
## At a Glance

| Aspect | Details |
|--------|---------|
| **What** | Super app combining ride-hailing + food delivery (like Grab/ShopeeFood/Be) |
| **Mobile** | Flutter 3.x with BLoC, GetIt DI, GoRouter |
| **Web Admin** | React 18 + TypeScript + Vite + TailwindCSS + shadcn/ui |
| **Backend** | NestJS microservices (Auth, User, Ride, Food, Payment, Chat, Notification) |
| **Realtime** | Socket.IO with Redis adapter for horizontal scaling |
| **Database** | PostgreSQL + MongoDB (geospatial) + Redis (cache/pub-sub) |
| **Storage** | MinIO (S3-compatible) |
| **Status** | Core phases complete · release hardening in progress |

---

## Table of Contents

<details>
<summary>Click to expand</summary>

- [At a Glance](#at-a-glance)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Features](#features)
- [Screenshots](#screenshots)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [API Documentation](#api-documentation)
- [Documentation](#documentation)
- [Docker Services](#docker-services)
- [Development](#development)
- [Roadmap](#roadmap)
- [Contributing](#contributing)
- [License](#license)

</details>

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      CLIENT LAYER                            │
├──────────────────────┬──────────────────────────────────────┤
│  Flutter Mobile App  │  React Admin Dashboard               │
│  (iOS + Android)     │  (Vite + TailwindCSS + shadcn/ui)   │
└──────────┬───────────┴──────────────┬───────────────────────┘
           │         HTTPS/WSS        │
           ▼                          ▼
┌─────────────────────────────────────────────────────────────┐
│              API GATEWAY (NestJS + Socket.IO)                │
│         Rate Limiting · JWT Auth · Redis Adapter            │
└──────────┬──────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────┐
│                   MICROSERVICES LAYER                        │
├─────────┬─────────┬─────────┬─────────┬─────────┬─────────┤
│  Auth   │  User   │  Ride   │  Food   │ Payment │  Chat   │
│ Service │ Service │ Service │ Service │ Service │ Service │
└────┬────┴────┬────┴────┬────┴────┬────┴────┬────┴────┬────┘
     │         │         │         │         │         │
     ▼         ▼         ▼         ▼         ▼         ▼
┌─────────────────────────────────────────────────────────────┐
│                    DATA LAYER                                │
├──────────────┬──────────────┬──────────────┬────────────────┤
│  PostgreSQL  │   MongoDB    │    Redis     │     MinIO      │
│  (ACID Data) │ (Geospatial) │(Cache/PubSub)│ (File Storage) │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Tech Stack

### Backend
| Technology | Purpose |
|-----------|---------|
| NestJS + TypeScript | Microservice framework |
| Socket.IO + Redis Adapter | Realtime communication, horizontal scaling |
| TypeORM | PostgreSQL ORM |
| Mongoose | MongoDB ODM (geospatial) |
| BullMQ | Job queue and scheduling |
| Passport + JWT | Authentication |
| class-validator | DTO validation |

### Mobile
| Technology | Purpose |
|-----------|---------|
| Flutter 3.x | Cross-platform mobile |
| flutter_bloc | State management |
| GetIt + Injectable | Dependency injection |
| GoRouter | Declarative routing |
| Dio | HTTP client with interceptors |
| socket_io_client | Realtime connection |

### Web Admin
| Technology | Purpose |
|-----------|---------|
| React 18 + TypeScript | UI framework |
| Vite | Build tool |
| TailwindCSS + shadcn/ui | Styling + components |
| React Query | Server state management |
| React Router v6 | Client routing |

### Infrastructure
| Technology | Purpose |
|-----------|---------|
| PostgreSQL 15 | Transactional data |
| MongoDB 7 | Geospatial queries (driver locations) |
| Redis 7 | Cache, sessions, pub/sub, rate limiting |
| MinIO | S3-compatible file storage |
| Docker Compose | Development environment |
| Turborepo + pnpm | Monorepo management |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Features

### Ride-Hailing
- Real-time GPS tracking (driver → server → rider, 2s interval)
- Intelligent driver matching (nearest + rating weighted)
- Surge pricing based on demand
- Ride state machine: REQUESTED → MATCHED → PICKUP → IN_PROGRESS → COMPLETED

### Food Delivery
- Location-based restaurant search (5km radius)
- Menu management with categories, variants, addons
- Order tracking with delivery GPS
- Order state machine: PLACED → CONFIRMED → PREPARING → READY → PICKED_UP → DELIVERED

### Payment & Wallet
- Digital wallet with top-up/withdraw
- Multiple payment methods (wallet, COD, bank transfer)
- Double-entry ledger for transaction integrity
- Promo codes and discount engine

### Chat & Notifications
- 1-to-1 realtime messaging (rider↔driver, user↔merchant)
- Typing indicators and read receipts
- Push notifications via FCM
- In-app notification center

### Admin Dashboard
- User/Driver/Merchant management
- Ride and order monitoring
- Transaction and payout management
- Analytics dashboard with stat cards

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Screenshots

Captured at 1440x900 viewport from the production Vite build via Playwright MCP. See [`docs/screenshots/README.md`](docs/screenshots/README.md) for the full gallery.

### Web Admin Dashboard

| Screen | Description |
|--------|-------------|
| ![Login](docs/screenshots/admin-01-login.png) | Phone/email login form with shadcn/ui styling, JWT auth with refresh-token rotation |
| ![Dashboard](docs/screenshots/admin-02-dashboard.png) | KPI cards (users, rides, revenue, orders) and full sidebar navigation |
| ![Users](docs/screenshots/admin-03-users.png) | Paginated user table with search, status badges, role tags |
| ![Drivers](docs/screenshots/admin-04-drivers.png) | Driver verification queue with license info, vehicle details, approve/reject actions |
| ![Rides](docs/screenshots/admin-05-rides.png) | Real-time rides monitoring with rider/driver IDs, status, fare, distance |
| ![Orders](docs/screenshots/admin-06-orders.png) | Food delivery orders by restaurant with full status timeline |

### Mobile (Flutter)

Mobile screenshots can be captured via `flutter screenshot` from a running emulator/device. The Flutter app implements:

- Auth flow: phone/email login, OTP verification with auto-advance and 60s resend timer, registration
- Home: greeting, wallet card, 8-service grid (bike, car, food, mart, express, pay, promos)
- Ride: pickup/dropoff selection, fare comparison across vehicle types, real-time tracking with chat/cancel/SOS
- Wallet: balance card, top-up sheet, transaction history
- Food: restaurant list, categories, popular nearby
- Profile: avatar, settings, theme, language, logout

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Getting Started

### Prerequisites

- Node.js 20+
- pnpm 10+
- Flutter 3.x (for mobile development)
- Docker & Docker Compose

### Installation

1. Clone the repository
```bash
git clone https://github.com/JasonTM17/Crab_Mobile_Flutter.git
cd Crab_Mobile_Flutter
```

2. Install dependencies
```bash
pnpm install
```

3. Start infrastructure services
```bash
docker compose -f docker-compose.dev.yml up -d
```

4. Copy environment files
```bash
cp .env.example .env
cp apps/backend/gateway/.env.example apps/backend/gateway/.env
```

5. Start all services in development mode
```bash
pnpm dev
```

6. For Flutter mobile app
```bash
cd apps/mobile
flutter pub get
flutter run
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Project Structure

```
crab/
├── apps/
│   ├── mobile/                    # Flutter mobile app
│   │   ├── lib/
│   │   │   ├── core/             # DI, network, router, theme
│   │   │   ├── features/         # auth, home, ride, food, chat, payment, notifications, profile
│   │   │   └── shared/           # models, widgets, utils
│   │   └── pubspec.yaml
│   ├── web-admin/                 # React admin dashboard
│   │   ├── src/
│   │   │   ├── components/       # UI + layout components
│   │   │   ├── pages/            # Login, Dashboard
│   │   │   ├── hooks/            # useAuth, etc.
│   │   │   ├── lib/              # axios, utils
│   │   │   └── services/         # API services
│   │   └── package.json
│   └── backend/
│       ├── gateway/               # API Gateway + Socket.IO
│       ├── auth-service/          # JWT authentication
│       ├── user-service/          # Profile CRUD + avatar
│       ├── ride-service/          # Ride-hailing + GPS tracking
│       ├── food-service/          # Restaurant + food ordering
│       ├── payment-service/       # Wallet + transactions
│       ├── chat-service/          # Realtime messaging
│       └── notification-service/  # Push notifications + FCM
├── packages/
│   ├── socket-events/             # Shared Socket.IO event types
│   └── common-types/              # Shared enums, DTOs, interfaces
├── docker/
│   └── docker-compose.dev.yml     # Dev infrastructure
├── docs/                          # Documentation
├── turbo.json                     # Turborepo pipeline
└── pnpm-workspace.yaml            # Workspace config
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## API Documentation

### Auth Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Register new user |
| POST | `/api/v1/auth/login` | Login, returns JWT + refresh token |
| POST | `/api/v1/auth/refresh` | Rotate refresh token |
| POST | `/api/v1/auth/logout` | Invalidate refresh token |

### User Service

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/v1/users/:id` | Get user profile |
| PATCH | `/api/v1/users/:id` | Update profile |
| POST | `/api/v1/users/:id/avatar` | Upload avatar (JPEG/PNG/WebP, 5MB max) |

### Socket.IO Namespaces

| Namespace | Events | Description |
|-----------|--------|-------------|
| `/ride` | ride:request, ride:location, ride:status | Ride-hailing realtime |
| `/food` | order:placed, order:status, order:tracking | Food delivery tracking |
| `/chat` | chat:message, chat:typing, chat:read | Realtime messaging |
| `/notification` | notification:new, notification:read | Push notifications |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Documentation

Full guides live under [`docs/`](docs/). Start with the index for an annotated tour.

| Document | Purpose |
|----------|---------|
| [docs/INDEX.md](docs/INDEX.md) | Documentation entry point and reading order |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture, service boundaries, data flow |
| [docs/API.md](docs/API.md) | REST API reference across all services |
| [docs/MOBILE.md](docs/MOBILE.md) | Flutter mobile app architecture and feature catalogue |
| [docs/ADMIN.md](docs/ADMIN.md) | React admin dashboard pages, auth flow, theme |
| [docs/REALTIME.md](docs/REALTIME.md) | Socket.IO realtime architecture and Redis adapter |
| [docs/WEBSOCKET_EVENTS.md](docs/WEBSOCKET_EVENTS.md) | Per-namespace event catalog and payload schemas |
| [docs/RIDE_MATCHING.md](docs/RIDE_MATCHING.md) | Driver matching algorithm, surge pricing, state machine |
| [docs/FOOD_DELIVERY.md](docs/FOOD_DELIVERY.md) | Restaurant search, ordering, delivery tracking flow |
| [docs/RATING.md](docs/RATING.md) | Rating model, aggregate flow, API surface |
| [docs/DATABASE.md](docs/DATABASE.md) | PostgreSQL + MongoDB schema and indexes |
| [docs/DEPLOYMENT.md](docs/DEPLOYMENT.md) | Docker Compose and Kubernetes deployment guide |
| [docs/OBSERVABILITY.md](docs/OBSERVABILITY.md) | Logs, metrics, traces, monitoring stack |
| [docs/TESTING.md](docs/TESTING.md) | Unit, integration, and load test strategy |
| [AGENTS.md](AGENTS.md) | Rules AI coding agents must follow when contributing |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Docker Services

| Service | Port | Image |
|---------|------|-------|
| PostgreSQL 16 | 5432 | `postgres:16-alpine` |
| MongoDB 7 | 27017 | `mongo:7` |
| Redis 7 | 6379 | `redis:7-alpine` |
| MinIO | 9000/9001 | `minio/minio` |
| API Gateway | 3000 | `nguyenson1710/crab-mobile-gateway` |
| Auth Service | 3001 | `nguyenson1710/crab-mobile-auth-service` |
| User Service | 3002 | `nguyenson1710/crab-mobile-user-service` |
| Ride Service | 3003 | `nguyenson1710/crab-mobile-ride-service` |
| Food Service | 3004 | `nguyenson1710/crab-mobile-food-service` |
| Payment Service | 3005 | `nguyenson1710/crab-mobile-payment-service` |
| Chat Service | 3006 | `nguyenson1710/crab-mobile-chat-service` |
| Notification Service | 3007 | `nguyenson1710/crab-mobile-notification-service` |
| Rating Service | 3008 | `nguyenson1710/crab-mobile-rating-service` |

In hardened local/prod compose, the gateway is the intended public entrypoint. Internal service ports above are service/container ports, not ports that must remain host-exposed.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Development

### Available Scripts

```bash
pnpm dev          # Start all services in dev mode
pnpm build        # Build all packages and services
pnpm lint         # Lint all packages
pnpm test         # Run all tests
```

### Quality Gates

| Check | Command | Expected |
|-------|---------|----------|
| TypeScript | `pnpm build` | Zero errors |
| Lint | `pnpm lint` | Zero errors |
| Tests | `pnpm test` | All passing |
| Flutter analyze | `flutter analyze` | Zero issues |
| Docker config | `docker compose -f docker-compose.prod.yml config` | Valid config |

### Release

Release documentation is maintained in [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

Quick summary:

- GitHub releases are created by `.github/workflows/release.yml` on tags like `v1.2.3`
- Docker images are published by `.github/workflows/docker-publish.yml`
- Public images use `nguyenson1710/crab-mobile-<service>` naming
- CI now enforces lint, build, Flutter checks, backend tests, and `contract:check`
- Mobile release builds require secure HTTPS/WSS endpoints and local/CI release signing material

Recommended release commands:

```bash
pnpm -w run lint
pnpm -w run build
pnpm -w run contract:check
pnpm -w run test
cd apps/mobile && flutter analyze && flutter test
```

Then tag the release:

```bash
git tag v1.2.3
git push origin v1.2.3
```

See `docs/DEPLOYMENT.md` for required GitHub secrets, Docker Hub naming, compose/k8s notes, mobile signing details, and troubleshooting.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Roadmap

- [x] **Phase 1**: Foundation (Monorepo, Auth, User, Gateway, Mobile, Admin)
- [x] **Phase 2**: Ride-Hailing Core (GPS tracking, driver matching, fare calculation)
- [x] **Phase 3**: Food Delivery (Restaurant listing, ordering, delivery tracking)
- [x] **Phase 4**: Payment & Wallet (Digital wallet, transactions, payouts)
- [x] **Phase 5**: Chat & Notifications (Realtime messaging, push notifications)
- [x] **Phase 6**: Rating, Review & Polish (Rating system, search, performance)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/amazing-feature`)
3. Commit your Changes (`git commit -m 'feat: add amazing feature'`)
4. Push to the Branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## License

Distributed under the MIT License. See `LICENSE` for more information.

---

<div align="center">
  <p>Built with dedication by <a href="https://github.com/JasonTM17">Nguyễn Sơn</a></p>
  <p><em>This is a learning project. Author: Nguyễn Sơn (jasonbmt06@gmail.com). Feedback and suggestions are welcome!</em></p>
</div>

<!-- BADGE REFERENCE LINKS -->
[ci-badge]: https://img.shields.io/github/actions/workflow/status/JasonTM17/Crab_Mobile_Flutter/ci.yml?style=for-the-badge&label=CI
[ci-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/actions
[docker-badge]: https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white
[docker-url]: docs/DEPLOYMENT.md
[license-badge]: https://img.shields.io/github/license/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[license-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/blob/main/LICENSE
[stars-badge]: https://img.shields.io/github/stars/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[stars-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/stargazers
[issues-badge]: https://img.shields.io/github/issues/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[issues-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/issues
[security-badge]: https://img.shields.io/badge/Security-Hardened-green?style=for-the-badge&logo=shield
[security-url]: SECURITY.md
