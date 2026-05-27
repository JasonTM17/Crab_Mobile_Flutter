-- Crab Super App local production-like demo data.
-- Run through the root script:
--   pnpm run db:seed

INSERT INTO users (
  id,
  email,
  phone,
  "passwordHash",
  "firstName",
  "lastName",
  role,
  status,
  "phoneVerified",
  "emailVerified"
)
VALUES
  (
    '00000000-0000-4000-8000-000000000001',
    'admin@crab.app',
    '+84900000001',
    '$2b$12$iUGrZ6Oog0xyfwSamNT/TuWwqsZc3e9V3ombfDdmmeSQXNZXeBLdu',
    'Admin',
    'Crab',
    'ADMIN',
    'ACTIVE',
    true,
    true
  ),
  (
    '00000000-0000-4000-8000-000000000002',
    'rider@crab.app',
    '+84900000002',
    '$2b$12$g8Gp7oIfPLF.thBEvHz.Ae1n0OieVmcLZTqMSi2DlOeG0WDdiGETi',
    'Linh',
    'Rider',
    'RIDER',
    'ACTIVE',
    true,
    true
  ),
  (
    '00000000-0000-4000-8000-000000000003',
    'driver@crab.app',
    '+84900000003',
    '$2b$12$3YU042pO3u96TyktiaEcgePoSmPUDm2i73QEdCGWlxSxhqqybAaQy',
    'Minh',
    'Driver',
    'DRIVER',
    'ACTIVE',
    true,
    true
  ),
  (
    '00000000-0000-4000-8000-000000000004',
    'merchant@crab.app',
    '+84900000004',
    '$2b$12$g8Gp7oIfPLF.thBEvHz.Ae1n0OieVmcLZTqMSi2DlOeG0WDdiGETi',
    'Hana',
    'Merchant',
    'MERCHANT',
    'ACTIVE',
    true,
    true
  )
ON CONFLICT (email) DO UPDATE SET
  phone = EXCLUDED.phone,
  "passwordHash" = EXCLUDED."passwordHash",
  "firstName" = EXCLUDED."firstName",
  "lastName" = EXCLUDED."lastName",
  role = EXCLUDED.role,
  status = EXCLUDED.status,
  "phoneVerified" = EXCLUDED."phoneVerified",
  "emailVerified" = EXCLUDED."emailVerified",
  "updatedAt" = NOW();

INSERT INTO profiles (
  "userId",
  email,
  phone,
  "firstName",
  "lastName",
  role,
  status,
  "preferredLanguage",
  "preferredCurrency",
  bio
)
VALUES
  (
    '00000000-0000-4000-8000-000000000001',
    'admin@crab.app',
    '+84900000001',
    'Admin',
    'Crab',
    'ADMIN',
    'ACTIVE',
    'en',
    'VND',
    'Portfolio demo admin account'
  ),
  (
    '00000000-0000-4000-8000-000000000002',
    'rider@crab.app',
    '+84900000002',
    'Linh',
    'Rider',
    'RIDER',
    'ACTIVE',
    'vi',
    'VND',
    'Portfolio demo mobile rider account'
  ),
  (
    '00000000-0000-4000-8000-000000000003',
    'driver@crab.app',
    '+84900000003',
    'Minh',
    'Driver',
    'DRIVER',
    'ACTIVE',
    'vi',
    'VND',
    'Portfolio demo driver account'
  ),
  (
    '00000000-0000-4000-8000-000000000004',
    'merchant@crab.app',
    '+84900000004',
    'Hana',
    'Merchant',
    'MERCHANT',
    'ACTIVE',
    'vi',
    'VND',
    'Portfolio demo restaurant merchant account'
  )
ON CONFLICT ("userId") DO UPDATE SET
  email = EXCLUDED.email,
  phone = EXCLUDED.phone,
  "firstName" = EXCLUDED."firstName",
  "lastName" = EXCLUDED."lastName",
  role = EXCLUDED.role,
  status = EXCLUDED.status,
  bio = EXCLUDED.bio,
  "updatedAt" = NOW();

