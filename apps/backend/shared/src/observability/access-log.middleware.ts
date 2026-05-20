import { Injectable, NestMiddleware, Logger as NestLogger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { Logger } from 'pino';
import { getDefaultLogger } from './logger';

interface AuthenticatedRequest extends Request {
  requestId?: string;
  user?: { id?: string; sub?: string };
}

/**
 * Logs every request when the response finishes with structured fields:
 *   ts, level, msg, request_id, user_id, route, method, status, latency_ms.
 *
 * Routes are normalised via `req.route?.path` when available so that
 * `/users/123` collapses to `/users/:id` for log aggregation.
 */
@Injectable()
export class AccessLogMiddleware implements NestMiddleware {
  private readonly logger: Logger;
  private readonly nestLogger = new NestLogger(AccessLogMiddleware.name);

  constructor(logger?: Logger) {
    this.logger = logger ?? getDefaultLogger();
  }

  use(req: AuthenticatedRequest, res: Response, next: NextFunction): void {
    const start = process.hrtime.bigint();

    res.on('finish', () => {
      const end = process.hrtime.bigint();
      const latencyMs = Number(end - start) / 1_000_000;
      const route =
        // Express route template after matching, e.g. /users/:id
        (req as unknown as { route?: { path?: string } }).route?.path ??
        req.originalUrl?.split('?')[0] ??
        req.url;

      const userId = req.user?.id ?? req.user?.sub;

      const fields = {
        request_id: req.requestId,
        user_id: userId,
        route,
        method: req.method,
        status: res.statusCode,
        latency_ms: Number(latencyMs.toFixed(2)),
      };

      if (res.statusCode >= 500) {
        this.logger.error(fields, 'request_completed');
      } else if (res.statusCode >= 400) {
        this.logger.warn(fields, 'request_completed');
      } else {
        this.logger.info(fields, 'request_completed');
      }
    });

    res.on('close', () => {
      // Connection terminated by client before response finished.
      if (!res.writableEnded) {
        const end = process.hrtime.bigint();
        const latencyMs = Number(end - start) / 1_000_000;
        this.logger.warn(
          {
            request_id: req.requestId,
            route: req.originalUrl?.split('?')[0] ?? req.url,
            method: req.method,
            status: 499,
            latency_ms: Number(latencyMs.toFixed(2)),
          },
          'request_aborted',
        );
      }
    });

    next();
  }
}
