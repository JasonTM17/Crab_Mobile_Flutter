-- Crab Super App local production-like schema.
-- Run through the root script:
--   pnpm run db:migrate

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(32) UNIQUE NOT NULL,
  "passwordHash" VARCHAR(255) NOT NULL,
  "firstName" VARCHAR(120) NOT NULL,
  "lastName" VARCHAR(120) NOT NULL,
  role VARCHAR(32) NOT NULL DEFAULT 'RIDER',
  status VARCHAR(40) NOT NULL DEFAULT 'ACTIVE',
  "avatarUrl" TEXT,
  "phoneVerified" BOOLEAN NOT NULL DEFAULT false,
  "emailVerified" BOOLEAN NOT NULL DEFAULT false,
  "lockedUntil" TIMESTAMP,
  "failedLoginCount" INTEGER NOT NULL DEFAULT 0,
  "lastLoginAt" TIMESTAMP,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS refresh_tokens (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  token VARCHAR(128) NOT NULL,
  "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  revoked BOOLEAN NOT NULL DEFAULT false,
  "expiresAt" TIMESTAMP NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS otps (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  phone VARCHAR(32) NOT NULL,
  code VARCHAR(16) NOT NULL,
  purpose VARCHAR(40) NOT NULL,
  attempts INTEGER NOT NULL DEFAULT 0,
  verified BOOLEAN NOT NULL DEFAULT false,
  "expiresAt" TIMESTAMP NOT NULL,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS login_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  identifier VARCHAR(255) NOT NULL,
  ip VARCHAR(64) NOT NULL,
  success BOOLEAN NOT NULL DEFAULT false,
  "userAgent" TEXT,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS devices (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  "deviceId" VARCHAR(255) NOT NULL,
  "deviceName" VARCHAR(255),
  platform VARCHAR(32),
  "fcmToken" TEXT,
  "lastIp" VARCHAR(64),
  "lastActiveAt" TIMESTAMP,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE ("userId", "deviceId")
);

CREATE TABLE IF NOT EXISTS profiles (
  "userId" UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  email VARCHAR(255) NOT NULL,
  phone VARCHAR(32) NOT NULL,
  "firstName" VARCHAR(120) NOT NULL,
  "lastName" VARCHAR(120) NOT NULL,
  role VARCHAR(32) NOT NULL DEFAULT 'RIDER',
  status VARCHAR(40) NOT NULL DEFAULT 'ACTIVE',
  "avatarUrl" TEXT,
  "dateOfBirth" DATE,
  gender VARCHAR(40),
  bio VARCHAR(500),
  "preferredLanguage" VARCHAR(8) NOT NULL DEFAULT 'vi',
  "preferredCurrency" VARCHAR(8) NOT NULL DEFAULT 'VND',
  "emergencyContactName" VARCHAR(255),
  "emergencyContactPhone" VARCHAR(32),
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS addresses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  label VARCHAR(120) NOT NULL,
  address TEXT NOT NULL,
  latitude DECIMAL(10, 7) NOT NULL,
  longitude DECIMAL(10, 7) NOT NULL,
  "isDefault" BOOLEAN NOT NULL DEFAULT false,
  notes TEXT,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS driver_profiles (
  "userId" UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  "licenseNumber" VARCHAR(80) UNIQUE NOT NULL,
  "licenseExpiry" TIMESTAMP NOT NULL,
  "vehicleType" VARCHAR(40) NOT NULL,
  "vehiclePlate" VARCHAR(40) NOT NULL,
  "vehicleBrand" VARCHAR(80) NOT NULL,
  "vehicleModel" VARCHAR(80) NOT NULL,
  "vehicleColor" VARCHAR(40),
  "vehicleYear" INTEGER,
  "insuranceNumber" VARCHAR(80),
  "insuranceExpiry" DATE,
  "verificationStatus" VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  "rejectionReason" TEXT,
  rating DECIMAL(3, 2) NOT NULL DEFAULT 0,
  "totalRides" INTEGER NOT NULL DEFAULT 0,
  "isOnline" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS merchant_profiles (
  "userId" UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  "businessName" VARCHAR(255) NOT NULL,
  "businessType" VARCHAR(120) NOT NULL,
  "taxId" VARCHAR(80) UNIQUE NOT NULL,
  "businessLicense" VARCHAR(120),
  "businessAddress" TEXT NOT NULL,
  latitude DECIMAL(10, 7),
  longitude DECIMAL(10, 7),
  "verificationStatus" VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  "rejectionReason" TEXT,
  rating DECIMAL(3, 2) NOT NULL DEFAULT 0,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS verification_docs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  "docType" VARCHAR(40) NOT NULL,
  "fileUrl" TEXT NOT NULL,
  verified BOOLEAN NOT NULL DEFAULT false,
  "verifiedBy" UUID,
  "verifiedAt" TIMESTAMP,
  "uploadedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rides (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  rider_id UUID NOT NULL,
  driver_id UUID,
  pickup_lat DECIMAL(10, 7) NOT NULL,
  pickup_lng DECIMAL(10, 7) NOT NULL,
  pickup_address TEXT NOT NULL,
  dropoff_lat DECIMAL(10, 7) NOT NULL,
  dropoff_lng DECIMAL(10, 7) NOT NULL,
  dropoff_address TEXT NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED',
  fare DECIMAL(12, 2),
  distance_km DECIMAL(8, 3),
  duration_min INTEGER,
  surge_multiplier DECIMAL(4, 2) NOT NULL DEFAULT 1.0,
  vehicle_type VARCHAR(40) NOT NULL DEFAULT 'BIKE',
  scheduled_at TIMESTAMP,
  is_scheduled BOOLEAN NOT NULL DEFAULT false,
  sos_triggered BOOLEAN NOT NULL DEFAULT false,
  sos_at TIMESTAMP,
  cancellation_reason TEXT,
  payment_method VARCHAR(40),
  paid BOOLEAN NOT NULL DEFAULT false,
  pickup_time TIMESTAMP,
  start_time TIMESTAMP,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  accepted_at TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS restaurants (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "merchantId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  "coverImageUrl" TEXT,
  "logoUrl" TEXT,
  phone VARCHAR(32) NOT NULL,
  address TEXT NOT NULL,
  city VARCHAR(120),
  latitude DECIMAL(10, 7) NOT NULL,
  longitude DECIMAL(10, 7) NOT NULL,
  "cuisineType" VARCHAR(80) NOT NULL DEFAULT 'OTHER',
  rating DECIMAL(3, 2) NOT NULL DEFAULT 0,
  "totalReviews" INTEGER NOT NULL DEFAULT 0,
  "totalOrders" INTEGER NOT NULL DEFAULT 0,
  "avgPrepTimeMin" INTEGER NOT NULL DEFAULT 30,
  "deliveryFee" DECIMAL(10, 2) NOT NULL DEFAULT 15000,
  "minOrderValue" DECIMAL(10, 2) NOT NULL DEFAULT 0,
  "openTime" VARCHAR(16) NOT NULL DEFAULT '08:00',
  "closeTime" VARCHAR(16) NOT NULL DEFAULT '22:00',
  "isOpen" BOOLEAN NOT NULL DEFAULT true,
  "isFeatured" BOOLEAN NOT NULL DEFAULT false,
  "acceptsCod" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS menu_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "restaurantId" UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  "sortOrder" INTEGER NOT NULL DEFAULT 0,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS menu_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "restaurantId" UUID NOT NULL REFERENCES restaurants(id) ON DELETE CASCADE,
  "categoryId" UUID NOT NULL REFERENCES menu_categories(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  "imageUrl" TEXT,
  price DECIMAL(10, 2) NOT NULL,
  "discountPrice" DECIMAL(10, 2),
  "isAvailable" BOOLEAN NOT NULL DEFAULT true,
  "isFeatured" BOOLEAN NOT NULL DEFAULT false,
  "totalSold" INTEGER NOT NULL DEFAULT 0,
  "prepTimeMin" INTEGER NOT NULL DEFAULT 15,
  options JSONB,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "customerId" UUID NOT NULL REFERENCES users(id),
  "restaurantId" UUID NOT NULL REFERENCES restaurants(id),
  "driverId" UUID REFERENCES users(id),
  status VARCHAR(20) NOT NULL DEFAULT 'PLACED',
  "deliveryLat" DECIMAL(10, 7) NOT NULL,
  "deliveryLng" DECIMAL(10, 7) NOT NULL,
  "deliveryAddress" TEXT NOT NULL,
  "deliveryNotes" TEXT,
  subtotal DECIMAL(12, 2) NOT NULL,
  "deliveryFee" DECIMAL(12, 2) NOT NULL DEFAULT 0,
  discount DECIMAL(12, 2) NOT NULL DEFAULT 0,
  total DECIMAL(12, 2) NOT NULL,
  "paymentMethod" VARCHAR(40) NOT NULL DEFAULT 'WALLET',
  paid BOOLEAN NOT NULL DEFAULT false,
  "promoCode" VARCHAR(80),
  "confirmedAt" TIMESTAMP,
  "preparedAt" TIMESTAMP,
  "pickedUpAt" TIMESTAMP,
  "deliveredAt" TIMESTAMP,
  "cancelledAt" TIMESTAMP,
  "cancellationReason" TEXT,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS order_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "orderId" UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
  "menuItemId" UUID NOT NULL REFERENCES menu_items(id),
  name VARCHAR(255) NOT NULL,
  price DECIMAL(10, 2) NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  notes TEXT,
  options JSONB
);

CREATE TABLE IF NOT EXISTS wallets (
  "userId" UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  balance DECIMAL(14, 2) NOT NULL DEFAULT 0,
  currency VARCHAR(8) NOT NULL DEFAULT 'VND',
  "pendingBalance" DECIMAL(14, 2) NOT NULL DEFAULT 0,
  frozen BOOLEAN NOT NULL DEFAULT false,
  version INTEGER NOT NULL DEFAULT 1,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type VARCHAR(40) NOT NULL,
  amount DECIMAL(14, 2) NOT NULL,
  currency VARCHAR(8) NOT NULL DEFAULT 'VND',
  status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
  "balanceAfter" DECIMAL(14, 2),
  "paymentMethod" VARCHAR(80),
  reference VARCHAR(255),
  "referenceId" VARCHAR(255),
  description TEXT,
  metadata JSONB,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS promos (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(80) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  type VARCHAR(32) NOT NULL,
  value DECIMAL(14, 2) NOT NULL,
  "minOrderValue" DECIMAL(14, 2) NOT NULL DEFAULT 0,
  "maxDiscount" DECIMAL(14, 2),
  "applicableTo" VARCHAR(32) NOT NULL DEFAULT 'ALL',
  "usageLimitPerUser" INTEGER NOT NULL DEFAULT 1,
  "totalUsageLimit" INTEGER,
  "totalUsed" INTEGER NOT NULL DEFAULT 0,
  "validFrom" TIMESTAMP NOT NULL,
  "validUntil" TIMESTAMP NOT NULL,
  "isActive" BOOLEAN NOT NULL DEFAULT true,
  "firstRideOnly" BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS promo_usages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "userId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  "promoId" UUID NOT NULL REFERENCES promos(id) ON DELETE CASCADE,
  "referenceId" VARCHAR(255),
  "discountAmount" DECIMAL(14, 2) NOT NULL,
  "usedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS promo_codes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code VARCHAR(80) UNIQUE NOT NULL,
  description TEXT NOT NULL,
  discount_percent DECIMAL(5, 2) NOT NULL,
  max_discount DECIMAL(12, 2),
  min_order_amount DECIMAL(12, 2) NOT NULL DEFAULT 0,
  max_uses INTEGER NOT NULL DEFAULT 100,
  current_uses INTEGER NOT NULL DEFAULT 0,
  valid_from TIMESTAMPTZ NOT NULL,
  valid_until TIMESTAMPTZ NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  "raterId" UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  "targetId" UUID NOT NULL,
  "targetType" VARCHAR(32) NOT NULL,
  context VARCHAR(32) NOT NULL,
  "referenceId" UUID NOT NULL,
  score SMALLINT NOT NULL CHECK (score >= 1 AND score <= 5),
  review TEXT,
  tags JSONB,
  photos JSONB,
  flagged BOOLEAN NOT NULL DEFAULT false,
  "flagReason" TEXT,
  hidden BOOLEAN NOT NULL DEFAULT false,
  "createdAt" TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS rating_aggregates (
  "targetId" UUID NOT NULL,
  "targetType" VARCHAR(32) NOT NULL,
  "avgScore" DECIMAL(3, 2) NOT NULL DEFAULT 0,
  "totalRatings" INTEGER NOT NULL DEFAULT 0,
  "count1" INTEGER NOT NULL DEFAULT 0,
  "count2" INTEGER NOT NULL DEFAULT 0,
  "count3" INTEGER NOT NULL DEFAULT 0,
  "count4" INTEGER NOT NULL DEFAULT 0,
  "count5" INTEGER NOT NULL DEFAULT 0,
  "updatedAt" TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  PRIMARY KEY ("targetId", "targetType")
);

CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
CREATE INDEX IF NOT EXISTS idx_users_phone ON users(phone);
CREATE INDEX IF NOT EXISTS idx_users_role ON users(role);
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_id ON refresh_tokens("userId");
CREATE INDEX IF NOT EXISTS idx_otps_phone_purpose ON otps(phone, purpose);
CREATE INDEX IF NOT EXISTS idx_login_attempts_identifier_created ON login_attempts(identifier, "createdAt");
CREATE INDEX IF NOT EXISTS idx_addresses_user_id ON addresses("userId");
CREATE INDEX IF NOT EXISTS idx_verification_docs_user_type ON verification_docs("userId", "docType");
CREATE INDEX IF NOT EXISTS idx_rides_rider ON rides(rider_id);
CREATE INDEX IF NOT EXISTS idx_rides_driver ON rides(driver_id);
CREATE INDEX IF NOT EXISTS idx_rides_status ON rides(status);
CREATE INDEX IF NOT EXISTS idx_rides_created ON rides(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_restaurants_merchant_id ON restaurants("merchantId");
CREATE INDEX IF NOT EXISTS idx_restaurants_city ON restaurants(city);
CREATE INDEX IF NOT EXISTS idx_menu_categories_restaurant_id ON menu_categories("restaurantId");
CREATE INDEX IF NOT EXISTS idx_menu_items_restaurant_id ON menu_items("restaurantId");
CREATE INDEX IF NOT EXISTS idx_menu_items_category_id ON menu_items("categoryId");
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders("customerId");
CREATE INDEX IF NOT EXISTS idx_orders_restaurant_id ON orders("restaurantId");
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders("createdAt");
CREATE INDEX IF NOT EXISTS idx_transactions_user_created ON transactions("userId", "createdAt");
CREATE INDEX IF NOT EXISTS idx_transactions_reference_id ON transactions("referenceId");
CREATE INDEX IF NOT EXISTS idx_promos_code ON promos(code);
CREATE INDEX IF NOT EXISTS idx_promo_usages_user_promo ON promo_usages("userId", "promoId");
CREATE INDEX IF NOT EXISTS idx_ratings_target ON ratings("targetId", "targetType");
CREATE INDEX IF NOT EXISTS idx_ratings_rater ON ratings("raterId");
CREATE UNIQUE INDEX IF NOT EXISTS idx_ratings_reference_unique ON ratings("referenceId");

CREATE OR REPLACE FUNCTION set_updated_at_camel()
RETURNS TRIGGER AS $$
BEGIN
  NEW."updatedAt" = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION set_updated_at_snake()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DO $$
DECLARE
  camel_table TEXT;
  snake_table TEXT;
BEGIN
  FOREACH camel_table IN ARRAY ARRAY[
    'users', 'devices', 'profiles', 'addresses', 'driver_profiles',
    'merchant_profiles', 'restaurants', 'menu_items', 'orders', 'wallets',
    'promos', 'rating_aggregates'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated_at ON %I', camel_table, camel_table);
    EXECUTE format(
      'CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION set_updated_at_camel()',
      camel_table,
      camel_table
    );
  END LOOP;

  FOREACH snake_table IN ARRAY ARRAY['rides', 'promo_codes']
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%I_updated_at ON %I', snake_table, snake_table);
    EXECUTE format(
      'CREATE TRIGGER trg_%I_updated_at BEFORE UPDATE ON %I FOR EACH ROW EXECUTE FUNCTION set_updated_at_snake()',
      snake_table,
      snake_table
    );
  END LOOP;
END;
$$;
