# Database Schema

## PostgreSQL Schema

Used by: Auth, User, Ride, Food, Payment, Rating services.

### users

```sql
CREATE TABLE users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(255) NOT NULL,
  phone         VARCHAR(20) UNIQUE,
  avatar_url    TEXT,
  role          VARCHAR(20) NOT NULL DEFAULT 'rider',  -- rider, driver, restaurant_owner, admin
  is_active     BOOLEAN DEFAULT true,
  is_verified   BOOLEAN DEFAULT false,
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone ON users(phone);
CREATE INDEX idx_users_role ON users(role);
```

### refresh_tokens

```sql
CREATE TABLE refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  VARCHAR(255) NOT NULL,
  expires_at  TIMESTAMP WITH TIME ZONE NOT NULL,
  revoked     BOOLEAN DEFAULT false,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_expires ON refresh_tokens(expires_at);
```

### driver_profiles

```sql
CREATE TABLE driver_profiles (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  license_number  VARCHAR(50) NOT NULL,
  vehicle_type    VARCHAR(20) NOT NULL,  -- bike, car, car_plus
  vehicle_plate   VARCHAR(20) NOT NULL,
  vehicle_model   VARCHAR(100),
  is_online       BOOLEAN DEFAULT false,
  current_lat     DECIMAL(10, 8),
  current_lng     DECIMAL(11, 8),
  rating_avg      DECIMAL(3, 2) DEFAULT 5.00,
  total_rides     INTEGER DEFAULT 0,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_driver_location ON driver_profiles(current_lat, current_lng) WHERE is_online = true;
CREATE INDEX idx_driver_vehicle ON driver_profiles(vehicle_type);
```

### rides

```sql
CREATE TABLE rides (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rider_id          UUID NOT NULL REFERENCES users(id),
  driver_id         UUID REFERENCES users(id),
  status            VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
  vehicle_type      VARCHAR(20) NOT NULL,
  pickup_lat        DECIMAL(10, 8) NOT NULL,
  pickup_lng        DECIMAL(11, 8) NOT NULL,
  pickup_address    TEXT NOT NULL,
  dropoff_lat       DECIMAL(10, 8) NOT NULL,
  dropoff_lng       DECIMAL(11, 8) NOT NULL,
  dropoff_address   TEXT NOT NULL,
  distance_km       DECIMAL(6, 2),
  duration_minutes  INTEGER,
  estimated_fare    INTEGER NOT NULL,
  actual_fare       INTEGER,
  cancellation_fee  INTEGER DEFAULT 0,
  cancelled_by      VARCHAR(10),  -- rider, driver
  cancel_reason     TEXT,
  started_at        TIMESTAMP WITH TIME ZONE,
  completed_at      TIMESTAMP WITH TIME ZONE,
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_rides_rider ON rides(rider_id);
CREATE INDEX idx_rides_driver ON rides(driver_id);
CREATE INDEX idx_rides_status ON rides(status);
CREATE INDEX idx_rides_created ON rides(created_at DESC);
```

### restaurants

```sql
CREATE TABLE restaurants (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  owner_id      UUID NOT NULL REFERENCES users(id),
  name          VARCHAR(255) NOT NULL,
  description   TEXT,
  category      VARCHAR(50) NOT NULL,
  image_url     TEXT,
  address       TEXT NOT NULL,
  lat           DECIMAL(10, 8) NOT NULL,
  lng           DECIMAL(11, 8) NOT NULL,
  phone         VARCHAR(20),
  is_open       BOOLEAN DEFAULT true,
  open_time     TIME,
  close_time    TIME,
  delivery_fee  INTEGER DEFAULT 15000,
  min_order     INTEGER DEFAULT 0,
  rating_avg    DECIMAL(3, 2) DEFAULT 5.00,
  total_orders  INTEGER DEFAULT 0,
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_restaurants_location ON restaurants(lat, lng);
CREATE INDEX idx_restaurants_category ON restaurants(category);
CREATE INDEX idx_restaurants_owner ON restaurants(owner_id);
```

### menu_items

```sql
CREATE TABLE menu_items (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  restaurant_id   UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  category_name   VARCHAR(100) NOT NULL,
  name            VARCHAR(255) NOT NULL,
  description     TEXT,
  price           INTEGER NOT NULL,
  image_url       TEXT,
  is_available    BOOLEAN DEFAULT true,
  options         JSONB DEFAULT '[]',
  sort_order      INTEGER DEFAULT 0,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_menu_restaurant ON menu_items(restaurant_id);
```

### food_orders

```sql
CREATE TABLE food_orders (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id       UUID NOT NULL REFERENCES users(id),
  restaurant_id     UUID NOT NULL REFERENCES restaurants(id),
  driver_id         UUID REFERENCES users(id),
  status            VARCHAR(20) NOT NULL DEFAULT 'PLACED',
  items             JSONB NOT NULL,
  subtotal          INTEGER NOT NULL,
  delivery_fee      INTEGER NOT NULL,
  total             INTEGER NOT NULL,
  delivery_lat      DECIMAL(10, 8) NOT NULL,
  delivery_lng      DECIMAL(11, 8) NOT NULL,
  delivery_address  TEXT NOT NULL,
  note              TEXT,
  estimated_time    INTEGER,
  confirmed_at      TIMESTAMP WITH TIME ZONE,
  picked_up_at      TIMESTAMP WITH TIME ZONE,
  delivered_at      TIMESTAMP WITH TIME ZONE,
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_food_orders_customer ON food_orders(customer_id);
CREATE INDEX idx_food_orders_restaurant ON food_orders(restaurant_id);
CREATE INDEX idx_food_orders_driver ON food_orders(driver_id);
CREATE INDEX idx_food_orders_status ON food_orders(status);
```

