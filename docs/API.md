# API Reference

Base URL: `http://localhost:3000/api/v1`

All endpoints require `Authorization: Bearer <token>` unless marked as public. The Gateway prefixes every downstream service with `/api/v1`; service ports below are reachable directly only inside the Docker network.

## Authentication Service

### POST /auth/register (Public)

Register a new user account.

```json
// Request
{
  "email": "user@example.com",
  "password": "SecurePass123!",
  "fullName": "Nguyen Van A",
  "phone": "+84901234567",
  "role": "rider" // rider | driver | restaurant_owner
}

// Response 201
{
  "id": "uuid",
  "email": "user@example.com",
  "fullName": "Nguyen Van A",
  "role": "rider",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### POST /auth/login (Public)

Authenticate and receive tokens.

```json
// Request
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}

// Response 200
{
  "accessToken": "eyJhbG...",
  "refreshToken": "eyJhbG...",
  "expiresIn": 900,
  "user": {
    "id": "uuid",
    "email": "user@example.com",
    "role": "rider"
  }
}
```

### POST /auth/refresh

Refresh an expired access token.

```json
// Request
{ "refreshToken": "eyJhbG..." }

// Response 200
{
  "accessToken": "eyJhbG...",
  "expiresIn": 900
}
```

### POST /auth/logout

Invalidate the current refresh token.

```json
// Response 200
{ "message": "Logged out successfully" }
```

### POST /auth/forgot-password (Public)

```json
// Request
{ "email": "user@example.com" }

// Response 200
{ "message": "Reset email sent" }
```

---

## User Service

### GET /users/me

Get current user profile.

```json
// Response 200
{
  "id": "uuid",
  "email": "user@example.com",
  "fullName": "Nguyen Van A",
  "phone": "+84901234567",
  "avatar": "https://storage.example.com/avatars/uuid.jpg",
  "role": "rider",
  "rating": 4.8,
  "totalRides": 42,
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### PATCH /users/me

Update current user profile.

```json
// Request
{
  "fullName": "Nguyen Van B",
  "phone": "+84909876543"
}

// Response 200
{ "id": "uuid", "fullName": "Nguyen Van B", ... }
```

### POST /users/me/avatar

Upload avatar (multipart/form-data).

```
Content-Type: multipart/form-data
Field: avatar (file, max 5MB, jpg/png)

// Response 200
{ "avatar": "https://storage.example.com/avatars/uuid.jpg" }
```

### GET /users/:id (Admin)

Get any user by ID (admin only).

---

## Ride Service

### POST /rides

Request a new ride.

```json
// Request
{
  "pickupLocation": {
    "lat": 10.7769,
    "lng": 106.7009,
    "address": "123 Nguyen Hue, District 1"
  },
  "dropoffLocation": {
    "lat": 10.8021,
    "lng": 106.7146,
    "address": "456 Le Van Sy, District 3"
  },
  "vehicleType": "car" // bike | car | car_plus
}

// Response 201
{
  "id": "uuid",
  "status": "REQUESTED",
  "estimatedFare": 45000,
  "estimatedDuration": 15,
  "pickupLocation": { ... },
  "dropoffLocation": { ... },
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### GET /rides/:id

Get ride details.

### GET /rides/history

Get ride history for current user.

```json
// Query params: ?page=1&limit=20&status=COMPLETED

// Response 200
{
  "data": [ ... ],
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 42,
    "totalPages": 3
  }
}
```

### POST /rides/:id/cancel

Cancel an active ride.

```json
// Request
{ "reason": "Changed my mind" }

// Response 200
{ "id": "uuid", "status": "CANCELLED", "cancellationFee": 5000 }
```

### Ride Statuses

`REQUESTED` → `MATCHED` → `PICKUP` → `IN_PROGRESS` → `COMPLETED`

Alternative: any state → `CANCELLED`. The matching queue dispatches drivers; if no driver accepts within the configured timeout the ride is auto-cancelled with reason `NO_DRIVER`.

---

## Food Service

### GET /food/restaurants

List restaurants near location.

```json
// Query: ?lat=10.77&lng=106.70&radius=5&category=vietnamese&page=1

// Response 200
{
  "data": [
    {
      "id": "uuid",
      "name": "Pho 24",
      "category": "vietnamese",
      "rating": 4.5,
      "deliveryTime": "20-30 min",
      "deliveryFee": 15000,
      "imageUrl": "https://...",
      "isOpen": true,
      "distance": 1.2
    }
  ],
  "meta": { "page": 1, "total": 50 }
}
```

### GET /food/restaurants/:id/menu

Get restaurant menu.

```json
// Response 200
{
  "categories": [
    {
      "name": "Main Dishes",
      "items": [
        {
          "id": "uuid",
          "name": "Pho Bo",
          "description": "Traditional beef noodle soup",
          "price": 55000,
          "imageUrl": "https://...",
          "options": [
            { "name": "Size", "choices": ["Regular", "Large"], "prices": [0, 15000] }
          ]
        }
      ]
    }
  ]
}
```

### POST /food/orders

Place a food order.

```json
// Request
{
  "restaurantId": "uuid",
  "items": [
    { "menuItemId": "uuid", "quantity": 2, "options": { "Size": "Large" } }
  ],
  "deliveryAddress": {
    "lat": 10.77,
    "lng": 106.70,
    "address": "123 Nguyen Hue"
  },
  "note": "Extra chili please"
}

