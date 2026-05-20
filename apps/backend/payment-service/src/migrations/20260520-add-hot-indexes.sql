-- Hot-path indexes for payment-service
-- Date: 2026-05-20

-- Wallet history pagination.
CREATE INDEX IF NOT EXISTS idx_transactions_wallet_created
  ON transactions (wallet_id, created_at DESC);

-- One wallet per user (race-safe ensure).
CREATE UNIQUE INDEX IF NOT EXISTS uniq_wallets_user
  ON wallets (user_id);

-- Pending settlement scan.
CREATE INDEX IF NOT EXISTS idx_transactions_status_created
  ON transactions (status, created_at)
  WHERE status IN ('pending', 'processing');

-- Promo code lookup.
CREATE INDEX IF NOT EXISTS idx_promos_code_active
  ON promos (code, is_active);

-- Per-user promo usage cap enforcement.
CREATE INDEX IF NOT EXISTS idx_promo_usages_user_promo
  ON promo_usages (user_id, promo_id);

-- DOWN
-- DROP INDEX IF EXISTS idx_transactions_wallet_created;
-- DROP INDEX IF EXISTS uniq_wallets_user;
-- DROP INDEX IF EXISTS idx_transactions_status_created;
-- DROP INDEX IF EXISTS idx_promos_code_active;
-- DROP INDEX IF EXISTS idx_promo_usages_user_promo;
