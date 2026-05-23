# Web Admin Dashboard

React-based admin panel for managing the Crab platform.

## Port: 5173 (dev) / 8080 (Docker)

## Tech Stack
- React 18 + TypeScript
- Vite build tool
- TailwindCSS + shadcn/ui components
- TanStack Query for data fetching
- Recharts for analytics
- React Router v6

## Features
- Dashboard with real-time analytics
- User management (riders, drivers, restaurants)
- Ride monitoring and history
- Order management
- Payment/transaction oversight
- Rating moderation
- System health monitoring
- Revenue reports

## Pages

| Route | Description |
|-------|-------------|
| `/` | Dashboard with KPIs and charts |
| `/users` | User management table |
| `/drivers` | Driver management and verification |
| `/rides` | Ride history and live monitoring |
| `/orders` | Food order management |
| `/restaurants` | Restaurant management |
| `/payments` | Transaction history |
| `/ratings` | Review moderation |
| `/settings` | System configuration |

## Development

```bash
pnpm --filter @crab/web-admin dev
```

## Docker

```bash
docker build -f apps/web-admin/Dockerfile -t nguyenson1710/crab-mobile-web-admin .
docker run -p 8080:8080 nguyenson1710/crab-mobile-web-admin
```
