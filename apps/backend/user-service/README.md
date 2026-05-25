# User Service

Manages user profiles, preferences, and account settings.

## Port: 3002

## Features
- User profile CRUD
- Avatar upload
- Address management (saved locations)
- User preferences
- Account deactivation
- Driver profile management

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/users/me` | Get current user profile |
| PUT | `/users/me` | Update profile |
| PUT | `/users/me/avatar` | Upload avatar |
| GET | `/users/me/addresses` | Saved addresses |
| POST | `/users/me/addresses` | Add address |
| DELETE | `/users/me/addresses/:id` | Remove address |
| GET | `/users/me/preferences` | Get preferences |
| PUT | `/users/me/preferences` | Update preferences |
| POST | `/users/me/deactivate` | Deactivate account |
| GET | `/users/:id` | Get user by ID (admin) |

## Docker

```bash
docker build -f apps/backend/user-service/Dockerfile -t nguyenson1710/crab-mobile-user-service .
docker run -p 3002:3002 --env-file .env nguyenson1710/crab-mobile-user-service
```
