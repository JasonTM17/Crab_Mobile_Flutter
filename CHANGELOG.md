# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Auth Service: OTP verification, phone-based login, account lockout, device management, Redis-backed sessions
- User Service: profiles, addresses, driver/merchant verification with document upload tracking
- Gateway: Redis Socket.IO adapter for multi-instance scaling, circuit breaker pattern, three-tier rate limiting
- Ride Service: multi-vehicle pricing (BIKE/CAR_4/CAR_7/PREMIUM), ride scheduling, SOS button, driver stats
- Payment Service: wallet with pessimistic-write locks, transactions ledger, promo engine
- Food Service: restaurants with location search, menus with categories, transactional order checkout
- Chat Service: rooms with unread tracking, messages with read receipts, edit/delete
- Notification Service: push notifications, in-app inbox, per-user preferences with FCM tokens
- Rating Service: ratings with denormalized aggregate distribution
- Mobile (Flutter): full auth flow with OTP, ride booking with fare comparison, wallet, food, profile
- Web Admin: pages for users, drivers verification, rides, orders, promos, broadcasts
- Production Docker Compose with monitoring stack (Prometheus + Grafana + Loki + Promtail + cAdvisor)
- Kubernetes manifests with HPA, StatefulSets for data layer, nginx ingress
- GitHub Actions CI matrix + Docker Hub publish workflow

### Infrastructure
- Multi-stage Dockerfiles for all 9 backend services + web-admin (alpine, non-root, healthcheck)
- nginx reverse proxy with rate-limit zones (api 30r/s, auth 10r/min, conn 100/IP)
- WebSocket support with 24h idle timeout
- HPA scaling: gateway 3-20, ride 3-15, others 2-8 replicas

## [0.1.0] - 2026-05-15

### Added
- Initial monorepo scaffolding with pnpm workspaces and Turborepo
- Basic NestJS microservice skeletons
- Flutter mobile app skeleton with BLoC architecture
- React admin skeleton with Vite + TailwindCSS
- Docker Compose dev stack (Postgres, MongoDB, Redis, MinIO)

[Unreleased]: https://github.com/JasonTM17/Crab_Mobile_Flutter/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/JasonTM17/Crab_Mobile_Flutter/releases/tag/v0.1.0
