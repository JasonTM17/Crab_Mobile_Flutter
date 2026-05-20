-- Hot-path indexes for user-service
-- Date: 2026-05-20

-- Default address lookup (used at checkout / ride booking).
CREATE INDEX IF NOT EXISTS idx_addresses_user_default
  ON addresses (user_id, is_default);

-- Driver verification lookup by status.
CREATE INDEX IF NOT EXISTS idx_driver_profiles_status
  ON driver_profiles (verification_status);

-- Merchant verification lookup by status.
CREATE INDEX IF NOT EXISTS idx_merchant_profiles_status
  ON merchant_profiles (verification_status);

-- Verification doc fanout by user.
CREATE INDEX IF NOT EXISTS idx_verification_docs_user_type
  ON verification_docs (user_id, doc_type);

-- DOWN
-- DROP INDEX IF EXISTS idx_addresses_user_default;
-- DROP INDEX IF EXISTS idx_driver_profiles_status;
-- DROP INDEX IF EXISTS idx_merchant_profiles_status;
-- DROP INDEX IF EXISTS idx_verification_docs_user_type;
