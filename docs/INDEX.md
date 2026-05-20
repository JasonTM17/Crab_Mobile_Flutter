# Documentation Index

## Crab Super App — Technical Documentation

| Document | Description |
|----------|-------------|
| [Architecture](./ARCHITECTURE.md) | System design, service catalog, communication patterns, security |
| [API Reference](./API.md) | REST API endpoints for all services with request/response examples |
| [Realtime](./REALTIME.md) | Socket.IO topology, namespaces, lifecycles, replay strategy |
| [WebSocket Events](./WEBSOCKET_EVENTS.md) | Wire-level event reference for ride, food, chat, notification |
| [Ride Matching](./RIDE_MATCHING.md) | Queue, scoring, surge, re-match flow, eligibility |
| [Food Delivery](./FOOD_DELIVERY.md) | Order state machine, dispatch, cancellation, restaurant ops |
| [Database Schema](./DATABASE.md) | PostgreSQL tables, MongoDB collections, Redis data structures |
| [Deployment](./DEPLOYMENT.md) | Docker setup, environment variables, scaling, CI/CD |
| [Testing](./TESTING.md) | Test strategy, examples, load testing, coverage requirements |

## Quick Links

- **Getting Started**: See [Deployment Guide](./DEPLOYMENT.md#quick-start-docker)
- **API Base URL**: `http://localhost:3000/api`
- **WebSocket URL**: `ws://localhost:3000/{namespace}`
- **Health Check**: `GET http://localhost:3000/health`

## Project Structure

```
Crab_Mobile_Flutter/
├── apps/
│   ├── backend/          # NestJS microservices (9 services)
│   ├── mobile/           # Flutter mobile app
│   └── web-admin/        # React admin dashboard
├── packages/
│   ├── common-types/     # Shared TypeScript interfaces
│   └── socket-events/    # Socket.IO event type definitions
├── docker/               # Docker development configs
├── docs/                 # This documentation
└── .github/workflows/    # CI/CD pipelines
```

## Service Ports

| Service | Port | Health |
|---------|------|--------|
| Gateway | 3000 | /health |
| Auth | 3001 | /health |
| User | 3002 | /health |
| Ride | 3003 | /health |
| Food | 3004 | /health |
| Payment | 3005 | /health |
| Chat | 3006 | /health |
| Notification | 3007 | /health |
| Rating | 3008 | /health |
| Web Admin | 8080 | / |
| PostgreSQL | 5432 | - |
| MongoDB | 27017 | - |
| Redis | 6379 | - |
