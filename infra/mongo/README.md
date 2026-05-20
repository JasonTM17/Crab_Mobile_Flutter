# DB Hot-Path Indexes

Migration scripts for the indexes that the most frequent query paths
depend on. Run them once per environment.

## Postgres (per-service SQL)

Each service owns its own SQL file under `apps/backend/<service>/src/migrations/`.
Apply with `psql`:

```bash
psql "$DATABASE_URL" -f apps/backend/auth-service/src/migrations/20260520-add-hot-indexes.sql
psql "$DATABASE_URL" -f apps/backend/user-service/src/migrations/20260520-add-hot-indexes.sql
psql "$DATABASE_URL" -f apps/backend/ride-service/src/migrations/20260520-add-hot-indexes.sql
psql "$DATABASE_URL" -f apps/backend/food-service/src/migrations/20260520-add-hot-indexes.sql
psql "$DATABASE_URL" -f apps/backend/payment-service/src/migrations/20260520-add-hot-indexes.sql
```

All scripts are idempotent (`CREATE INDEX IF NOT EXISTS`). Each file has a
commented `-- DOWN` section if a rollback is needed.

## MongoDB

```bash
mongosh "$MONGODB_URI" < infra/mongo/indexes.js
```

Covers ride driver locations (2dsphere + status), chat messages
(`roomId, createdAt`), notification fanout, and rating reviews.

## What's covered

| Domain         | Hot path                                     | Index                                            |
| -------------- | -------------------------------------------- | ------------------------------------------------ |
| auth           | login by phone                               | `idx_users_phone`                                |
| auth           | OTP latest by phone                          | `idx_otps_phone_created`                         |
| user           | default address                              | `idx_addresses_user_default`                     |
| ride           | driver dispatch                              | `idx_rides_status_driver_created`                |
| ride           | rider history                                | `idx_rides_rider_created`                        |
| ride (mongo)   | nearest available drivers                    | `idx_driver_locations_geo` (2dsphere)            |
| food           | restaurant dashboard active orders           | `idx_orders_status_restaurant`                   |
| food           | user order history                           | `idx_orders_user_created`                        |
| food           | menu availability filter                     | `idx_menu_items_restaurant_available`            |
| payment        | wallet history                               | `idx_transactions_wallet_created`                |
| payment        | one-wallet-per-user invariant                | `uniq_wallets_user`                              |
| chat (mongo)   | room timeline                                | `idx_messages_room_created`                      |
| notification   | user feed unread first                       | `idx_notifications_user_read_created`            |

## Verify

```sql
-- Postgres
SELECT indexname FROM pg_indexes
 WHERE indexname LIKE 'idx_%' OR indexname LIKE 'uniq_%'
 ORDER BY indexname;
```

```js
// Mongo
db.driver_locations.getIndexes()
```
