-- Crab Platform Database Schema
-- Run: psql -U crab -d crab -f scripts/schema.sql

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- Users table
CREATE TABLE IF NOT EXISTS users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email         VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  full_name     VARCHAR(255) NOT NULL,
  phone         VARCHAR(20) UNIQUE,
  avatar_url    TEXT,
  role          VARCHAR(20) NOT NULL DEFAULT 'rider',
  is_active     BOOLEAN DEFAULT true,
  is_verified   BOOLEAN DEFAULT false,
  created_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at    TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);

-- Refresh tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  token_hash  VARCHAR(255) NOT NULL,
  expires_at  TIMESTAMP WITH TIME ZONE NOT NULL,
  revoked     BOOLEAN DEFAULT false,
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user ON refresh_tokens(user_id);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_expires ON refresh_tokens(expires_at);

-- Driver profiles
CREATE TABLE IF NOT EXISTS driver_profiles (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id         UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  license_number  VARCHAR(50) NOT NULL,
  vehicle_type    VARCHAR(20) NOT NULL,
  vehicle_plate   VARCHAR(20) NOT NULL,
  vehicle_model   VARCHAR(100),
  is_online       BOOLEAN DEFAULT false,
  current_lat     DECIMAL(10, 8),
  current_lng     DECIMAL(11, 8),
  rating_avg      DECIMAL(3, 2) DEFAULT 5.00,
  total_rides     INTEGER DEFAULT 0,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_driver_location ON driver_profiles(current_lat, current_lng) WHERE is_online = true;
CREATE INDEX IF NOT EXISTS idx_driver_vehicle ON driver_profiles(vehicle_type);

-- Rides
CREATE TABLE IF NOT EXISTS rides (
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
  cancelled_by      VARCHAR(10),
  cancel_reason     TEXT,
  started_at        TIMESTAMP WITH TIME ZONE,
  completed_at      TIMESTAMP WITH TIME ZONE,
  created_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at        TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rides_rider ON rides(rider_id);
CREATE INDEX IF NOT EXISTS idx_rides_driver ON rides(driver_id);
CREATE INDEX IF NOT EXISTS idx_rides_status ON rides(status);
CREATE INDEX IF NOT EXISTS idx_rides_created ON rides(created_at DESC);

-- Restaurants
CREATE TABLE IF NOT EXISTS restaurants (
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

CREATE INDEX IF NOT EXISTS idx_restaurants_location ON restaurants(lat, lng);
CREATE INDEX IF NOT EXISTS idx_restaurants_category ON restaurants(category);
CREATE INDEX IF NOT EXISTS idx_restaurants_owner ON restaurants(owner_id);

-- Menu items
CREATE TABLE IF NOT EXISTS menu_items (
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

CREATE INDEX IF NOT EXISTS idx_menu_restaurant ON menu_items(restaurant_id);

-- Food orders
CREATE TABLE IF NOT EXISTS food_orders (
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

CREATE INDEX IF NOT EXISTS idx_food_orders_customer ON food_orders(customer_id);
CREATE INDEX IF NOT EXISTS idx_food_orders_restaurant ON food_orders(restaurant_id);
CREATE INDEX IF NOT EXISTS idx_food_orders_driver ON food_orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_food_orders_status ON food_orders(status);

-- Wallets
CREATE TABLE IF NOT EXISTS wallets (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID UNIQUE NOT NULL REFERENCES users(id),
  balance     BIGINT NOT NULL DEFAULT 0,
  currency    VARCHAR(3) DEFAULT 'VND',
  created_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at  TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_wallets_user ON wallets(user_id);

-- Transactions
CREATE TABLE IF NOT EXISTS transactions (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  wallet_id       UUID NOT NULL REFERENCES wallets(id),
  type            VARCHAR(30) NOT NULL,
  amount          BIGINT NOT NULL,
  balance_after   BIGINT NOT NULL,
  reference_id    UUID,
  reference_type  VARCHAR(20),
  description     TEXT,
  metadata        JSONB DEFAULT '{}',
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_transactions_wallet ON transactions(wallet_id);
CREATE INDEX IF NOT EXISTS idx_transactions_type ON transactions(type);
CREATE INDEX IF NOT EXISTS idx_transactions_created ON transactions(created_at DESC);

-- Ratings
CREATE TABLE IF NOT EXISTS ratings (
  id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reviewer_id     UUID NOT NULL REFERENCES users(id),
  target_id       UUID NOT NULL,
  target_type     VARCHAR(20) NOT NULL,
  reference_id    UUID,
  reference_type  VARCHAR(20),
  score           SMALLINT NOT NULL CHECK (score >= 1 AND score <= 5),
  comment         TEXT,
  created_at      TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_ratings_target ON ratings(target_id, target_type);
CREATE INDEX IF NOT EXISTS idx_ratings_reviewer ON ratings(reviewer_id);
CREATE UNIQUE INDEX IF NOT EXISTS idx_ratings_unique ON ratings(reviewer_id, reference_id, reference_type);

-- Updated_at trigger function
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply updated_at triggers
DO $$
DECLARE
  t TEXT;
BEGIN
  FOR t IN SELECT unnest(ARRAY['users', 'rides', 'food_orders', 'wallets'])
  LOOP
    EXECUTE format('
      DROP TRIGGER IF EXISTS update_%s_updated_at ON %s;
      CREATE TRIGGER update_%s_updated_at
        BEFORE UPDATE ON %s
        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
    ', t, t, t, t);
  END LOOP;
END;
$$;
