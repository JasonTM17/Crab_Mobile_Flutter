import { DynamicModule, Global, Module, Provider, Type } from '@nestjs/common';
import { CircuitBreakerFactory } from './circuit-breaker.factory';
import {
  GracefulShutdownConfig,
  GracefulShutdownService,
  NamedShutdownHook,
  SHUTDOWN_HOOKS_TOKEN,
} from './graceful-shutdown.service';
import {
  IDEMPOTENCY_REDIS_TOKEN,
  IdempotencyInterceptor,
} from './idempotency.interceptor';
import {
  RATE_LIMIT_REDIS_TOKEN,
  RedisRateLimitGuard,
} from './redis-rate-limit.guard';

export interface ResilienceModuleOptions {
  /**
   * Existing provider (token, class, or factory) that resolves to an
   * `ioredis` Redis client. Used only when Redis-backed HTTP helpers are enabled.
   */
  redis?: {
    /** Token / class to inject. e.g. 'REDIS_CLIENT' or RedisService. */
    inject: string | symbol | Type<unknown>;
  };
  /**
   * Opt-in registration for Redis-backed HTTP helpers such as the rate-limit
   * guard and idempotency interceptor.
   */
  enableRedisHttpHelpers?: boolean;
  shutdown?: GracefulShutdownConfig;
  staticShutdownHooks?: NamedShutdownHook[];
}

/**
 * Global resilience module. Import once in the root AppModule per service.
 *
 * @example
 *   ResilienceModule.forRoot({ redis: { inject: 'REDIS_CLIENT' } })
 */
@Global()
@Module({})
export class ResilienceModule {
  static forRoot(options: ResilienceModuleOptions): DynamicModule {
    const providers: Provider[] = [
      CircuitBreakerFactory,
      {
        provide: SHUTDOWN_HOOKS_TOKEN,
        useValue: options.staticShutdownHooks ?? [],
      },
      {
        provide: GracefulShutdownService,
        useFactory: (hooks: NamedShutdownHook[]) =>
          new GracefulShutdownService(hooks, options.shutdown),
        inject: [SHUTDOWN_HOOKS_TOKEN],
      },
    ];

    const exports: Array<Provider | string | symbol | Type<unknown>> = [
      CircuitBreakerFactory,
      GracefulShutdownService,
    ];

    if (options.enableRedisHttpHelpers) {
      if (!options.redis) {
        throw new Error('ResilienceModule.enableRedisHttpHelpers requires redis.inject')
      }

      const redisAlias = (token: string): Provider => ({
        provide: token,
        useExisting: options.redis!.inject,
      });

      providers.unshift(redisAlias(RATE_LIMIT_REDIS_TOKEN), redisAlias(IDEMPOTENCY_REDIS_TOKEN))
      providers.push(RedisRateLimitGuard, IdempotencyInterceptor)
      exports.push(RedisRateLimitGuard, IdempotencyInterceptor)
    }

    return {
      module: ResilienceModule,
      providers,
      exports,
    };
  }
}
