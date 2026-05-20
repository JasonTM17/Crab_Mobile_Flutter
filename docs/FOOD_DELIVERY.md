# Food Delivery

## Overview

Food orders flow through three principals: **customer**, **restaurant**, **courier**. The order state machine is owned by `food-service`; courier dispatch piggy-backs on the same matching infrastructure used for rides ([RIDE_MATCHING.md](./RIDE_MATCHING.md)). This doc covers the full lifecycle.

For wire events see [WEBSOCKET_EVENTS.md](./WEBSOCKET_EVENTS.md). For schema see [DATABASE.md](./DATABASE.md).

## Order state machine

`apps/backend/food-service/src/orders/orders.service.ts` enforces this transition table. Any HTTP / socket request to move an order outside it returns `409 Conflict`.

```
PLACED    ──▶  CONFIRMED   ──▶  PREPARING   ──▶  READY    ──▶  PICKED_UP   ──▶  DELIVERED
   │              │                  │              │
   ▼              ▼                  ▼              ▼
              CANCELLED         CANCELLED       CANCELLED   (after PICKED_UP cancellation requires support)
```

| From         | Allowed next             | Actor              |
|--------------|--------------------------|--------------------|
| `PLACED`     | `CONFIRMED`, `CANCELLED` | Restaurant / customer |
| `CONFIRMED`  | `PREPARING`, `CANCELLED` | Restaurant         |
| `PREPARING`  | `READY`, `CANCELLED`     | Restaurant         |
| `READY`      | `PICKED_UP`, `CANCELLED` | Courier (system)   |
| `PICKED_UP`  | `DELIVERED`              | Courier            |
| `DELIVERED`  | —                        | terminal           |
| `CANCELLED`  | —                        | terminal           |

## Cart and pricing

Carts are server-authoritative. The mobile client mutates the cart over REST (`POST /carts/items`, `PATCH /carts/items/:id`) and the server recomputes line totals on every change. Three reasons:

1. Prices change while items sit in a cart — restaurants can mark items 86'd or update prices server-side.
2. Promo codes need server validation (per-user limits, min order, expiry).
3. Delivery fee depends on courier availability at checkout time and is computed server-side.

Pricing breakdown stored on `food_orders`:

| Field            | Description                                    |
|------------------|------------------------------------------------|
| `subtotal`       | Sum of line item prices                        |
| `delivery_fee`   | Distance-based fee, computed at checkout       |
| `service_fee`    | Flat platform fee, currently 5%                |
| `discount`       | Promo discount, validated against `promotions` |
| `tax`            | VAT 8% (configurable per-region)               |
| `total`          | `subtotal + delivery_fee + service_fee + tax - discount` |

The cart preview endpoint (`GET /carts/preview`) returns the same breakdown so checkout never surprises the customer with a different number.

## Lifecycle in detail

### 1. Place order

```
POST /orders
```

The `orders.service.placeOrder()` flow inside one transaction:

1. Re-validate the cart (items still available, prices unchanged or accept-able).
2. Validate the promo code (if any) against `PromosService` — see `apps/backend/payment-service/src/promo/promo.service.spec.ts` for the test surface.
3. Reserve payment via `PaymentsService.authorize(amount)`. On failure, roll back.
4. Insert `food_orders` row at `PLACED`, plus `food_order_items` rows.
5. Publish `order:incoming` to `restaurant:<rId>` and `order:status PLACED` to the customer.

If anything in step 2–4 fails the transaction is rolled back and the customer gets the original error code (no partial order is ever persisted).

### 2. Restaurant accepts

The restaurant tablet receives `order:incoming` and either:

- **Confirms** within 90 s → state transitions to `CONFIRMED`. Auto-progresses to `PREPARING` after a configurable delay (default 30 s) so restaurants don't have to click twice.
- **Rejects** → `CANCELLED` with reason `RESTAURANT_REJECTED`. Customer is refunded automatically.
- **Times out** (no action in 90 s) → auto-`CANCELLED` with reason `RESTAURANT_TIMEOUT`.

