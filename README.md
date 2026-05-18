<!-- Back-to-top anchor -->
<a id="readme-top"></a>

English | [Tiếng Việt](docs/README_VI.md)

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
| **Status** | Phase 1 Complete - Foundation |

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

> Screenshots and GIFs will be added as features are completed.

| Screen | Description |
|--------|-------------|
| ![Login](docs/screenshots/login.png) | Mobile login screen with email/phone authentication |
| ![Home](docs/screenshots/home.png) | Home screen with ride and food service cards |
| ![Admin](docs/screenshots/admin-dashboard.png) | Admin dashboard with analytics overview |
| ![Tracking](docs/gifs/ride-tracking.gif) | Real-time ride tracking with driver movement |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Getting Started

### Prerequisites

- Node.js 20+
- pnpm 8+
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
docker compose -f docker/docker-compose.dev.yml up -d
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
│   │   │   ├── features/         # auth, home, ride, food, chat, profile
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
│       ├── ride-service/          # (Phase 2)
│       ├── food-service/          # (Phase 3)
│       ├── payment-service/       # (Phase 4)
│       └── chat-service/          # (Phase 5)
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

## Docker Services

| Service | Port | Image |
|---------|------|-------|
| PostgreSQL 15 | 5432 | `postgres:15-alpine` |
| MongoDB 7 | 27017 | `mongo:7` |
| Redis 7 | 6379 | `redis:7-alpine` |
| MinIO | 9000/9001 | `minio/minio` |
| API Gateway | 3000 | `ghcr.io/jasontm17/crab-gateway` |
| Auth Service | 3001 | `ghcr.io/jasontm17/crab-auth-service` |
| User Service | 3002 | `ghcr.io/jasontm17/crab-user-service` |

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
| Lint | `pnpm lint` | Zero warnings |
| Tests | `pnpm test` | All passing |
| Docker | `docker compose up` | All healthy |

<p align="right">(<a href="#readme-top">back to top</a>)</p>

---

## Roadmap

- [x] **Phase 1**: Foundation (Monorepo, Auth, User, Gateway, Mobile, Admin)
- [ ] **Phase 2**: Ride-Hailing Core (GPS tracking, driver matching, fare calculation)
- [ ] **Phase 3**: Food Delivery (Restaurant listing, ordering, delivery tracking)
- [ ] **Phase 4**: Payment & Wallet (Digital wallet, transactions, payouts)
- [ ] **Phase 5**: Chat & Notifications (Realtime messaging, push notifications)
- [ ] **Phase 6**: Rating, Review & Polish (Rating system, search, performance)

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
  <p>Built with dedication by <a href="https://github.com/JasonTM17">JasonTM17</a></p>
</div>

<!-- BADGE REFERENCE LINKS -->
[ci-badge]: https://img.shields.io/github/actions/workflow/status/JasonTM17/Crab_Mobile_Flutter/ci.yml?style=for-the-badge&label=CI
[ci-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/actions
[docker-badge]: https://img.shields.io/badge/Docker-Ready-2496ED?style=for-the-badge&logo=docker&logoColor=white
[docker-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/pkgs/container/crab-gateway
[license-badge]: https://img.shields.io/github/license/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[license-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/blob/main/LICENSE
[contributors-badge]: https://img.shields.io/github/contributors/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[contributors-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/graphs/contributors
[stars-badge]: https://img.shields.io/github/stars/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[stars-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/stargazers
[issues-badge]: https://img.shields.io/github/issues/JasonTM17/Crab_Mobile_Flutter?style=for-the-badge
[issues-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/issues
[security-badge]: https://img.shields.io/badge/Security-Hardened-green?style=for-the-badge&logo=shield
[security-url]: https://github.com/JasonTM17/Crab_Mobile_Flutter/security
