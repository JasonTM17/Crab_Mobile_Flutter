# Real-time Architecture

## Overview

Crab uses **Socket.IO** over WebSocket as the realtime transport for ride tracking, food order updates, chat, and notifications. Socket.IO is mounted on the API gateway and sits in front of dedicated handler classes inside each domain service.

For the wire-level event reference (payload shapes, namespaces, error envelopes) see [WEBSOCKET_EVENTS.md](./WEBSOCKET_EVENTS.md). This document focuses on **how it works under the hood** and **how to extend it safely**.

## Topology

```
┌──────────────┐       ┌──────────────────────────────────────────┐
│ Mobile / Web │ ──ws──▶│  Gateway (:3000)                         │
└──────────────┘        │  • io = new Server(httpServer)            │
                        │  • JWT handshake middleware               │
                        │  • Namespaces: /ride /food /chat /notif   │
                        └──┬────────────┬────────────┬──────────────┘
                           │            │            │
                  publish  ▼   publish  ▼   publish  ▼
                        ┌──────────────────────────────────────────┐
                        │   Redis pub/sub  (single source of truth) │
                        └──┬────────────┬────────────┬──────────────┘
                           │            │            │
                           ▼            ▼            ▼
                    ┌─────────┐  ┌─────────┐  ┌──────────────┐
                    │  Ride   │  │  Food   │  │ Notification │
                    │ service │  │ service │  │  service     │
                    └─────────┘  └─────────┘  └──────────────┘
```

The gateway is the **only** process that owns sockets. Domain services emit by **publishing on Redis channels** the gateway is subscribed to — this means any number of gateway pods can be added behind a load balancer and a single emit is fanned out to whichever pod holds the recipient's socket.

## Authentication

Every connection is authenticated during the Socket.IO handshake.

1. Client passes the access token: `io(url, { auth: { token: 'Bearer <jwt>' } })`.
2. Gateway middleware verifies the token against the same Ed25519 JWKS the REST API uses.
3. On success the validated user is stored on `socket.data.user`. Reject otherwise — the socket is never `connect`ed.

Tokens are validated on **handshake only**. If a token expires mid-session the socket is allowed to live until disconnect, but any *server → server* refresh attempts must use a service token. Riders/drivers should refresh and reconnect; the client SDK does this automatically on `disconnect`.

## Namespaces and rooms

Each domain has its own namespace so a connection only carries the events it cares about. Within a namespace, **rooms** scope broadcasts to a specific party.

| Namespace | Rooms                                       | Used by                       |
|-----------|---------------------------------------------|-------------------------------|
| `/ride`   | `ride:<rideId>`, `driver:<driverId>`        | Rider, driver, dispatcher     |
| `/food`   | `order:<orderId>`, `restaurant:<rId>`       | Customer, restaurant, courier |
| `/chat`   | `conv:<conversationId>`                     | Conversation participants     |
| `/notif`  | `user:<userId>`                             | Per-user channel              |

A rider joining `/ride` is auto-`socket.join(\`ride:${rideId}\`)` after the gateway looks up their active rides. Drivers join their own `driver:<id>` room on connect so the matching engine can push assignment offers.

## Lifecycle: a ride

```
rider     gateway                ride-svc      driver
  │ ws connect (JWT)               │              │
  │───────────────▶ verify, join ride:<id>        │
  │                                │              │
  │ ride:request ───────────────▶ create row     │
  │                                │ enqueue match│
  │ ◀── ride:status REQUESTED      │              │
  │                                │ pick best    │
  │                                ├─ driver:<id> ▶ ride:offered
  │                                │              │
  │                                │              │ ride:accept ▶
  │                                │ assign       │
  │ ◀── ride:status MATCHED ───────│              │
  │ ◀── ride:location ◀────────────────────────── │ (every 3s)
  │ ◀── ride:status IN_PROGRESS ───│              │
  │ ◀── ride:status COMPLETED ─────│              │
```

