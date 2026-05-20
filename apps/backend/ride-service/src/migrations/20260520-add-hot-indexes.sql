-- Hot-path indexes for ride-service
-- Date: 2026-05-20
-- Idempotent: uses IF NOT EXISTS so re-runs are safe.

-- Driver dispatch lookup: open rides matched to a driver, newest first.
CREATE INDEX IF NOT EXISTS idx_rides_status_driver_created
  ON rides (status, driver_id, created_at DESC);

-- Rider history: last N rides for a user.
CREATE INDEX IF NOT EXISTS idx_rides_rider_created
  ON rides (rider_id, created_at DESC);

-- Active ride lookup by status + vehicle for fare/surge calc.
CREATE INDEX IF NOT EXISTS idx_rides_status_vehicle
  ON rides (status, vehicle_type)
  WHERE status IN ('pending', 'matched', 'in_progress');

-- DOWN
-- DROP INDEX IF EXISTS idx_rides_status_driver_created;
-- DROP INDEX IF EXISTS idx_rides_rider_created;
-- DROP INDEX IF EXISTS idx_rides_status_vehicle;