### 3. Preparing

Status is `PREPARING`. The restaurant marks each item as ready in their POS; the order moves to `READY` only when **every** line item is marked. The customer sees a live "X of Y items ready" counter via `order:item_progress` events.

Estimated prep time = `max(item.prep_time_minutes)` from the menu, plus a 2-minute buffer for plating. The customer's "expected delivery" timer is anchored on this estimate plus the courier's projected ETA.

### 4. Courier dispatch

When an order hits `READY` (or 5 minutes before, configurable), `DispatchService` enqueues a `food-matching` BullMQ job with the same shape as ride matching, biased to:

- Couriers within 1 km of the restaurant (smaller radius than rides).
- Couriers without an active food/ride (no batching in v1).
- Courier vehicle type matches order size (`bike` for ≤5 items, `car` for ≥6 or `requires_car: true`).

Scoring reuses `MatchingService` from ride-service — `food-service` calls it as a library. Score weights are different:

```
food_score = 0.6 * (1 - normalized_distance) + 0.2 * normalized_rating + 0.2 * (1 - active_orders)
```

The third term gently discourages stacking multiple food orders on one courier.

### 5. Pickup

Courier arrives at the restaurant, scans the order QR (or taps "Picked up" in the app). The state moves to `PICKED_UP` and `order:courier_location` starts streaming on the customer's socket. Pickup is the **last cancellation point** — after this, the customer must contact support.

### 6. Delivery

Courier taps "Delivered" within the geofence of the dropoff address (or overrides with a reason). State moves to `DELIVERED`, payment is captured (the original auth from step 1.3 is settled), the rating prompt is queued, and the courier returns to the available pool.

## Cancellation policy

| State        | Customer can cancel                | Restaurant can cancel | Refund?              |
|--------------|------------------------------------|------------------------|----------------------|
| `PLACED`     | Yes, free                          | Yes, with reason       | Full refund          |
| `CONFIRMED`  | Yes if < 60s after CONFIRMED, else fee | Yes, with reason  | Full or partial      |
| `PREPARING`  | No (support only)                  | Only if item unavailable | Partial             |
| `READY`+     | No (support only)                  | No                     | Case by case        |

The cancellation fee policy lives in `pricing_rules` (DB) so ops can tune without a code deploy.

## Restaurant operations

Restaurants get a thin web view (or tablet app) at `/restaurant/<id>` that shows:

- Live incoming orders with countdown to auto-cancel.
- Active prep queue with per-item progress checkboxes.
- "Mark item 86'd" toggle that updates `menu_items.available = false` and the customer-facing list in real time.

Daily revenue and order count come from the same `restaurants.daily_summary` view used by the admin dashboard ([API.md](./API.md#restaurants-summary)).

## Failure modes

| Symptom                                | Likely cause                                | Where to look                                  |
|----------------------------------------|---------------------------------------------|------------------------------------------------|
| Order stuck at `PLACED`                | Restaurant socket not connected             | `restaurant:<id>` join logs in gateway         |
| Order stuck at `READY` for > 5 min     | No couriers in 1 km radius                  | Same diagnostics as ride matching             |
| Customer not getting status updates    | Stale token, multiple tabs                  | `realtime_events` replay in [REALTIME.md](./REALTIME.md) |
| Payment auth held but order cancelled  | Refund worker stuck                         | `payment-service` logs, `refunds` queue depth  |
| Promo code rejected client-side only   | Mobile cache out of date                    | Always re-validate on server (we do)           |

## Testing

- Unit: `apps/backend/food-service/src/orders/orders.service.spec.ts` (state transitions), `apps/backend/payment-service/src/promo/promo.service.spec.ts` (discount math, per-user limits).
- Integration: `tests/integration/food-flow.spec.ts` drives `place → confirm → prepare → ready → pickup → deliver` with Postgres + Redis + the dispatch queue.
- Load: `tests/load/order-flow.js` simulates 100 customers + 30 restaurants + 50 couriers, gate p95 < 800ms.
