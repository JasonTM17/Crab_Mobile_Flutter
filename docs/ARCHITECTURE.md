# System Architecture

## Overview

Crab is a super-app platform built on a microservices architecture. The system consists of 9 backend services, a Flutter mobile client, and a React admin dashboard — all orchestrated via Docker and managed as a pnpm monorepo.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
├─────────────────────┬───────────────────────────────────────────┤
│   Flutter Mobile    │         React Admin Dashboard             │
│   (iOS / Android)   │         (Web Browser)                     │
└─────────┬───────────┴──────────────────┬────────────────────────┘
          │ REST + WebSocket             │ REST
          ▼                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                     API GATEWAY (:3000)                          │
│              NestJS + Passport + Socket.IO                       │
│         Rate Limiting · JWT Validation · Routing                │
└────┬────────┬────────┬────────┬────────┬────────┬───────────────┘
     │        │        │        │        │        │
     ▼        ▼        ▼        ▼        ▼        ▼
┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐┌────────┐
│  Auth  ││  User  ││  Ride  ││  Food  ││Payment ││  Chat  │
│ :3001  ││ :3002  ││ :3003  ││ :3004  ││ :3005  ││ :3006  │
└────┬───┘└────┬───┘└────┬───┘└────┬───┘└────┬───┘└────┬───┘
     │         │         │         │         │         │
     ▼         ▼         ▼         ▼         ▼         ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA LAYER                                  │
├──────────────────┬──────────────────┬───────────────────────────┤
│   PostgreSQL     │    MongoDB       │        Redis              │
│   (Auth, User,   │   (Chat msgs,    │   (Sessions, Cache,       │
│    Payment,      │    Notifications) │    Socket.IO Adapter,     │
│    Rating)       │                   │    Rate Limiting)         │
└──────────────────┴──────────────────┴───────────────────────────┘
```

## Service Catalog

| Service | Port | Database | Responsibility |
|---------|------|----------|----------------|
| Gateway | 3000 | Redis | API routing, auth validation, rate limiting, WebSocket proxy |
| Auth | 3001 | PostgreSQL | JWT auth, OAuth2, token refresh, password reset |
| User | 3002 | PostgreSQL | Profile CRUD, avatar upload, preferences |
| Ride | 3003 | PostgreSQL + Redis | Ride matching, GPS tracking, fare calculation |
| Food | 3004 | PostgreSQL | Restaurant catalog, menu, order management |
| Payment | 3005 | PostgreSQL | Wallet, transactions, payment methods, refunds |
| Chat | 3006 | MongoDB | Real-time messaging, conversation history |
| Notification | 3007 | MongoDB + Redis | Push notifications, in-app alerts, FCM |
| Rating | 3008 | PostgreSQL | Reviews, ratings, driver/restaurant scores |

## Communication Patterns

### Synchronous (HTTP)

- Client → Gateway → Service (REST API)
- Service → Service (internal HTTP via service discovery)

### Asynchronous (Events)

- Socket.IO with Redis Adapter for horizontal scaling
- Namespaced events: `/ride`, `/food`, `/chat`, `/notification`

### Inter-Service Communication

```
Gateway ──HTTP──► Auth Service (token validation)
Ride Service ──HTTP──► Payment Service (fare charge)
Ride Service ──HTTP──► Notification Service (driver assigned)
Food Service ──HTTP──► Payment Service (order charge)
Chat Service ──Socket.IO──► Notification Service (new message)
```

## Authentication Flow

```
1. Client sends credentials to POST /api/v1/auth/login
2. Gateway forwards to Auth Service
3. Auth Service validates, returns JWT access + refresh tokens
4. Client stores tokens securely (Flutter Secure Storage)
5. Subsequent requests include Bearer token in Authorization header
6. Gateway validates JWT before routing to downstream services
7. Token refresh via POST /api/v1/auth/refresh (silent refresh)
```

## Data Flow: Ride Booking

```
1. Rider requests ride via POST /api/v1/rides
2. Ride Service creates ride record (status: REQUESTED)
3. Ride Service broadcasts to nearby drivers via Socket.IO /ride namespace
4. Driver accepts → Ride Service updates status to MATCHED
5. Driver heads to pickup → status: PICKUP. Real-time GPS tracking via Socket.IO events
6. Trip starts → status: IN_PROGRESS. Trip completes → status: COMPLETED. Payment Service charges rider wallet
7. Rating Service prompts both parties for review
8. Notification Service sends receipt + rating prompt
```

## Data Flow: Food Order

```
1. Customer browses restaurants via GET /api/v1/restaurants/search
2. Customer places order via POST /api/v1/orders
3. Food Service creates order (status: PLACED)
4. Restaurant confirms → status: CONFIRMED → PREPARING
5. Driver assigned + picks up → status: READY → PICKED_UP
6. Real-time tracking via Socket.IO /food namespace
7. Delivery confirmed → status: DELIVERED. Payment Service charges
8. Rating prompts sent to customer
```

## Shared Packages

| Package | Purpose |
|---------|----------|
| `@crab/common-types` | Shared TypeScript interfaces, DTOs, enums |
| `@crab/socket-events` | Socket.IO event names and payload types |

## Security Architecture

- **JWT tokens** with short-lived access (15min) + long-lived refresh (7d)
- **Rate limiting** at Gateway level (100 req/min per IP, 1000 req/min per user)
- **Input validation** via class-validator on all DTOs
- **CORS** configured per environment
- **Helmet.js** for HTTP security headers
- **bcrypt** for password hashing (12 rounds)
- **Redis-backed sessions** for admin dashboard

## Scalability Considerations

- **Horizontal scaling**: Each service runs independently, scale via Docker replicas
- **Redis Adapter**: Socket.IO scales across multiple Gateway instances
- **Database per service**: No shared database coupling
- **Stateless services**: JWT-based auth, no server-side sessions for mobile
- **Connection pooling**: TypeORM connection pool per service
- **Caching**: Redis for frequently accessed data (user profiles, restaurant menus)

## Monitoring & Observability

- Health check endpoints: `GET /health` on each service
- Structured JSON logging via NestJS Logger
- Docker health checks with restart policies
- Graceful shutdown handling (SIGTERM)
