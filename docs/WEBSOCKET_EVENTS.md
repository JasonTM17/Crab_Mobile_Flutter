# WebSocket Events Reference

Crab uses Socket.IO with namespace-based event routing. All WebSocket connections go through the Gateway at `ws://localhost:3000`.

## Connection

```javascript
import { io } from 'socket.io-client';

const socket = io('http://localhost:3000/ride', {
  auth: { token: 'Bearer <access_token>' },
  transports: ['websocket'],
});
```

## Namespaces

| Namespace | Purpose | Participants |
|-----------|---------|-------------|
| `/ride` | Real-time ride tracking | Riders, Drivers |
| `/food` | Food order status updates | Customers, Restaurants, Drivers |
| `/chat` | Instant messaging | All users |
| `/notification` | Push notifications | All users |

---

## /ride Namespace

### Client → Server Events

#### `ride:request`
Rider requests a new ride.
```javascript
socket.emit('ride:request', {
  pickupLocation: { lat: 10.7769, lng: 106.7009, address: '123 Nguyen Hue' },
  dropoffLocation: { lat: 10.8021, lng: 106.7146, address: '456 Le Van Sy' },
  vehicleType: 'car'
});
```

#### `ride:accept`
Driver accepts a ride request.
```javascript
socket.emit('ride:accept', { rideId: 'uuid' });
```

#### `ride:cancel`
Cancel an active ride.
```javascript
socket.emit('ride:cancel', { rideId: 'uuid', reason: 'Changed plans' });
```

#### `driver:location`
Driver sends GPS location update.
```javascript
socket.emit('driver:location', {
  lat: 10.7780,
  lng: 106.7015,
  heading: 45,
  speed: 30
});
```

#### `ride:arrived`
Driver arrived at pickup point.
```javascript
socket.emit('ride:arrived', { rideId: 'uuid' });
```

#### `ride:start`
Ride has started (rider picked up).
```javascript
socket.emit('ride:start', { rideId: 'uuid' });
```

#### `ride:complete`
Ride completed (arrived at destination).
```javascript
socket.emit('ride:complete', { rideId: 'uuid', actualFare: 48000 });
```

### Server → Client Events

#### `ride:new_request`
Broadcast to nearby drivers when a ride is requested.
```javascript
socket.on('ride:new_request', (data) => {
  // data: { rideId, pickupLocation, dropoffLocation, vehicleType, estimatedFare }
});
```

#### `ride:accepted`
Notify rider that a driver accepted.
```javascript
socket.on('ride:accepted', (data) => {
  // data: { rideId, driver: { id, name, avatar, phone, vehiclePlate, vehicleModel, rating }, eta }
});
```

#### `ride:driver_location`
Real-time driver location updates for rider.
```javascript
socket.on('ride:driver_location', (data) => {
  // data: { rideId, lat, lng, heading, speed, eta }
});
```

#### `ride:status_changed`
Ride status transition notification.
```javascript
socket.on('ride:status_changed', (data) => {
  // data: { rideId, status, timestamp }
  // status: ACCEPTED | ARRIVING | IN_PROGRESS | COMPLETED | CANCELLED
});
```

#### `ride:no_driver`
No driver found within timeout.
```javascript
socket.on('ride:no_driver', (data) => {
  // data: { rideId, message: 'No drivers available' }
});
```

---

## /food Namespace

### Client → Server Events

#### `order:track`
Subscribe to order status updates.
```javascript
socket.emit('order:track', { orderId: 'uuid' });
```

#### `order:untrack`
Unsubscribe from order updates.
```javascript
socket.emit('order:untrack', { orderId: 'uuid' });
```

### Server → Client Events

#### `order:status_changed`
Order status update.
```javascript
socket.on('order:status_changed', (data) => {
  // data: { orderId, status, timestamp, estimatedTime }
  // status: CONFIRMED | PREPARING | READY | PICKED_UP | DELIVERED
});
```

#### `order:driver_assigned`
Delivery driver assigned to order.
```javascript
socket.on('order:driver_assigned', (data) => {
  // data: { orderId, driver: { id, name, avatar, phone, vehiclePlate } }
});
```

#### `order:driver_location`
Delivery driver location during transit.
```javascript
socket.on('order:driver_location', (data) => {
  // data: { orderId, lat, lng, eta }
});
```

---

## /chat Namespace

### Client → Server Events

#### `message:send`
Send a message.
```javascript
socket.emit('message:send', {
  conversationId: 'objectId',
  text: 'Hello!',
  type: 'text'
});
```

#### `message:typing`
Typing indicator.
```javascript
socket.emit('message:typing', { conversationId: 'objectId', isTyping: true });
```

#### `message:read`
Mark messages as read.
```javascript
socket.emit('message:read', { conversationId: 'objectId', messageId: 'objectId' });
```

### Server → Client Events

#### `message:new`
New message received.
```javascript
socket.on('message:new', (data) => {
  // data: { id, conversationId, senderId, text, type, createdAt }
});
```

#### `message:typing`
Other user typing indicator.
```javascript
socket.on('message:typing', (data) => {
  // data: { conversationId, userId, isTyping }
});
```

#### `message:read_receipt`
Message read confirmation.
```javascript
socket.on('message:read_receipt', (data) => {
  // data: { conversationId, userId, lastReadMessageId }
});
```

---

## /notification Namespace

### Server → Client Events

#### `notification:new`
New notification received.
```javascript
socket.on('notification:new', (data) => {
  // data: { id, type, title, body, data, createdAt }
});
```

#### `notification:badge_update`
Unread count changed.
```javascript
socket.on('notification:badge_update', (data) => {
  // data: { unreadCount: 5 }
});
```

---

## Error Handling

All namespaces emit errors via:

```javascript
socket.on('error', (error) => {
  // error: { code: 'UNAUTHORIZED', message: 'Invalid token' }
  // error: { code: 'RATE_LIMITED', message: 'Too many events' }
  // error: { code: 'INVALID_PAYLOAD', message: 'Missing required field: rideId' }
});
```

## Reconnection

Socket.IO handles reconnection automatically. On reconnect:
1. Client re-authenticates with current token
2. Client re-subscribes to active rooms (ride tracking, order tracking)
3. Server sends missed events since disconnect (buffered for 30s)

```javascript
socket.on('connect', () => {
  // Re-join active ride room
  if (activeRideId) {
    socket.emit('ride:rejoin', { rideId: activeRideId });
  }
});
```

## Rate Limiting

| Event Type | Limit | Window |
|-----------|-------|--------|
| `message:send` | 30 | 60s |
| `driver:location` | 60 | 60s |
| `message:typing` | 10 | 10s |
| All other events | 100 | 60s |
