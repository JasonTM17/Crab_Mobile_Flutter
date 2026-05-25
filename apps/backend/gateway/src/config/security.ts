import type { ConfigService } from '@nestjs/config'

type NodeEnv = 'production' | 'test' | string | undefined

const DEV_ORIGINS = [
  'http://localhost:3000',
  'http://localhost:5173',
  'http://localhost:8080',
  'http://127.0.0.1:3000',
  'http://127.0.0.1:5173',
  'http://127.0.0.1:8080',
]

const TEST_JWT_SECRET = 'test-only-jwt-secret'

function isProduction(env: NodeEnv): boolean {
  return env === 'production'
}

function splitOrigins(value: string): string[] {
  return value
    .split(',')
    .map((origin) => origin.trim())
    .filter(Boolean)
}

export function getRequiredJwtSecret(config: ConfigService): string {
  const env = config.get<string>('NODE_ENV')
  const secret = config.get<string>('JWT_SECRET')

  if (secret && secret !== 'change-me-in-production') {
    return secret
  }

  if (env === 'test') {
    return TEST_JWT_SECRET
  }

  throw new Error('JWT_SECRET must be set')
}

export function getAllowedCorsOrigins(config: ConfigService, key: string): string[] {
  const env = config.get<string>('NODE_ENV')
  const raw = config.get<string>(key)

  if (!raw) {
    if (isProduction(env)) {
      throw new Error(`${key} must be set`)
    }
    return DEV_ORIGINS
  }

  const origins = splitOrigins(raw)
  if (origins.includes('*')) {
    if (isProduction(env)) {
      throw new Error(`${key} cannot contain wildcard origin in production`)
    }
    return DEV_ORIGINS
  }

  if (origins.length === 0) {
    throw new Error(`${key} must include at least one origin`)
  }

  return origins
}
