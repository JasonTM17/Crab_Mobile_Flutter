-- Hot-path indexes for food-service
-- Date: 2026-05-20

-- Restaurant dashboard: pending/confirmed orders by restaurant.
CREATE INDEX IF NOT EXISTS idx_orders_status_restaurant
  ON orders (status, restaurant_id);

-- User order history.
CREATE INDEX IF NOT EXISTS idx_orders_user_created
  ON orders (user_id, created_at DESC);

-- Active orders lookup (driver / kitchen polling).
CREATE INDEX IF NOT EXISTS idx_orders_status_created
  ON orders (status, created_at DESC)
  WHERE status IN ('pending', 'confirmed', 'preparing', 'out_for_delivery');

-- Menu item availability filter (restaurant menu screen).
CREATE INDEX IF NOT EXISTS idx_menu_items_restaurant_available
  ON menu_items (restaurant_id, is_available);

-- Restaurant search by city + open status.
CREATE INDEX IF NOT EXISTS idx_restaurants_city_open
  ON restaurants (city, is_open);

-- DOWN
-- DROP INDEX IF EXISTS idx_orders_status_restaurant;
-- DROP INDEX IF EXISTS idx_orders_user_created;
-- DROP INDEX IF EXISTS idx_orders_status_created;
-- DROP INDEX IF EXISTS idx_menu_items_restaurant_available;
-- DROP INDEX IF EXISTS idx_restaurants_city_open;