// Response 201
{
  "id": "uuid",
  "status": "PLACED",
  "items": [ ... ],
  "subtotal": 125000,
  "deliveryFee": 15000,
  "total": 140000,
  "estimatedDelivery": "25-35 min"
}
```

### Food Order Statuses

`PLACED` → `CONFIRMED` → `PREPARING` → `READY` → `PICKED_UP` → `DELIVERED`

Alternative: any non-terminal state → `CANCELLED`.

---

## Payment Service

### GET /payments/wallet

Get wallet balance.

```json
// Response 200
{
  "balance": 500000,
  "currency": "VND",
  "lastUpdated": "2024-01-01T00:00:00Z"
}
```

### POST /payments/topup

Top up wallet.

```json
// Request
{
  "amount": 100000,
  "method": "bank_transfer" // bank_transfer | momo | zalopay | credit_card
}

// Response 200
{
  "transactionId": "uuid",
  "amount": 100000,
  "newBalance": 600000,
  "status": "COMPLETED"
}
```

### GET /payments/transactions

Get transaction history.

```json
// Query: ?page=1&limit=20&type=ride_payment

// Response 200
{
  "data": [
    {
      "id": "uuid",
      "type": "ride_payment",
      "amount": -45000,
      "description": "Ride #abc123",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { ... }
}
```

---

## Chat Service

### GET /chat/conversations

List user conversations.

```json
// Response 200
{
  "data": [
    {
      "id": "uuid",
      "participant": { "id": "uuid", "name": "Driver A", "avatar": "..." },
      "lastMessage": { "text": "I'm arriving", "createdAt": "..." },
      "unreadCount": 2,
      "rideId": "uuid"
    }
  ]
}
```

### GET /chat/conversations/:id/messages

Get messages in a conversation.

```json
// Query: ?before=cursor&limit=50

// Response 200
{
  "data": [
    {
      "id": "uuid",
      "senderId": "uuid",
      "text": "Hello!",
      "type": "text",
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "cursor": "next_page_cursor"
}
```

---

## Notification Service

### GET /notifications

Get user notifications.

```json
// Query: ?page=1&limit=20&unreadOnly=true

// Response 200
{
  "data": [
    {
      "id": "uuid",
      "type": "ride_accepted",
      "title": "Driver found!",
      "body": "Your driver is on the way",
      "data": { "rideId": "uuid" },
      "read": false,
      "createdAt": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": { ... },
  "unreadTotal": 5
}
```

### POST /notifications/read

Mark notifications as read.

```json
// Request
{ "ids": ["uuid1", "uuid2"] }

// Response 200
{ "marked": 2 }
```

### POST /notifications/fcm-token

Register FCM token for push notifications.

```json
// Request
{ "token": "fcm_device_token_here", "platform": "android" }

// Response 200
{ "registered": true }
```

---

## Rating Service

### POST /ratings

Submit a rating.

```json
// Request
{
  "targetId": "uuid",
  "targetType": "driver", // driver | rider | restaurant
  "rideId": "uuid",
  "score": 5,
  "comment": "Great driver, very polite"
}

// Response 201
{
  "id": "uuid",
  "score": 5,
  "comment": "Great driver, very polite",
  "createdAt": "2024-01-01T00:00:00Z"
}
```

### GET /ratings/:targetId

Get ratings for a user/restaurant.

```json
// Query: ?page=1&limit=10

// Response 200
{
  "averageScore": 4.7,
  "totalRatings": 156,
  "distribution": { "5": 100, "4": 40, "3": 10, "2": 4, "1": 2 },
  "data": [ ... ]
}
```

---

## Common Response Patterns

### Error Response

```json
{
  "statusCode": 400,
  "message": "Validation failed",
  "errors": [
    { "field": "email", "message": "Invalid email format" }
  ],
  "timestamp": "2024-01-01T00:00:00Z"
}
```

### Pagination

All list endpoints support:
- `?page=1` — Page number (default: 1)
- `?limit=20` — Items per page (default: 20, max: 100)

### Rate Limiting

Headers returned on every response:
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1704067200
```

When exceeded: `429 Too Many Requests`

```json
{ "statusCode": 429, "message": "Rate limit exceeded. Try again in 60 seconds." }
```