### wallets

```sql
CREATE TABLE wallets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID UNIQUE NOT NULL REFERENCES users(id),
  balance     BIGINT NOT NULL DEFAULT 0,
  currency    VARCHAR(3) DEFAULT 'VND',
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_wallets_user ON wallets(user_id);
```

### transactions

```sql
CREATE TABLE transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id       UUID NOT NULL REFERENCES wallets(id),
  type            VARCHAR(30) NOT NULL,  -- topup, ride_payment, food_payment, refund, withdrawal
  amount          BIGINT NOT NULL,
  balance_after   BIGINT NOT NULL,
  reference_id    UUID,
  reference_type  VARCHAR(20),  -- ride, food_order
  description     TEXT,
  metadata        JSONB DEFAULT '{}',
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_transactions_wallet ON transactions(wallet_id);
CREATE INDEX idx_transactions_type ON transactions(type);
CREATE INDEX idx_transactions_created ON transactions(created_at DESC);
```

### ratings

```sql
CREATE TABLE ratings (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reviewer_id   UUID NOT NULL REFERENCES users(id),
  target_id     UUID NOT NULL,
  target_type   VARCHAR(20) NOT NULL,  -- driver, rider, restaurant
  reference_id  UUID,
  reference_type VARCHAR(20),  -- ride, food_order
  score         SMALLINT NOT NULL CHECK (score >= 1 AND score <= 5),
  comment       TEXT,
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX idx_ratings_target ON ratings(target_id, target_type);
CREATE INDEX idx_ratings_reviewer ON ratings(reviewer_id);
CREATE UNIQUE INDEX idx_ratings_unique ON ratings(reviewer_id, reference_id, reference_type);
```

---

## MongoDB Schema

Used by: Chat, Notification services.

### messages (Collection)

```javascript
{
  _id: ObjectId,
  conversationId: ObjectId,  // ref: conversations
  senderId: String,          // UUID from PostgreSQL users
  text: String,
  type: String,              // text, image, location, system
  imageUrl: String,          // if type === 'image'
  location: {                // if type === 'location'
    lat: Number,
    lng: Number
  },
  readBy: [String],          // array of user UUIDs
  createdAt: Date,
  updatedAt: Date
}

// Indexes
{ conversationId: 1, createdAt: -1 }
{ senderId: 1 }
```

### conversations (Collection)

```javascript
{
  _id: ObjectId,
  participants: [String],    // array of user UUIDs
  type: String,              // direct, ride, food_order
  referenceId: String,       // ride or food_order UUID
  lastMessage: {
    text: String,
    senderId: String,
    createdAt: Date
  },
  createdAt: Date,
  updatedAt: Date
}

// Indexes
{ participants: 1 }
{ referenceId: 1, type: 1 }
{ updatedAt: -1 }
```

### notifications (Collection)

```javascript
{
  _id: ObjectId,
  userId: String,            // target user UUID
  type: String,              // ride_accepted, order_ready, payment_received, promo, system
  title: String,
  body: String,
  data: Object,              // arbitrary payload (rideId, orderId, etc.)
  read: Boolean,
  pushSent: Boolean,
  createdAt: Date
}

// Indexes
{ userId: 1, read: 1, createdAt: -1 }
{ userId: 1, createdAt: -1 }
{ createdAt: 1, expireAfterSeconds: 2592000 }  // TTL: 30 days
```

---

## Redis Data Structures

| Key Pattern | Type | TTL | Purpose |
|-------------|------|-----|----------|
| `session:{userId}` | Hash | 7d | User session data |
| `rate:{ip}:{endpoint}` | String (counter) | 60s | Rate limiting |
| `rate:user:{userId}` | String (counter) | 60s | Per-user rate limiting |
| `driver:location:{driverId}` | GeoHash | - | Real-time driver location |
| `drivers:online` | Sorted Set | - | Online drivers by area |
| `ride:active:{rideId}` | Hash | 1h | Active ride state cache |
| `user:profile:{userId}` | Hash | 5m | Profile cache |
| `restaurant:menu:{id}` | String (JSON) | 10m | Menu cache |
| `socket:adapter:*` | Pub/Sub | - | Socket.IO Redis adapter |

---

## Entity Relationship Diagram

```
users 1───1 wallets
  │
  ├──1 driver_profiles
  │
  ├──* rides (as rider)
  ├──* rides (as driver)
  │
  ├──* restaurants (as owner)
  │
  ├──* food_orders (as customer)
  ├──* food_orders (as driver)
  │
  ├──* ratings (as reviewer)
  ├──* ratings (as target)
  │
  └──* refresh_tokens

restaurants 1──* menu_items
restaurants 1──* food_orders

wallets 1──* transactions
```
