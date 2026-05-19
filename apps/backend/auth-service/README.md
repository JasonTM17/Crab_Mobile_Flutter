# Auth Service

Handles user authentication, registration, and token management.

## Port: 3001

## Features
- User registration with email/phone
- Login with JWT access + refresh tokens
- Token refresh flow
- Password hashing (bcrypt)
- OTP verification
- Session management via Redis

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login with credentials |
| POST | `/auth/refresh` | Refresh access token |
| POST | `/auth/logout` | Invalidate session |
| POST | `/auth/verify-otp` | Verify OTP code |
| POST | `/auth/forgot-password` | Request password reset |
| POST | `/auth/reset-password` | Reset password with token |

## Docker

```bash
docker build -f apps/backend/auth-service/Dockerfile -t jasontm17/auth-service .
docker run -p 3001:3001 --env-file .env jasontm17/auth-service
```

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| PORT | Service port | 3001 |
| JWT_SECRET | JWT signing key | - |
| JWT_EXPIRES_IN | Access token TTL | 15m |
| JWT_REFRESH_EXPIRES_IN | Refresh token TTL | 7d |
| POSTGRES_HOST | PostgreSQL host | localhost |
| POSTGRES_PORT | PostgreSQL port | 5432 |
| POSTGRES_USER | Database user | crab |
| POSTGRES_PASSWORD | Database password | - |
| POSTGRES_DB | Database name | crab |
| REDIS_HOST | Redis host | localhost |
| REDIS_PORT | Redis port | 6379 |
