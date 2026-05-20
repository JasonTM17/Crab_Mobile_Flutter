import {
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Inject,
  Injectable,
  Logger,
  SetMetadata,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import type { Request } from 'express';
import type Redis from 'ioredis';

export const RATE_LIMIT_REDIS_TOKEN = 'RATE_LIMIT_REDIS';
export const RATE_LIMIT_METADATA = 'crab:rate-limit';

export type RateLimitKeyBy = 'ip' | 'user';

export interface RateLimitOptions {
  /** Maximum requests per window. */
  limit: number;
  /** Window length in milliseconds. */
  windowMs: number;
  /** Actor key derivation. Defaults to 'ip'. */
  keyBy?: RateLimitKeyBy;
  /** Optional namespace label, defaults to controller#handler. */
  bucket?: string;
}

/**
 * Decorator applied to controllers / handlers to declare a rate limit.
 *
 * @example
 *   @RateLimit({ limit: 60, windowMs: 60_000, keyBy: 'ip' })
 *   @Post('login') login() {}
 */
export const RateLimit = (options: RateLimitOptions): MethodDecorator & ClassDecorator =>
  SetMetadata(RATE_LIMIT_METADATA, options);

interface AuthedRequest extends Request {
  user?: { id?: string; sub?: string } & Record<string, unknown>;
}

/**
 * Sliding-window-ish rate limiter (fixed-window with millisecond TTL).
 * Atomic INCR + PEXPIRE via Lua so a key never lives forever.
 *
 * Redis key shape: rl:<bucket>:<actor>
 */
@Injectable()
export class RedisRateLimitGuard implements CanActivate {
  private readonly logger = new Logger(RedisRateLimitGuard.name);

  // Lua script: returns [count, ttl_ms]. Sets PEXPIRE only on first INCR.
  private static readonly LUA = `
    local current = redis.call('INCR', KEYS[1])
    if current == 1 then
      redis.call('PEXPIRE', KEYS[1], ARGV[1])
    end
    local ttl = redis.call('PTTL', KEYS[1])
    return { current, ttl }
  `;

  constructor(
    @Inject(RATE_LIMIT_REDIS_TOKEN) private readonly redis: Redis,
    private readonly reflector: Reflector,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const options = this.reflector.getAllAndOverride<RateLimitOptions | undefined>(
      RATE_LIMIT_METADATA,
      [context.getHandler(), context.getClass()],
    );

    if (!options) return true;

    const req = context.switchToHttp().getRequest<AuthedRequest>();
    const actor = this.deriveActor(req, options.keyBy ?? 'ip');
    if (!actor) {
      // Cannot identify actor (e.g. keyBy=user but unauthenticated).
      // Fail-closed by allowing — auth guard will reject anyway.
      return true;
    }

    const bucket = options.bucket ?? this.deriveBucket(context);
    const key = `rl:${bucket}:${actor}`;

    let count: number;
    let ttlMs: number;
    try {
      const result = (await this.redis.eval(
        RedisRateLimitGuard.LUA,
        1,
        key,
        String(options.windowMs),
      )) as [number, number];
      count = result[0];
      ttlMs = result[1];
    } catch (err) {
      this.logger.error(
        `Redis rate-limit eval failed for ${key}: ${(err as Error).message}`,
      );
      // Fail-open: do not block traffic on Redis hiccup. Operator sees the log.
      return true;
    }

    if (count > options.limit) {
      const retryAfterSec = Math.max(1, Math.ceil(ttlMs / 1000));
      throw new HttpException(
        {
          statusCode: HttpStatus.TOO_MANY_REQUESTS,
          message: 'Too Many Requests',
          retryAfter: retryAfterSec,
        },
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    return true;
  }

  private deriveActor(req: AuthedRequest, keyBy: RateLimitKeyBy): string | null {
    if (keyBy === 'user') {
      const u = req.user;
      const id = u?.id ?? u?.sub;
      return typeof id === 'string' && id.length > 0 ? id : null;
    }
    // ip
    const fwd = (req.headers['x-forwarded-for'] as string | undefined)?.split(',')[0]?.trim();
    return fwd || req.ip || req.socket?.remoteAddress || 'unknown';
  }

  private deriveBucket(context: ExecutionContext): string {
    const cls = context.getClass()?.name ?? 'Unknown';
    const handler = context.getHandler()?.name ?? 'unknown';
    return `${cls}#${handler}`;
  }
}
