# Crab - Super App (Ride-Hailing & Food Delivery)

[![CI](https://github.com/JasonTM17/Crab_Mobile_Flutter/actions/workflows/ci.yml/badge.svg)](https://github.com/JasonTM17/Crab_Mobile_Flutter/actions/workflows/ci.yml)
[![Release](https://github.com/JasonTM17/Crab_Mobile_Flutter/actions/workflows/release.yml/badge.svg)](https://github.com/JasonTM17/Crab_Mobile_Flutter/actions/workflows/release.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Node.js](https://img.shields.io/badge/Node.js-20_LTS-green.svg)](https://nodejs.org/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-blue.svg)](https://flutter.dev/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED.svg)](https://www.docker.com/)
[![Kubernetes](https://img.shields.io/badge/K8s-Ready-326CE5.svg)](https://kubernetes.io/)

Crab is a production-engineering portfolio for a ride-hailing and food delivery super app: Flutter 3.x, NestJS 10, React 18, PostgreSQL, MongoDB, Redis, Socket.IO, Docker, and GitHub Actions CI/CD. The repository demonstrates mobile-first architecture, real-time communication, microservices boundaries, and full-stack delivery.

> **Learning Project** — This project was built for educational purposes to demonstrate full-stack mobile app development with microservices architecture. Feedback and contributions are welcome!

**Author:** Nguyễn Sơn  
**Email:** jasonbmt06@gmail.com  
**GitHub:** [@JasonTM17](https://github.com/JasonTM17)

---

## 30-Second Reviewer Brief

| Question | Answer |
|---|---|
| What is being demonstrated? | A super app combining ride-hailing and food delivery with real-time tracking, driver matching, and digital wallet. |
| What is the flagship feature? | Real-time ride tracking with animated driver markers, fare estimation, and driver matching with countdown timer. |
| What is production-shaped? | Service-owned databases, JWT auth with refresh tokens, Socket.IO with Redis adapter, rate limiting, Docker orchestration, CI/CD pipeline, GHCR image publishing, Kubernetes manifests, Prometheus monitoring. |
| What is not claimed? | This is not a live customer app. Google Maps API keys and payment gateways require real credentials for full functionality. |

## Repository Status

| Signal | Current |
|---|---|
| Latest release | v1.0.0 |
| Default branch | `main` |
| Mobile framework | Flutter 3.x + BLoC + GetIt + GoRouter |
| Backend framework | NestJS 10 + TypeORM + Mongoose |
| Web admin | React 18 + Vite + TailwindCSS + shadcn/ui |
| Container registry | `ghcr.io/jasontm17/crab-*` |
| Monitoring | Prometheus + Grafana + Loki |
| Orchestration | Docker Compose + Kubernetes |

## Documentation

| Document | Description |
|----------|-------------|
| [Architecture](docs/ARCHITECTURE.md) | System design, service catalog, communication patterns, security |
| [API Reference](docs/API.md) | REST API endpoints for all services with request/response examples |
| [OpenAPI Spec](docs/openapi.yaml) | Machine-readable OpenAPI 3.0 specification |
| [WebSocket Events](docs/WEBSOCKET_EVENTS.md) | Real-time event reference for ride, food, chat, notification |
| [Database Schema](docs/DATABASE.md) | PostgreSQL tables, MongoDB collections, Redis data structures |
| [Deployment](docs/DEPLOYMENT.md) | Docker setup, environment variables, scaling, CI/CD |
| [Testing](docs/TESTING.md) | Test strategy, examples, load testing, coverage requirements |
| [Docs Index](docs/INDEX.md) | Full documentation index with quick links |

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                         │
│              (BLoC + GetIt + GoRouter + Dio)                  │
└──────────────────────────┬──────────────────────────────────┘
                           │ REST + WebSocket
┌──────────────────────────▼──────────────────────────────────┐
│                    API Gateway (:3000)                        │
│         NestJS + JWT + Rate Limiting + Socket.IO              │
└──┬────┬────┬────┬────┬────┬────┬────┬────┬──────────────────┘
   │    │    │    │    │    │    │    │    │
   ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼
┌────┐┌────┐┌────┐┌────┐┌────┐┌────┐┌────┐┌────┐┌─────────┐
│Auth││User││Ride││Food││Pay ││Chat││Noti││Rate││Web Admin│
│3001││3002││3003││3004││3005││3006││3007││3008││  :5173  │
└────┘└────┘└────┘└────┘└────┘└────┘└────┘└────┘└─────────┘
   │    │    │    │    │    │    │    │
   ▼    ▼    ▼    ▼    ▼    ▼    ▼    ▼
┌─────────────┐  ┌──────────┐  ┌──────────┐
│ PostgreSQL  │  │ MongoDB  │  │  Redis   │
│  (TypeORM)  │  │(Mongoose)│  │ (Pub/Sub)│
└─────────────┘  └──────────┘  └──────────┘
         │              │             │
         ▼              ▼             ▼
┌─────────────────────────────────────────────┐
│        Prometheus + Grafana + Loki           │
│            (Monitoring Stack)                │
└─────────────────────────────────────────────┘
```

## Architecture and Operations Proof

| Layer | Implementation |
|---|---|
| Edge | API Gateway with JWT validation, CORS, rate limiting (100 req/min), request proxying |
| Core services | auth, user, ride, food, payment, chat, notification, rating (8 microservices) |
| Data ownership | PostgreSQL per relational service (TypeORM), MongoDB for chat/notifications (Mongoose) |
| Real-time | Socket.IO with Redis adapter, 4 namespaces (/ride, /food, /chat, /notification) |
| Auth | JWT access + refresh tokens, bcrypt hashing, token rotation, session management via Redis |
| Mobile | Flutter BLoC pattern, feature-first architecture, injectable DI, GoRouter navigation |
| Observability | Prometheus metrics, Grafana dashboards, Loki log aggregation, health endpoints |
| Testing | Jest unit/integration, Supertest E2E, k6 load testing, testcontainers |
| Delivery | Multi-stage Docker builds, GitHub Actions CI/CD, GHCR publishing, Kubernetes manifests |
| Security | Rate limiting, input validation, CORS, Helmet.js, bcrypt, token rotation |

## Service Catalog

| Service | Port | Database | Transport | Documentation |
|---------|------|----------|-----------|---------------|
| Gateway | 3000 | Redis (cache) | HTTP + WebSocket | [README](apps/backend/gateway/README.md) |
| Auth | 3001 | PostgreSQL | HTTP | [README](apps/backend/auth-service/README.md) |
| User | 3002 | PostgreSQL | HTTP | [README](apps/backend/user-service/README.md) |
| Ride | 3003 | PostgreSQL + Redis | HTTP + Socket.IO | [README](apps/backend/ride-service/README.md) |
| Food | 3004 | PostgreSQL | HTTP + Socket.IO | [README](apps/backend/food-service/README.md) |
| Payment | 3005 | PostgreSQL | HTTP | [README](apps/backend/payment-service/README.md) |
| Chat | 3006 | MongoDB | HTTP + Socket.IO | [README](apps/backend/chat-service/README.md) |
| Notification | 3007 | MongoDB + Redis | HTTP + Socket.IO | [README](apps/backend/notification-service/README.md) |
| Rating | 3008 | PostgreSQL | HTTP | [README](apps/backend/rating-service/README.md) |
| Web Admin | 5173/80 | - | HTTP | [README](apps/web-admin/README.md) |

## Tech Stack

### Mobile (Flutter)
| Category | Technology |
|----------|------------|
| Framework | Flutter 3.x |
| State Management | flutter_bloc + equatable |
| DI | get_it + injectable |
| Navigation | go_router |
| Networking | dio + socket_io_client |
| Maps | google_maps_flutter |
| Storage | flutter_secure_storage |
| Serialization | json_serializable |

### Backend (NestJS)
| Category | Technology |
|----------|------------|
| Framework | NestJS 10 |
| Database | PostgreSQL (TypeORM) + MongoDB (Mongoose) |
| Cache/PubSub | Redis |
| Real-time | Socket.IO + Redis adapter |
| Auth | JWT + Passport + bcrypt |
| Validation | class-validator + class-transformer |
| Build | pnpm workspaces + Turborepo |
| Testing | Jest + Supertest + k6 + testcontainers |

### Web Admin (React)
| Category | Technology |
|----------|------------|
| Framework | React 18 + TypeScript |
| Build | Vite |
| Styling | TailwindCSS + shadcn/ui |
| Charts | Recharts |
| State | TanStack Query |
| Routing | React Router v6 |

### Infrastructure
| Category | Technology |
|----------|------------|
| Containers | Docker + Docker Compose |
| Orchestration | Kubernetes (HPA, Ingress, Secrets) |
| CI/CD | GitHub Actions + GHCR |
| Monitoring | Prometheus + Grafana + Loki |
| Code Quality | ESLint + Prettier + Husky + lint-staged |
| API Spec | OpenAPI 3.0 |

## Features

### Ride-Hailing
- Real-time driver tracking with animated markers and camera follow
- Location search with recent history (HCMC landmarks)
- Fare estimation before booking (distance-based VND pricing)
- Driver matching with 15-second countdown timer
- Driver mode: online/offline toggle, ride request cards
- Ride status progression: searching → matched → pickup → in-progress → completed
- Navigation view for drivers with pickup/dropoff phases

### Food Delivery
- Restaurant browsing with category filters
- Menu with item customization and add-ons
- Cart management with quantity controls
- Order tracking with animated status stepper
- Restaurant ratings and review integration

### Shared Features
- JWT authentication with token refresh and secure storage
- Real-time notifications via Socket.IO
- In-app chat between rider and driver
- Digital wallet with top-up and transaction history
- Rating system with tags and reply support
- Push notification preferences

## Project Structure

```
Crab_Mobile_Flutter/
├── apps/
│   ├── mobile/                  # Flutter mobile app
│   │   ├── lib/
│   │   │   ├── core/            # DI, networking, routing, theme, constants
│   │   │   ├── features/        # Feature modules (auth, ride, food, chat, etc.)
│   │   │   └── shared/          # Shared models, utils, widgets
│   │   └── pubspec.yaml
│   ├── backend/                 # NestJS microservices
│   │   ├── gateway/             # API Gateway (:3000)
│   │   ├── auth-service/        # Authentication (:3001)
│   │   ├── user-service/        # User management (:3002)
│   │   ├── ride-service/        # Ride-hailing (:3003)
│   │   ├── food-service/        # Food delivery (:3004)
│   │   ├── payment-service/     # Payments (:3005)
│   │   ├── chat-service/        # Real-time chat (:3006)
│   │   ├── notification-service/# Notifications (:3007)
│   │   ├── rating-service/      # Ratings (:3008)
│   │   └── shared/              # Shared guards, decorators, utils
│   └── web-admin/               # React admin dashboard
├── packages/
│   ├── common-types/            # Shared TypeScript interfaces
│   └── socket-events/           # Socket.IO event type definitions
├── docs/                        # Technical documentation
├── docker/                      # Dev Docker configs
├── k8s/                         # Kubernetes manifests
├── monitoring/                  # Prometheus + Grafana stack
├── scripts/                     # DB migration & seed scripts
├── test/                        # E2E tests & load tests
├── docker-compose.yml           # Full stack orchestration
├── .github/workflows/           # CI/CD pipelines
├── turbo.json                   # Turborepo config
├── pnpm-workspace.yaml          # pnpm workspaces
└── Makefile                     # Developer shortcuts
```

## Quick Start

### Docker (Recommended)

```bash
git clone https://github.com/JasonTM17/Crab_Mobile_Flutter.git
cd Crab_Mobile_Flutter
cp .env.example .env
docker compose up -d
```

| Service | URL |
|---------|-----|
| API Gateway | http://localhost:3000 |
| Web Admin | http://localhost:8080 |
| Grafana | http://localhost:3100 |
| Prometheus | http://localhost:9090 |
| PostgreSQL | localhost:5432 |
| MongoDB | localhost:27017 |
| Redis | localhost:6379 |

### One-Command Setup

```bash
make setup    # Installs deps, starts DBs, runs migrations, seeds data
make dev      # Starts all services in dev mode
```

### Manual Setup

```bash
# Backend
pnpm install
pnpm db:migrate
pnpm db:seed
pnpm dev

# Web Admin
pnpm --filter @crab/web-admin dev

# Flutter Mobile
cd apps/mobile
flutter pub get
flutter run
```

## Demo Accounts

| Role | Email | Password |
|------|-------|----------|
| Admin | `admin@crab.app` | `Admin123!` |
| Rider | `rider@crab.app` | `User123!` |
| Driver | `driver@crab.app` | `Driver123!` |
| Restaurant | `restaurant@crab.app` | `User123!` |

## Socket.IO Namespaces

| Namespace | Events | Purpose |
|-----------|--------|---------|
| `/ride` | `ride:request`, `ride:accepted`, `ride:status_changed`, `driver:location` | Real-time ride tracking |
| `/food` | `order:status_changed`, `order:driver_assigned`, `order:driver_location` | Order delivery tracking |
| `/chat` | `message:send`, `message:new`, `message:typing` | In-app messaging |
| `/notification` | `notification:new`, `notification:badge_update` | Push delivery |

See [WebSocket Events Reference](docs/WEBSOCKET_EVENTS.md) for full event documentation.

## Container Images

All services publish to GitHub Container Registry on release:

```bash
docker pull ghcr.io/jasontm17/crab-gateway:latest
docker pull ghcr.io/jasontm17/crab-auth-service:latest
docker pull ghcr.io/jasontm17/crab-user-service:latest
docker pull ghcr.io/jasontm17/crab-ride-service:latest
docker pull ghcr.io/jasontm17/crab-food-service:latest
docker pull ghcr.io/jasontm17/crab-payment-service:latest
docker pull ghcr.io/jasontm17/crab-chat-service:latest
docker pull ghcr.io/jasontm17/crab-notification-service:latest
docker pull ghcr.io/jasontm17/crab-rating-service:latest
docker pull ghcr.io/jasontm17/crab-web-admin:latest
```

## Testing

```bash
# Unit tests
pnpm test

# E2E tests (requires running services)
pnpm test:e2e

# Load tests (requires k6)
pnpm test:load          # Full flow
pnpm test:load:rate     # Rate limiting verification
pnpm test:load:ride     # Ride service stress test

# Coverage
pnpm test:cov
```

See [Testing Guide](docs/TESTING.md) for full test strategy and examples.

## Kubernetes Deployment

```bash
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/services/
kubectl apply -f k8s/ingress.yaml
kubectl get pods -n crab
```

See [Kubernetes README](k8s/README.md) for full deployment guide.

## Monitoring

```bash
make monitoring-up    # Start Prometheus + Grafana + Loki
# Grafana: http://localhost:3100 (admin/crab_admin)
# Prometheus: http://localhost:9090
```

See [Monitoring README](monitoring/README.md) for alert configuration and dashboards.

## Screenshots

| Home Screen | Ride Booking | Driver Matching |
|:-----------:|:------------:|:---------------:|
| Service selection with wallet balance | Map with pickup/dropoff and fare estimate | Animated searching with cancel option |

| Driver Mode | Food Ordering | Order Tracking |
|:-----------:|:-------------:|:--------------:|
| Online/offline toggle with ride requests | Restaurant list with category filters | Real-time status stepper |

| Location Search | Tracking Map | Admin Dashboard |
|:---------------:|:------------:|:---------------:|
| Recent locations with search | Animated driver marker with ETA | Analytics with user management |

## Verification

```bash
# Full stack health check
make health

# Or manually
curl http://localhost:3000/health
curl http://localhost:3001/health
# ... all services on ports 3000-3008
```

## Honest Scope

Crab is a production-engineering portfolio, not a claim of live customer traffic. It does not claim real payment processing, a production Google Maps API key, or real customer data. The architecture demonstrates patterns suitable for production but requires real credentials and infrastructure for deployment.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for development setup and guidelines.

## Security

See [SECURITY.md](SECURITY.md) for security policy and vulnerability reporting.

## License

MIT License - see [LICENSE](LICENSE) for details.
