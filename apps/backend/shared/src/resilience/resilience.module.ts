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
   * `ioredis` Redis client. Used by the rate-limit guard and idempotency
   * interceptor.
   */
  redis: {
    /** Token / class to inject. e.g. 'REDIS_CLIENT' or RedisService. */
    inject: string | symbol | Type<unknown>;
  };
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
    const redisAlias = (token: string): Provider => ({
      provide: token,
      useExisting: options.redis.inject,
    });

    const providers: Provider[] = [
      redisAlias(RATE_LIMIT_REDIS_TOKEN),
      redisAlias(IDEMPOTENCY_REDIS_TOKEN),
      RedisRateLimitGuard,
      IdempotencyInterceptor,
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

    return {
      module: ResilienceModule,
      providers,
      exports: [
        RedisRateLimitGuard,
        IdempotencyInterceptor,
        CircuitBreakerFactory,
        GracefulShutdownService,
      ],
    };
  }
}
