import { ThrottlerModuleOptions } from '@nestjs/throttler'

export const throttlerConfig: ThrottlerModuleOptions = [
  {
    name: 'short',
    ttl: 1000, // 1 second
    limit: 30, // 30 req/sec per IP
  },
  {
    name: 'medium',
    ttl: 60000, // 1 minute
    limit: 200, // 200 req/min per IP
  },
  {
    name: 'long',
    ttl: 3600000, // 1 hour
    limit: 5000, // 5000 req/hour per IP
  },
]

export const authThrottlerConfig = {
  // Stricter for auth endpoints
  ttl: 60000,
  limit: 10, // 10 attempts per minute per IP
}
