export {
  CircuitBreaker,
  CircuitBreakerOpenError,
  CircuitBreakerTimeoutError,
} from './circuit-breaker';
export type { CircuitBreakerOptions, CircuitState } from './circuit-breaker';

export { CircuitBreakerFactory } from './circuit-breaker.factory';

export {
  RedisRateLimitGuard,
  RateLimit,
  RATE_LIMIT_METADATA,
  RATE_LIMIT_REDIS_TOKEN,
} from './redis-rate-limit.guard';
export type {
  RateLimitOptions,
  RateLimitKeyBy,
} from './redis-rate-limit.guard';

export {
  IdempotencyInterceptor,
  IDEMPOTENCY_REDIS_TOKEN,
} from './idempotency.interceptor';

export {
  GracefulShutdownService,
  SHUTDOWN_HOOKS_TOKEN,
} from './graceful-shutdown.service';
export type {
  GracefulShutdownConfig,
  NamedShutdownHook,
  ShutdownHook,
} from './graceful-shutdown.service';

export { ResilienceModule } from './resilience.module';
export type { ResilienceModuleOptions } from './resilience.module';
