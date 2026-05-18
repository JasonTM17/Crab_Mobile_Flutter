import { Injectable, Logger, OnModuleInit, OnModuleDestroy } from '@nestjs/common'
import { ConfigService } from '@nestjs/config'
import Redis from 'ioredis'

export interface SessionData {
  userId: string
  deviceId: string
  ip: string
  userAgent?: string
  createdAt: string
}

const SESSION_TTL_SECONDS = 15 * 60 // 15 minutes (matches JWT expiry)
const BLACKLIST_TTL_SECONDS = 24 * 60 * 60 // 24 hours

@Injectable()
export class SessionService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(SessionService.name)
  private redis!: Redis

  constructor(private readonly config: ConfigService) {}

  onModuleInit() {
    const redisUrl = this.config.get<string>('REDIS_URL', 'redis://localhost:6379')
    this.redis = new Redis(redisUrl, {
      maxRetriesPerRequest: 3,
      retryStrategy: (times) => Math.min(times * 100, 3000),
    })
    this.redis.on('connect', () => this.logger.log('Redis connected'))
    this.redis.on('error', (err) => this.logger.error('Redis error', err.message))
  }

  onModuleDestroy() {
    this.redis?.disconnect()
  }

  async createSession(sessionId: string, data: SessionData): Promise<void> {
    const key = `session:${sessionId}`
    await this.redis.setex(key, SESSION_TTL_SECONDS, JSON.stringify(data))
  }

  async getSession(sessionId: string): Promise<SessionData | null> {
    const key = `session:${sessionId}`
    const raw = await this.redis.get(key)
    if (!raw) return null
    return JSON.parse(raw)
  }

  async deleteSession(sessionId: string): Promise<void> {
    const key = `session:${sessionId}`
    await this.redis.del(key)
  }

  async deleteAllUserSessions(userId: string): Promise<void> {
    const pattern = `session:*`
    const keys = await this.redis.keys(pattern)
    for (const key of keys) {
      const raw = await this.redis.get(key)
      if (raw) {
        const data: SessionData = JSON.parse(raw)
        if (data.userId === userId) {
          await this.redis.del(key)
        }
      }
    }
  }

  async blacklistToken(jti: string, expiresInSeconds?: number): Promise<void> {
    const key = `blacklist:${jti}`
    await this.redis.setex(key, expiresInSeconds ?? BLACKLIST_TTL_SECONDS, '1')
  }

  async isTokenBlacklisted(jti: string): Promise<boolean> {
    const key = `blacklist:${jti}`
    const result = await this.redis.get(key)
    return result !== null
  }

  // Rate limiting helper
  async incrementLoginAttempts(identifier: string): Promise<number> {
    const key = `login_attempts:${identifier}`
    const count = await this.redis.incr(key)
    if (count === 1) {
      await this.redis.expire(key, 15 * 60) // 15 min window
    }
    return count
  }

  async getLoginAttempts(identifier: string): Promise<number> {
    const key = `login_attempts:${identifier}`
    const count = await this.redis.get(key)
    return count ? parseInt(count, 10) : 0
  }

  async resetLoginAttempts(identifier: string): Promise<void> {
    const key = `login_attempts:${identifier}`
    await this.redis.del(key)
  }
}
