-- Hot-path indexes for auth-service
-- Date: 2026-05-20

-- Login lookup by phone.
CREATE INDEX IF NOT EXISTS idx_users_phone
  ON users (phone)
  WHERE phone IS NOT NULL;

-- Refresh token rotation lookup.
CREATE INDEX IF NOT EXISTS idx_refresh_tokens_user_revoked
  ON refresh_tokens (user_id, revoked_at);

-- Active OTP fetch (per phone, latest first).
CREATE INDEX IF NOT EXISTS idx_otps_phone_created
  ON otps (phone, created_at DESC);

-- Login attempt rate-limit window.
CREATE INDEX IF NOT EXISTS idx_login_attempts_user_created
  ON login_attempts (user_id, created_at DESC);

-- Per-user device list.
CREATE INDEX IF NOT EXISTS idx_devices_user_active
  ON devices (user_id, is_active);

-- DOWN
-- DROP INDEX IF EXISTS idx_users_phone;
-- DROP INDEX IF EXISTS idx_refresh_tokens_user_revoked;
-- DROP INDEX IF EXISTS idx_otps_phone_created;
-- DROP INDEX IF EXISTS idx_login_attempts_user_created;
-- DROP INDEX IF EXISTS idx_devices_user_active;
