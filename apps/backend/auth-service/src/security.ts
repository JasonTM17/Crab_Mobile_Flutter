import type { ConfigService } from '@nestjs/config'

const TEST_JWT_SECRET = 'test-only-jwt-secret'
const TEST_REFRESH_SECRET = 'test-only-refresh-secret'

function getRequiredSecret(
  config: ConfigService,
  key: 'JWT_SECRET' | 'JWT_REFRESH_SECRET',
  testSecret: string,
): string {
  const env = config.get<string>('NODE_ENV')
  const secret = config.get<string>(key)

  if (secret && secret !== 'change-me-in-production' && secret !== 'refresh-secret') {
    return secret
  }

  if (env === 'test') {
    return testSecret
  }

  throw new Error(`${key} must be set`)
}

export function getRequiredJwtSecret(config: ConfigService): string {
  return getRequiredSecret(config, 'JWT_SECRET', TEST_JWT_SECRET)
}

export function getRequiredRefreshSecret(config: ConfigService): string {
  return getRequiredSecret(config, 'JWT_REFRESH_SECRET', TEST_REFRESH_SECRET)
}