INSERT INTO addresses (id, "userId", label, address, latitude, longitude, "isDefault", notes)
VALUES
  (
    '10000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000002',
    'Home',
    '42 Nguyen Hue, District 1, Ho Chi Minh City',
    10.7769000,
    106.7009000,
    true,
    'Primary portfolio demo address'
  )
ON CONFLICT (id) DO UPDATE SET
  address = EXCLUDED.address,
  latitude = EXCLUDED.latitude,
  longitude = EXCLUDED.longitude,
  "isDefault" = EXCLUDED."isDefault",
  "updatedAt" = NOW();

INSERT INTO wallets ("userId", balance, currency, "pendingBalance", frozen)
VALUES
  ('00000000-0000-4000-8000-000000000001', 5000000, 'VND', 0, false),
  ('00000000-0000-4000-8000-000000000002', 1250000, 'VND', 0, false),
  ('00000000-0000-4000-8000-000000000003', 2300000, 'VND', 0, false),
  ('00000000-0000-4000-8000-000000000004', 850000, 'VND', 0, false)
ON CONFLICT ("userId") DO UPDATE SET
  balance = EXCLUDED.balance,
  currency = EXCLUDED.currency,
  "pendingBalance" = EXCLUDED."pendingBalance",
  frozen = EXCLUDED.frozen,
  "updatedAt" = NOW();

INSERT INTO driver_profiles (
  "userId",
  "licenseNumber",
  "licenseExpiry",
  "vehicleType",
  "vehiclePlate",
  "vehicleBrand",
  "vehicleModel",
  "vehicleColor",
  "vehicleYear",
  "insuranceNumber",
  "insuranceExpiry",
  "verificationStatus",
  rating,
  "totalRides",
  "isOnline"
)
VALUES (
  '00000000-0000-4000-8000-000000000003',
  'CRAB-DL-2026',
  '2028-12-31',
  'MOTORBIKE',
  '59A1-20260',
  'Honda',
  'Air Blade',
  'Green',
  2024,
  'INS-CRAB-2026',
  '2028-12-31',
  'APPROVED',
  4.91,
  312,
  true
)
ON CONFLICT ("userId") DO UPDATE SET
  "licenseNumber" = EXCLUDED."licenseNumber",
  "verificationStatus" = EXCLUDED."verificationStatus",
  rating = EXCLUDED.rating,
  "totalRides" = EXCLUDED."totalRides",
  "isOnline" = EXCLUDED."isOnline",
  "updatedAt" = NOW();

INSERT INTO merchant_profiles (
  "userId",
  "businessName",
  "businessType",
  "taxId",
  "businessLicense",
  "businessAddress",
  latitude,
  longitude,
  "verificationStatus",
  rating
)
VALUES (
  '00000000-0000-4000-8000-000000000004',
  'Crab Food Demo Group',
  'Restaurant',
  'CRAB-TAX-2026',
  'CRAB-BIZ-2026',
  '88 Le Loi, District 1, Ho Chi Minh City',
  10.7731000,
  106.7000000,
  'APPROVED',
  4.85
)
ON CONFLICT ("userId") DO UPDATE SET
  "businessName" = EXCLUDED."businessName",
  "businessType" = EXCLUDED."businessType",
  "verificationStatus" = EXCLUDED."verificationStatus",
  rating = EXCLUDED.rating,
  "updatedAt" = NOW();

