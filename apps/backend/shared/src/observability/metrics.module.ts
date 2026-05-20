import { Injectable, NestMiddleware, Module, Global } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import {
  Counter,
  Histogram,
  Registry,
  collectDefaultMetrics,
  register as defaultRegister,
} from 'prom-client';
import { MetricsController } from './metrics.controller';

/**
 * Standard buckets for HTTP request duration in seconds.
 * Tuned for Crab API where most calls are <500ms but ride/order
 * orchestrations can run a few seconds.
 */
export const DEFAULT_HTTP_BUCKETS = [
  0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5, 10,
];

interface HttpMetrics {
  requestsTotal: Counter<string>;
  requestDuration: Histogram<string>;
}

let metrics: HttpMetrics | undefined;

/**
 * Lazily initialise (or reuse) the HTTP metrics on the global default
 * registry. Safe to call multiple times across modules.
 */
export function ensureHttpMetrics(): HttpMetrics {
  if (metrics) return metrics;

  // Surface Node.js process / event-loop metrics under the same registry.
  // Wrapped so repeated calls in the same process don't double-register.
  if (!defaultRegister.getSingleMetric('process_cpu_user_seconds_total')) {
    collectDefaultMetrics({ register: defaultRegister });
  }

  const requestsTotal = new Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['route', 'method', 'status'],
    registers: [defaultRegister],
  });

  const requestDuration = new Histogram({
    name: 'http_request_duration_seconds',
    help: 'HTTP request duration in seconds',
    labelNames: ['route', 'method'],
    buckets: DEFAULT_HTTP_BUCKETS,
    registers: [defaultRegister],
  });

  metrics = { requestsTotal, requestDuration };
  return metrics;
}

@Injectable()
export class MetricsMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction): void {
    const m = ensureHttpMetrics();
    const start = process.hrtime.bigint();

    res.on('finish', () => {
      const routedPath = (req as unknown as { route?: { path?: string } }).route?.path
      const fallbackPath = req.originalUrl?.split('?')[0] ?? req.url ?? 'unknown'
      const route = routedPath ?? fallbackPath

      const labels = {
        route,
        method: req.method,
        status: String(res.statusCode),
      };

      m.requestsTotal.inc(labels, 1);

      const end = process.hrtime.bigint();
      const seconds = Number(end - start) / 1_000_000_000;
      m.requestDuration.observe(
        { route, method: req.method },
        seconds,
      );
    });

    next();
  }
}

/**
 * Global module that exposes Prometheus metrics. Importing it once at the
 * application root automatically:
 *   - registers default Node.js metrics,
 *   - exposes `GET /metrics`,
 *   - allows wiring `MetricsMiddleware` via the consumer pattern.
 */
@Global()
@Module({
  controllers: [MetricsController],
  providers: [MetricsMiddleware],
  exports: [MetricsMiddleware],
})
export class MetricsModule {
  /** Returns the shared `prom-client` registry, useful for tests. */
  static getRegistry(): Registry {
    ensureHttpMetrics();
    return defaultRegister;
  }
}
