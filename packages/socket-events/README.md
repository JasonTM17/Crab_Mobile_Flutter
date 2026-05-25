# Crab Super App - Socket Events

Type-safe Socket.IO event definitions shared between backend services and the Flutter mobile client.

## Installation

```typescript
import type { ChatMessagePayload, RideRequestPayload } from '@crab/socket-events';
```

## Event Map

### Ride Events (`/ride` namespace)

| Event | Direction |
|-------|-----------|
| `ride:request` | Client → Server |
| `ride:new_request` | Server → Client |
| `ride:request_received` | Server → Client |
| `ride:join` | Client → Server |
| `ride:joined` | Server → Client |
| `ride:cancel` | Client → Server |
| `ride:matched` | Server → Client |
| `ride:accepted` | Server → Client |
| `ride:location` | Bidirectional |
| `ride:status` | Server → Client |
| `ride:completed` | Server → Client |
| `ride:cancelled` | Server → Client |

### Food Events (`/food` namespace)

| Event | Direction |
|-------|-----------|
| `order:placed` | Server → Client |
| `order:status` | Server → Client |
| `order:tracking` | Server → Client |
| `order:ready` | Server → Client |

### Chat Events (`/chat` namespace)

| Event | Direction |
|-------|-----------|
| `chat:message` | Bidirectional |
| `chat:typing` | Bidirectional |
| `chat:read` | Client → Server |

## Payload Types

All event payloads are fully typed:

```typescript
import type { RideNamespaceEvents, RideRequestPayload } from '@crab/socket-events';

const payload = {
  riderId: 'uuid',
  pickup: { lat: 10.7769, lng: 106.7009, address: '123 Nguyen Hue' },
  dropoff: { lat: 10.8021, lng: 106.7146, address: '456 Le Van Sy' },
  paymentMethod: 'wallet',
} satisfies RideRequestPayload;

const event: keyof RideNamespaceEvents = 'ride:request';
socket.emit(event, payload);
```

## Build

```bash
pnpm --filter @crab/socket-events build
```
