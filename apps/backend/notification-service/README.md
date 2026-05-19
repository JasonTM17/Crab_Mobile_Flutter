# Notification Service

Manages push notifications and in-app notification delivery.

## Port: 3007

## Features
- In-app notification storage and retrieval
- Push notification delivery (FCM)
- Notification preferences per user
- Read/unread status tracking
- Batch notification sending
- Real-time delivery via Socket.IO

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/notifications` | List user notifications |
| GET | `/notifications/unread-count` | Get unread count |
| PATCH | `/notifications/:id/read` | Mark as read |
| PATCH | `/notifications/read-all` | Mark all as read |
| DELETE | `/notifications/:id` | Delete notification |
| GET | `/notifications/preferences` | Get preferences |
| PUT | `/notifications/preferences` | Update preferences |

## Socket.IO Events (namespace: /notification)

| Event | Direction | Description |
|-------|-----------|-------------|
| `notification:new` | Server → Client | New notification |
| `notification:count` | Server → Client | Updated unread count |

## Notification Types

| Type | Trigger |
|------|---------|
| `ride_accepted` | Driver accepts ride |
| `ride_arriving` | Driver near pickup |
| `ride_completed` | Ride finished |
| `order_confirmed` | Food order confirmed |
| `order_ready` | Order ready for pickup |
| `order_delivered` | Food delivered |
| `payment_received` | Payment processed |
| `promo` | Promotional notification |

## Docker

```bash
docker build -t ghcr.io/jasontm17/crab-notification-service .
docker run -p 3007:3007 --env-file .env ghcr.io/jasontm17/crab-notification-service
```
