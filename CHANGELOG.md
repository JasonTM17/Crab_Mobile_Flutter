# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Complete microservices backend (9 NestJS services)
- Flutter mobile app with BLoC state management
- React admin dashboard with shadcn/ui
- Docker multi-stage builds for all services
- GitHub Actions CI/CD (lint, test, build, publish)
- Comprehensive documentation (Architecture, API, WebSocket, Database, Deployment, Testing)
- ESLint + Prettier code quality enforcement
- Flutter analysis_options with strict linting
- Rate limiting at Gateway level
- JWT authentication with refresh token rotation
- Real-time features via Socket.IO (ride tracking, chat, notifications)
- Payment wallet system with transaction history
- Food ordering with restaurant management
- Driver matching and GPS tracking
- Push notifications via FCM
- k6 load testing configuration

### Infrastructure
- pnpm monorepo with Turborepo
- Docker Compose for full-stack orchestration
- PostgreSQL, MongoDB, Redis data layer
- GHCR container registry publishing
- Health check endpoints on all services
- Shared packages (@crab/common-types, @crab/socket-events)

## [1.0.0] - TBD

### Planned
- Production deployment guide
- Kubernetes manifests
- Monitoring stack (Prometheus + Grafana)
- API versioning (v1, v2)
- Internationalization (i18n)
- Admin dashboard analytics
