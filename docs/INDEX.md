# Documentation Index

## Crab Super App — Technical Documentation

This index organizes the repository documentation by system area so reviewers can quickly inspect architecture, API contracts, mobile/web clients, deployment, testing, and operations.

Trang này sắp xếp tài liệu theo từng mảng hệ thống để người xem nhanh chóng kiểm tra kiến trúc, API contract, mobile/web clients, deployment, testing và vận hành.

### Architecture & Reference

Core system design and contract documents.

Tài liệu cốt lõi về thiết kế hệ thống và contract.

| Document | Description |
|----------|-------------|
| [Architecture](./ARCHITECTURE.md) | System design, service catalog, communication patterns, security |
| [API Reference](./API.md) | REST API endpoints for all services with request/response examples |
| [OpenAPI Spec](./openapi.yaml) | Canonical OpenAPI 3.1 contract used by client generators |
| [Database Schema](./DATABASE.md) | PostgreSQL tables, MongoDB collections, Redis data structures |

### Realtime & Domain Flows

Domain-specific flows for rides, food delivery, ratings, and realtime events.

Các luồng nghiệp vụ cho gọi xe, giao đồ ăn, rating và realtime events.

| Document | Description |
|----------|-------------|
| [Realtime](./REALTIME.md) | Socket.IO topology, namespaces, lifecycles, replay strategy |
| [WebSocket Events](./WEBSOCKET_EVENTS.md) | Wire-level event reference for ride, food, chat, notification |
| [Ride Matching](./RIDE_MATCHING.md) | Queue, scoring, surge, re-match flow, eligibility |
| [Food Delivery](./FOOD_DELIVERY.md) | Order state machine, dispatch, cancellation, restaurant ops |
| [Rating Service](./RATING.md) | Rating model, aggregate update flow, API surface |

### Apps & Operations

Application surfaces, deployment guidance, observability, and test strategy.

Tài liệu về bề mặt ứng dụng, triển khai, observability và chiến lược test.

| Document | Description |
|----------|-------------|
| [Mobile App](./MOBILE.md) | Flutter app architecture, BLoC, DI, routing, feature catalogue |
| [Admin Dashboard](./ADMIN.md) | React admin pages, auth flow, theme, build commands |
| [Deployment](./DEPLOYMENT.md) | Docker setup, environment variables, scaling, CI/CD |
| [Observability](./OBSERVABILITY.md) | Logs, metrics, traces, monitoring stack |
| [Testing](./TESTING.md) | Test strategy, examples, load testing, coverage requirements |

### Architecture Decisions

| Document | Description |
|----------|-------------|
| [ADR Template](./adr/template.md) | Standard template for new architecture decision records |
| [ADR 0001](./adr/0001-record-architecture-decisions.md) | Establishes the ADR process for this repository |

### Repo-Level Files

| Document | Description |
|----------|-------------|
| [README](../README.md) | Project overview and quick start |
| [Changelog](../CHANGELOG.md) | Versioned change history (Keep a Changelog) |
| [Contributing](../CONTRIBUTING.md) | Setup, branching, PR rules |
| [Code of Conduct](../CODE_OF_CONDUCT.md) | Community standards |
| [Security](../SECURITY.md) | How to report vulnerabilities |

## Canonical Constants

Shared runtime constants used across clients, services, and documentation.

Các hằng số runtime dùng chung giữa client, service và tài liệu.

- **API base URL (dev)**: `http://localhost:3000/api/v1`
- **API base URL (web-admin prod default)**: same-origin `/api/v1`
- **WebSocket URL (dev)**: `ws://localhost:3000/{namespace}` (`ride`, `food`, `chat`, `notification`)
- **Health check**: gateway `GET /health`; services expose `GET /health`, and the shared observability module also provides `GET /healthz` and `GET /readyz` where wired

### Ride Status Vocabulary
`REQUESTED` → `MATCHED` → `PICKUP` → `IN_PROGRESS` → `COMPLETED` (any state → `CANCELLED`)

### Order Status Vocabulary
`PLACED` → `CONFIRMED` → `PREPARING` → `READY` → `PICKED_UP` → `DELIVERED` (any non-terminal state → `CANCELLED`)

## Project Structure

```
Crab_Mobile_Flutter/
├── apps/
│   ├── backend/          # NestJS microservices (9 services)
│   ├── mobile/           # Flutter mobile app
│   └── web-admin/        # React admin dashboard
├── packages/
│   ├── common-types/     # Shared TypeScript interfaces and enums
│   └── socket-events/    # Socket.IO event type definitions
├── docker/               # Docker dev configs (compose lives at repo root)
├── docs/                 # This documentation
├── infra/                # Kubernetes manifests, IaC
├── monitoring/           # Prometheus/Loki/Grafana configs
└── .github/workflows/    # CI/CD pipelines
```

## Service Ports

| Service | Port | Healthz |
|---------|------|---------|
| Gateway | 3000 | `/health` |
| Auth | 3001 | `/healthz` |
| User | 3002 | `/healthz` |
| Ride | 3003 | `/healthz` |
| Food | 3004 | `/healthz` |
| Payment | 3005 | `/healthz` |
| Chat | 3006 | `/healthz` |
| Notification | 3007 | `/healthz` |
| Rating | 3008 | `/healthz` |
| Web Admin | 8080 | `/` |
| PostgreSQL | 5432 | – |
| MongoDB | 27017 | – |
| Redis | 6379 | – |

Gateway prefixes every downstream call with `/api/v1`. Service ports above are reachable directly only inside the Docker network.
