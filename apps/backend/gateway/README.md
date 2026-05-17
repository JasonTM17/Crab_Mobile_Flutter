# API Gateway

Central entry point for all Crab microservices. Handles routing, authentication, rate limiting, and WebSocket proxying.

## Port: 3000

## Features
- JWT authentication middleware
- Rate limiting (100 req/min per IP)
- Request proxying to downstream services
- Socket.IO namespace routing with Redis adapter
- Health check endpoint
- CORS configuration

## API Routes

| Method | Path | Target Service |
|--------|------|----------------|
| POST | `/api/v1/auth/*` | auth-service:3001 |
| GET/PUT | `/api/v1/users/*` | user-service:3002 |
| ALL | `/api/v1/rides/*` | ride-service:3003 |
| ALL | `/api/v1/food/*` | food-service:3004 |
| ALL | `/api/v1/payments/*` | payment-service:3005 |
| ALL | `/api/v1/chat/*` | chat-service:3006 |
| ALL | `/api/v1/notifications/*` | notification-service:3007 |
| ALL | `/api/v1/ratings/*` | rating-service:3008 |

## Docker

```bash
docker build -t ghcr.io/jasontm17/crab-gateway .
docker run -p 3000:3000 --env-file .env ghcr.io/jasontm17/crab-gateway
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Service port | 3000 |
| JWT_SECRET | JWT signing key | - |
| REDIS_HOST | Redis host | localhost |
| REDIS_PORT | Redis port | 6379 |
| RATE_LIMIT_TTL | Rate limit window (seconds) | 60 |
| RATE_LIMIT_MAX | Max requests per window | 100 |
| AUTH_SERVICE_URL | Auth service URL | http://localhost:3001 |
| USER_SERVICE_URL | User service URL | http://localhost:3002 |
| RIDE_SERVICE_URL | Ride service URL | http://localhost:3003 |
| FOOD_SERVICE_URL | Food service URL | http://localhost:3004 |
| PAYMENT_SERVICE_URL | Payment service URL | http://localhost:3005 |
| CHAT_SERVICE_URL | Chat service URL | http://localhost:3006 |
| NOTIFICATION_SERVICE_URL | Notification service URL | http://localhost:3007 |
| RATING_SERVICE_URL | Rating service URL | http://localhost:3008 |
