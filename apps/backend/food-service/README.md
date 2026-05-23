# Food Service

Manages food delivery operations including restaurants, menus, orders, and delivery tracking.

## Port: 3004

## Features
- Restaurant CRUD with categories and search
- Menu management with item customization
- Order creation and status tracking
- Delivery assignment and tracking
- Restaurant ratings integration
- Category-based browsing

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| GET | `/food/restaurants` | List restaurants |
| GET | `/food/restaurants/:id` | Restaurant details |
| GET | `/food/restaurants/:id/menu` | Get menu |
| POST | `/food/orders` | Create order |
| GET | `/food/orders/:id` | Order details |
| GET | `/food/orders/active` | Active orders |
| GET | `/food/orders/history` | Order history |
| PATCH | `/food/orders/:id/status` | Update order status |
| POST | `/food/orders/:id/cancel` | Cancel order |
| GET | `/food/categories` | List categories |

## Socket.IO Events (namespace: /food)

| Event | Direction | Description |
|-------|-----------|-------------|
| `order:status` | Server → Client | Order status update |
| `order:assigned` | Server → Client | Delivery driver assigned |
| `delivery:location` | Server → Client | Driver location |

## Docker

```bash
docker build -f apps/backend/food-service/Dockerfile -t nguyenson1710/crab-mobile-food-service .
docker run -p 3004:3004 --env-file .env nguyenson1710/crab-mobile-food-service
```
