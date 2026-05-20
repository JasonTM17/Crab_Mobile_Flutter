import {
  Global,
  MiddlewareConsumer,
  Module,
  NestModule,
} from '@nestjs/common';
import { AccessLogMiddleware } from './access-log.middleware';
import { HealthController } from './health.controller';
import {
  MetricsMiddleware,
  MetricsModule,
  ensureHttpMetrics,
} from './metrics.module';
import { RequestIdMiddleware } from './request-id.middleware';

/**
 * Wires the standard observability surface into a NestJS application:
 *
 *   - request-id middleware (generates / propagates X-Request-Id)
 *   - access-log middleware (structured JSON logs per request)
 *   - metrics middleware (http_requests_total, http_request_duration_seconds)
 *   - GET /healthz, GET /readyz
 *   - GET /metrics (text/plain Prometheus exposition)
 *
 * Tracing is bootstrapped separately via `initTracing()` BEFORE Nest starts;
 * see `tracing.ts` and the README.
 *
 * Usage in a service:
 *
 *   @Module({ imports: [ObservabilityModule] })
 *   export class AppModule {}
 *
 * Then in `main.ts`:
 *
 *   app.setGlobalPrefix('api/v1', { exclude: ['healthz', 'readyz', 'metrics'] });
 */
@Global()
@Module({
  imports: [MetricsModule],
  controllers: [HealthController],
  providers: [RequestIdMiddleware, AccessLogMiddleware],
  exports: [RequestIdMiddleware, AccessLogMiddleware, MetricsModule],
})
export class ObservabilityModule implements NestModule {
  configure(consumer: MiddlewareConsumer): void {
    // Touch metrics so default Node metrics are registered even if no
    // request comes in (so `/metrics` is non-empty after boot).
    ensureHttpMetrics();

    consumer
      .apply(RequestIdMiddleware, AccessLogMiddleware, MetricsMiddleware)
      .forRoutes('*');
  }
}