INSERT INTO restaurants (
  id,
  "merchantId",
  name,
  description,
  "coverImageUrl",
  "logoUrl",
  phone,
  address,
  city,
  latitude,
  longitude,
  "cuisineType",
  rating,
  "totalReviews",
  "totalOrders",
  "avgPrepTimeMin",
  "deliveryFee",
  "minOrderValue",
  "openTime",
  "closeTime",
  "isOpen",
  "isFeatured",
  "acceptsCod"
)
VALUES
  (
    '20000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000004',
    'Crab Rice Studio',
    'Hot rice bowls, grilled demo plates, and quick lunch combos.',
    'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5',
    '+84281234567',
    '24 Tran Hung Dao, District 1, Ho Chi Minh City',
    'Ho Chi Minh City',
    10.7725000,
    106.6980000,
    'VIETNAMESE',
    4.85,
    1240,
    5300,
    18,
    0,
    30000,
    '08:00',
    '22:30',
    true,
    true,
    true
  ),
  (
    '20000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000004',
    'Crab Noodle Lab',
    'Vietnamese noodles, fresh herbs, and delivery-friendly sides.',
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
    'https://images.unsplash.com/photo-1551218808-94e220e084d2',
    '+84281234568',
    '88 Le Loi, District 1, Ho Chi Minh City',
    'Ho Chi Minh City',
    10.7731000,
    106.7000000,
    'NOODLES',
    4.79,
    980,
    4100,
    15,
    10000,
    25000,
    '09:00',
    '22:00',
    true,
    true,
    true
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  rating = EXCLUDED.rating,
  "isOpen" = EXCLUDED."isOpen",
  "isFeatured" = EXCLUDED."isFeatured",
  "updatedAt" = NOW();

INSERT INTO menu_categories (id, "restaurantId", name, description, "sortOrder", "isActive")
VALUES
  ('21000000-0000-4000-8000-000000000001', '20000000-0000-4000-8000-000000000001', 'Rice Bowls', 'Fast portfolio demo meals', 1, true),
  ('21000000-0000-4000-8000-000000000002', '20000000-0000-4000-8000-000000000001', 'Drinks', 'Coffee, tea, and citrus drinks', 2, true),
  ('21000000-0000-4000-8000-000000000003', '20000000-0000-4000-8000-000000000002', 'Noodles', 'Hot noodle bowls', 1, true)
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  "sortOrder" = EXCLUDED."sortOrder",
  "isActive" = EXCLUDED."isActive";

INSERT INTO menu_items (
  id,
  "restaurantId",
  "categoryId",
  name,
  description,
  "imageUrl",
  price,
  "discountPrice",
  "isAvailable",
  "isFeatured",
  "totalSold",
  "prepTimeMin",
  options
)
VALUES
  (
    '22000000-0000-4000-8000-000000000001',
    '20000000-0000-4000-8000-000000000001',
    '21000000-0000-4000-8000-000000000001',
    'Signature Crab Rice Bowl',
    'Grilled pork, egg, pickles, and demo sauce.',
    'https://images.unsplash.com/photo-1603133872878-684f208fb84b',
    68000,
    59000,
    true,
    true,
    920,
    12,
    '{"spiceLevels":["mild","medium","hot"]}'::jsonb
  ),
  (
    '22000000-0000-4000-8000-000000000002',
    '20000000-0000-4000-8000-000000000001',
    '21000000-0000-4000-8000-000000000002',
    'Iced Milk Coffee',
    'Vietnamese iced coffee for the demo menu.',
    'https://images.unsplash.com/photo-1559496417-e7f25cb247f3',
    29000,
    NULL,
    true,
    false,
    610,
    5,
    NULL
  ),
  (
    '22000000-0000-4000-8000-000000000003',
    '20000000-0000-4000-8000-000000000002',
    '21000000-0000-4000-8000-000000000003',
    'Crab Noodle Bowl',
    'Warm broth, herbs, and delivery-ready toppings.',
    'https://images.unsplash.com/photo-1569718212165-3a8278d5f624',
    72000,
    65000,
    true,
    true,
    700,
    15,
    '{"addons":["egg","extra herbs","chili oil"]}'::jsonb
  )
ON CONFLICT (id) DO UPDATE SET
  name = EXCLUDED.name,
  price = EXCLUDED.price,
  "discountPrice" = EXCLUDED."discountPrice",
  "isAvailable" = EXCLUDED."isAvailable",
  "isFeatured" = EXCLUDED."isFeatured",
  "updatedAt" = NOW();

INSERT INTO transactions (
  id,
  "userId",
  type,
  amount,
  currency,
  status,
  "balanceAfter",
  "paymentMethod",
  reference,
  "referenceId",
  description,
  metadata
)
VALUES
  (
    '30000000-0000-4000-8000-000000000001',
    '00000000-0000-4000-8000-000000000002',
    'TOP_UP',
    500000,
    'VND',
    'COMPLETED',
    1250000,
    'DEMO_BANK',
    'DEMO-TOPUP-001',
    'demo-topup-001',
    'Portfolio demo wallet top-up',
    '{"source":"seed"}'::jsonb
  ),
  (
    '30000000-0000-4000-8000-000000000002',
    '00000000-0000-4000-8000-000000000002',
    'PAYMENT',
    -68000,
    'VND',
    'COMPLETED',
    1182000,
    'WALLET',
    'DEMO-FOOD-001',
    '22000000-0000-4000-8000-000000000001',
    'Signature Crab Rice Bowl order',
    '{"source":"seed","domain":"food"}'::jsonb
  )
ON CONFLICT (id) DO UPDATE SET
  amount = EXCLUDED.amount,
  status = EXCLUDED.status,
  "balanceAfter" = EXCLUDED."balanceAfter",
  description = EXCLUDED.description;

INSERT INTO promos (
  id,
  code,
  name,
  description,
  type,
  value,
  "minOrderValue",
  "maxDiscount",
  "applicableTo",
  "usageLimitPerUser",
  "totalUsageLimit",
  "validFrom",
  "validUntil",
  "isActive",
  "firstRideOnly"
)
VALUES (
  '40000000-0000-4000-8000-000000000001',
  'PORTFOLIO26',
  'Portfolio Demo Promo',
  'Reusable local demo promo for ride and food flows.',
  'PERCENTAGE',
  15,
  30000,
  50000,
  'ALL',
  3,
  1000,
  '2026-01-01',
  '2027-01-01',
  true,
  false
)
ON CONFLICT (code) DO UPDATE SET
  name = EXCLUDED.name,
  description = EXCLUDED.description,
  value = EXCLUDED.value,
  "validUntil" = EXCLUDED."validUntil",
  "isActive" = EXCLUDED."isActive",
  "updatedAt" = NOW();

INSERT INTO promo_codes (
  id,
  code,
  description,
  discount_percent,
  max_discount,
  min_order_amount,
  max_uses,
  current_uses,
  valid_from,
  valid_until,
  is_active
)
VALUES (
  '41000000-0000-4000-8000-000000000001',
  'PORTFOLIO26',
  'Portfolio demo promo code',
  15,
  50000,
  30000,
  1000,
  0,
  '2026-01-01',
  '2027-01-01',
  true
)
ON CONFLICT (code) DO UPDATE SET
  description = EXCLUDED.description,
  discount_percent = EXCLUDED.discount_percent,
  valid_until = EXCLUDED.valid_until,
  is_active = EXCLUDED.is_active,
  updated_at = NOW();

INSERT INTO rating_aggregates (
  "targetId",
  "targetType",
  "avgScore",
  "totalRatings",
  "count1",
  "count2",
  "count3",
  "count4",
  "count5"
)
VALUES
  ('20000000-0000-4000-8000-000000000001', 'RESTAURANT', 4.85, 1240, 4, 10, 41, 310, 875),
  ('00000000-0000-4000-8000-000000000003', 'DRIVER', 4.91, 312, 1, 2, 8, 55, 246)
ON CONFLICT ("targetId", "targetType") DO UPDATE SET
  "avgScore" = EXCLUDED."avgScore",
  "totalRatings" = EXCLUDED."totalRatings",
  "count1" = EXCLUDED."count1",
  "count2" = EXCLUDED."count2",
  "count3" = EXCLUDED."count3",
  "count4" = EXCLUDED."count4",
  "count5" = EXCLUDED."count5",
  "updatedAt" = NOW();

-- Demo accounts:
--   Admin:    admin@crab.app / Admin123!
--   Rider:    rider@crab.app / User123!
--   Driver:   driver@crab.app / Driver123!
--   Merchant: merchant@crab.app / User123!