Status transitions are persisted by the ride service first; the WebSocket event is published **after** the database write succeeds so the wire state never gets ahead of the source of truth.

## Lifecycle: a food order

```
customer  gateway              food-svc      restaurant     courier
  │ wsorder:place ─────────────▶ row PLACED  │              │
  │ ◀── order:status PLACED      │           │              │
  │                              ├─ restaurant:<id> ▶ order:incoming
  │                              │           │ accept ▶     │
  │ ◀── order:status CONFIRMED ──│           │              │
  │ ◀── order:status PREPARING ──│           │              │
  │                              ├─ matching engine ▶       │
  │ ◀── order:status PICKED_UP ──│           │     ▶ assign │
  │ ◀── order:courier_location ◀──────────── │     ◀────────│
  │ ◀── order:status DELIVERED ──│           │              │
```

See [FOOD_DELIVERY.md](./FOOD_DELIVERY.md) for the full status machine.

## Driver location stream

Drivers emit `driver:location` every **3 seconds** while online. The gateway:

1. Validates the payload (`{ lat, lng, heading?, speed? }`) — geo bounds, schema, timestamp not in the future.
2. Updates `drivers:online` in Redis (sorted set, TTL 30s) so the matching engine sees fresh positions.
3. If the driver is on an active ride, broadcasts `ride:location` into `ride:<rideId>` so the rider sees the dot move.

If updates stop for 30 seconds the driver is marked **stale** and removed from the matching pool. They get a soft `driver:stale_warning` first; an explicit `driver:offline` at 60s.

## Backpressure and rate limiting

- Per-socket rate limit on **client → server** events: 30 events/sec, sliding window (Redis). Exceeding closes the socket with reason `RATE_LIMITED`.
- Per-user **server → client** broadcast cap: 60 events/sec; bursts buffer briefly then coalesce (latest-wins for `*_location` events).
- Heartbeat: Socket.IO ping every 25s, timeout at 60s. Mobile clients also send an app-level heartbeat every 60s so we can distinguish *network* drops from *app suspended*.

## Reliability and at-least-once delivery

WebSocket delivery is best-effort. For events that **must** reach the client (order status, payment confirmation), the pattern is:

1. Publish the event over WebSocket.
2. Persist the same event to a `realtime_events` Mongo collection with `delivered: false`.
3. On client reconnect, the gateway replays any undelivered events for that user, then marks `delivered: true`.

This gives the client a clean reconnect story without forcing every consumer to track a cursor.

## Local development

```bash
docker compose up postgres redis      # required infra
pnpm --filter @crab/gateway dev        # mounts Socket.IO
pnpm --filter @crab/ride-service dev
```

Then in a browser console:

```javascript
const socket = io('http://localhost:3000/ride', {
  auth: { token: 'Bearer ' + localStorage.access_token }
});
socket.on('ride:status', console.log);
```

`docker compose --profile observability up` adds Loki + Tempo so you can correlate a socket event with the trace that produced it. See [DEPLOYMENT.md](./DEPLOYMENT.md) for the full observability stack.

## Testing

- **Unit:** mock `@nestjs/websockets` `WsResponse` returns. Gateways are testable like any other class.
- **Integration:** spin up gateway + redis with `tests/setup-realtime.ts`, connect a `socket.io-client`, assert event sequences.
- **Load:** `tests/load/ride-flow.js` exercises a full ride over WebSocket with k6's `ws` module. p95 < 500ms is the gate.

## Adding a new realtime event

1. Define the payload type in `packages/socket-events/src/<namespace>.ts` so both client and server share it.
2. Add a handler method in the gateway class (server → client) or a `@SubscribeMessage('your:event')` (client → server).
3. If domain services need to emit it, publish on the matching Redis channel — never `socket.emit` directly from a service process.
4. Document the event in [WEBSOCKET_EVENTS.md](./WEBSOCKET_EVENTS.md) in the same PR.

Skipping step 4 will fail the API doc CI gate.
