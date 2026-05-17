# Crab Super App - Socket Events

Type-safe Socket.IO event definitions shared between backend services and the Flutter mobile client.

## Installation

```typescript
import { RIDE_EVENTS, CHAT_EVENTS, RideRequestPayload } from '@crab/socket-events';
```

## Event Constants

### Ride Events (`/ride` namespace)

| Constant | Value | Direction |
|----------|-------|-----------|
| `RIDE_EVENTS.REQUEST` | `ride:request` | Client → Server |
| `RIDE_EVENTS.ACCEPT` | `ride:accept` | Client → Server |
| `RIDE_EVENTS.CANCEL` | `ride:cancel` | Client → Server |
| `RIDE_EVENTS.NEW_REQUEST` | `ride:new_request` | Server → Client |
| `RIDE_EVENTS.ACCEPTED` | `ride:accepted` | Server → Client |
| `RIDE_EVENTS.DRIVER_LOCATION` | `ride:driver_location` | Server → Client |
| `RIDE_EVENTS.STATUS_CHANGED` | `ride:status_changed` | Server → Client |

### Food Events (`/food` namespace)

| Constant | Value | Direction |
|----------|-------|-----------|
| `FOOD_EVENTS.ORDER_TRACK` | `order:track` | Client → Server |
| `FOOD_EVENTS.ORDER_STATUS_CHANGED` | `order:status_changed` | Server → Client |
| `FOOD_EVENTS.ORDER_DRIVER_ASSIGNED` | `order:driver_assigned` | Server → Client |

### Chat Events (`/chat` namespace)

| Constant | Value | Direction |
|----------|-------|-----------|
| `CHAT_EVENTS.MESSAGE_SEND` | `message:send` | Client → Server |
| `CHAT_EVENTS.MESSAGE_NEW` | `message:new` | Server → Client |
| `CHAT_EVENTS.MESSAGE_TYPING` | `message:typing` | Bidirectional |

## Payload Types

All event payloads are fully typed:

```typescript
import { RideRequestPayload, MessageSendPayload } from '@crab/socket-events';

socket.emit(RIDE_EVENTS.REQUEST, payload satisfies RideRequestPayload);
```

## Build

```bash
pnpm --filter @crab/socket-events build
```
