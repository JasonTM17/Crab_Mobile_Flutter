import {
  CallHandler,
  ExecutionContext,
  Inject,
  Injectable,
  Logger,
  NestInterceptor,
} from '@nestjs/common';
import type { Request, Response } from 'express';
import type Redis from 'ioredis';
import { Observable, from, of, switchMap, tap } from 'rxjs';

export const IDEMPOTENCY_REDIS_TOKEN = 'IDEMPOTENCY_REDIS';

const HEADER = 'idempotency-key';
const TTL_SECONDS = 60 * 60 * 24; // 24h
const MAX_BODY_BYTES = 64 * 1024; // 64 KB
const MUTATING_METHODS = new Set(['POST', 'PATCH', 'PUT']);
const KEY_PATTERN = /^[A-Za-z0-9_\-:.]{8,128}$/;

interface CachedResponse {
  status: number;
  body: unknown;
  headers: Record<string, string>;
}

/**
 * Idempotency-Key interceptor.
 *
 * For mutating requests carrying an `Idempotency-Key` header:
 *  - Cache hit  -> replay the cached response (status + body + safe headers).
 *  - Cache miss -> execute the handler, cache the response for 24h.
 *
 * Skips when the header is missing (opt-in behaviour).
 *
 * Redis key shape: idemp:<METHOD>:<routePath>:<key>
 */
@Injectable()
export class IdempotencyInterceptor implements NestInterceptor {
  private readonly logger = new Logger(IdempotencyInterceptor.name);

  constructor(@Inject(IDEMPOTENCY_REDIS_TOKEN) private readonly redis: Redis) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<unknown> {
    const http = context.switchToHttp();
    const req = http.getRequest<Request>();
    const res = http.getResponse<Response>();

    if (!MUTATING_METHODS.has(req.method)) return next.handle();

    const rawKey = (req.headers[HEADER] as string | undefined)?.trim();
    if (!rawKey) return next.handle();

    if (!KEY_PATTERN.test(rawKey)) {
      this.logger.warn(`Invalid Idempotency-Key format ignored on ${req.method} ${req.path}`);
      return next.handle();
    }

    const route = this.deriveRoute(req);
    const cacheKey = `idemp:${req.method}:${route}:${rawKey}`;

    return from(this.tryReplay(cacheKey, res)).pipe(
      switchMap((cached) => {
        if (cached) return of(cached.body);
        return next.handle().pipe(
          tap((body) => {
            void this.cacheResponse(cacheKey, res, body);
          }),
        );
      }),
    );
  }

  private async tryReplay(
    cacheKey: string,
    res: Response,
  ): Promise<CachedResponse | null> {
    let raw: string | null;
    try {
      raw = await this.redis.get(cacheKey);
    } catch (err) {
      this.logger.error(`Idempotency GET failed for ${cacheKey}: ${(err as Error).message}`);
      return null; // fail-open
    }
    if (!raw) return null;

    let cached: CachedResponse;
    try {
      cached = JSON.parse(raw) as CachedResponse;
    } catch {
      this.logger.warn(`Corrupt idempotency cache at ${cacheKey}; ignoring.`);
      return null;
    }

    res.status(cached.status);
    for (const [name, value] of Object.entries(cached.headers ?? {})) {
      res.setHeader(name, value);
    }
    res.setHeader('Idempotent-Replay', 'true');
    this.logger.debug(`Replayed cached response for ${cacheKey}`);
    return cached;
  }

  private async cacheResponse(
    cacheKey: string,
    res: Response,
    body: unknown,
  ): Promise<void> {
    let serialized: string;
    try {
      const payload: CachedResponse = {
        status: res.statusCode,
        body,
        headers: this.pickSafeHeaders(res),
      };
      serialized = JSON.stringify(payload);
    } catch (err) {
      this.logger.warn(
        `Cannot serialize response for ${cacheKey}: ${(err as Error).message}`,
      );
      return;
    }

    if (Buffer.byteLength(serialized, 'utf8') > MAX_BODY_BYTES) {
      this.logger.debug(`Skipping idempotency cache for ${cacheKey}: body > 64KB`);
      return;
    }

    try {
      await this.redis.set(cacheKey, serialized, 'EX', TTL_SECONDS);
    } catch (err) {
      this.logger.error(
        `Idempotency SET failed for ${cacheKey}: ${(err as Error).message}`,
      );
    }
  }

  private pickSafeHeaders(res: Response): Record<string, string> {
    // Only echo headers safe to replay. Drop anything connection-specific.
    const allow = ['content-type', 'content-language', 'cache-control', 'etag'];
    const out: Record<string, string> = {};
    for (const name of allow) {
      const v = res.getHeader(name);
      if (typeof v === 'string') out[name] = v;
      else if (typeof v === 'number') out[name] = String(v);
    }
    return out;
  }

  private deriveRoute(req: Request): string {
    // Express decorates with `route.path`; fall back to `originalUrl` w/ querystring stripped.
    const r = (req as Request & { route?: { path?: string } }).route;
    if (r?.path) return r.path;
    const url = req.originalUrl || req.url || '/';
    return url.split('?')[0];
  }
}
