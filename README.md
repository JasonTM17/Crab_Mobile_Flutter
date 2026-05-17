# Crab - Super App (Ride-Hailing & Food Delivery)

A full-stack super app combining ride-hailing and food delivery services, built with modern microservices architecture.

> **Learning Project** - This project was built for educational purposes to demonstrate full-stack mobile app development with microservices. Feedback and contributions are welcome!

**Author:** Nguyễn Sơn  
**Email:** jasonbmt06@gmail.com  
**GitHub:** [@JasonTM17](https://github.com/JasonTM17)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Mobile App                         │
│              (BLoC + GetIt + GoRouter + Dio)                  │
└──────────────────────────┬──────────────────────────────────┘
                           │
┌──────────────────────────▼──────────────────────────────────┐
│                    API Gateway (:3000)                        │
│              (NestJS + JWT + Rate Limiting)                   │
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
```

## Tech Stack

### Mobile (Flutter)
- **Framework:** Flutter 3.x
- **State Management:** flutter_bloc + equatable
- **DI:** get_it + injectable
- **Navigation:** go_router
- **Networking:** dio + socket_io_client
- **Maps:** google_maps_flutter
- **Storage:** flutter_secure_storage

### Backend (NestJS Microservices)
- **Framework:** NestJS 10
- **Database:** PostgreSQL (TypeORM) + MongoDB (Mongoose)
- **Cache/PubSub:** Redis
- **Real-time:** Socket.IO with Redis adapter
- **Auth:** JWT + Passport
- **Validation:** class-validator + class-transformer
- **Build:** pnpm workspaces + Turborepo

### Web Admin (React)
- **Framework:** React 18 + TypeScript
- **Build:** Vite
- **Styling:** TailwindCSS + shadcn/ui
- **Charts:** Recharts
- **State:** TanStack Query

## Project Structure

```
Crab_Mobile_Flutter/
├── apps/
│   ├── mobile/              # Flutter mobile app
│   │   ├── lib/
│   │   │   ├── core/        # DI, networking, routing, theme
│   │   │   ├── features/    # Feature modules (auth, ride, food, etc.)
│   │   │   └── shared/      # Shared models, utils, widgets
│   │   └── pubspec.yaml
│   ├── backend/             # NestJS microservices
│   │   ├── gateway/         # API Gateway (:3000)
│   │   ├── auth-service/    # Authentication (:3001)
│   │   ├── user-service/    # User management (:3002)
│   │   ├── ride-service/    # Ride-hailing (:3003)
│   │   ├── food-service/    # Food delivery (:3004)
│   │   ├── payment-service/ # Payments (:3005)
│   │   ├── chat-service/    # Real-time chat (:3006)
│   │   ├── notification-service/ # Push notifications (:3007)
│   │   └── rating-service/  # Ratings & reviews (:3008)
│   └── web-admin/           # React admin dashboard
├── docker-compose.yml       # Full stack orchestration
├── turbo.json              # Turborepo config
├── pnpm-workspace.yaml     # pnpm workspaces
└── package.json            # Root package.json
```

## Features

### Ride-Hailing
- Real-time driver tracking with animated markers
- Location search with recent history
- Fare estimation before booking
- Driver matching with countdown timer
- Driver mode with online/offline toggle
- Ride status progression (searching → matched → pickup → in-progress → completed)

### Food Delivery
- Restaurant browsing with categories
- Menu with item customization
- Cart management
- Order tracking with status stepper
- Restaurant ratings and reviews

### Shared Features
- JWT authentication with token refresh
- Real-time notifications via Socket.IO
- In-app chat between rider/driver
- Digital wallet with top-up
- Rating system with tags
- Push notifications

## Getting Started

### Prerequisites
- Flutter SDK >= 3.0.0
- Node.js >= 18
- pnpm >= 8
- Docker & Docker Compose
- PostgreSQL 15+
- MongoDB 6+
- Redis 7+

### Quick Start with Docker

```bash
# Clone the repository
git clone https://github.com/JasonTM17/Crab_Mobile_Flutter.git
cd Crab_Mobile_Flutter

# Start all services
docker-compose up -d

# Services will be available at:
# Gateway:      http://localhost:3000
# Web Admin:    http://localhost:5173
```

### Manual Setup

```bash
# Install dependencies
pnpm install

# Start backend services
pnpm --filter @crab/gateway dev
pnpm --filter @crab/auth-service dev
# ... start other services

# Start web admin
pnpm --filter @crab/web-admin dev

# Flutter mobile
cd apps/mobile
flutter pub get
flutter run
```

## API Endpoints

| Service | Port | Base Path | Description |
|---------|------|-----------|-------------|
| Gateway | 3000 | `/api/v1` | API routing, rate limiting, auth |
| Auth | 3001 | `/auth` | Login, register, token refresh |
| User | 3002 | `/users` | Profile, preferences |
| Ride | 3003 | `/rides` | Booking, tracking, history |
| Food | 3004 | `/food` | Restaurants, menus, orders |
| Payment | 3005 | `/payments` | Wallet, transactions |
| Chat | 3006 | `/chat` | Real-time messaging |
| Notification | 3007 | `/notifications` | Push & in-app notifications |
| Rating | 3008 | `/ratings` | Reviews, scores |

## Socket.IO Namespaces

| Namespace | Purpose |
|-----------|---------|
| `/ride` | Driver location updates, ride status changes |
| `/food` | Order status updates, delivery tracking |
| `/chat` | Real-time messaging |
| `/notification` | Push notification delivery |

## Docker Services

All services are containerized and available on GitHub Container Registry:

```bash
# Pull all images
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

## Environment Variables

Copy `.env.example` to `.env` and configure:

```env
# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=crab
POSTGRES_PASSWORD=crab_secret
POSTGRES_DB=crab

# MongoDB
MONGO_URI=mongodb://localhost:27017/crab

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

# JWT
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=15m
JWT_REFRESH_EXPIRES_IN=7d

# Google Maps
GOOGLE_MAPS_API_KEY=your-api-key
```

## Screenshots

| Home Screen | Ride Booking | Driver Mode |
|:-----------:|:------------:|:-----------:|
| Service selection with wallet balance | Map with pickup/dropoff selection | Online/offline toggle with ride requests |

| Food Ordering | Order Tracking | Admin Dashboard |
|:-------------:|:--------------:|:---------------:|
| Restaurant list with categories | Real-time status stepper | Analytics with user management |

## Contributing

This is a learning project and contributions are welcome! Feel free to:
- Open issues for bugs or feature requests
- Submit pull requests with improvements
- Share feedback via email at jasonbmt06@gmail.com

## License

MIT License - see [LICENSE](LICENSE) for details.
