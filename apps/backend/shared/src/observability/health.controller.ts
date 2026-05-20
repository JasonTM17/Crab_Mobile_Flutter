import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Inject,
  Optional,
  ServiceUnavailableException,
} from '@nestjs/common';
import type Redis from 'ioredis';

/**
 * DI tokens that consuming services should provide when they want
 * `/readyz` to verify a dependency. Both are optional. When unbound the
 * corresponding check is skipped (and reported as "not_configured").
 */
export const HEALTH_REDIS_CLIENT = 'CRAB_HEALTH_REDIS_CLIENT';
export const HEALTH_PG_CLIENT = 'CRAB_HEALTH_PG_CLIENT';

/** Minimal interface; matches `pg.Pool` and `pg.Client`. */
export interface PgLikeClient {
  query: (text: string) => Promise<unknown>;
}

interface CheckResult {
  status: 'ok' | 'fail' | 'not_configured';
  latency_ms?: number;
  error?: string;
}

@Controller()
export class HealthController {
  constructor(
    @Optional() @Inject(HEALTH_REDIS_CLIENT) private readonly redis?: Redis,
    @Optional() @Inject(HEALTH_PG_CLIENT) private readonly pg?: PgLikeClient,
  ) {}

  /**
   * Liveness probe: process is up. Always returns 200 unless the event
   * loop is wedged hard enough to prevent the response.
   */
  @Get('healthz')
  @HttpCode(HttpStatus.OK)
  liveness() {
    return { status: 'ok', uptime_s: Math.round(process.uptime()) };
  }

  /**
   * Readiness probe: dependencies reachable. Returns 503 with a per-check
   * breakdown when any configured dependency fails so orchestrators can
   * route traffic accordingly.
   */
  @Get('readyz')
  async readiness() {
    const [redis, postgres] = await Promise.all([
      this.checkRedis(),
      this.checkPostgres(),
    ]);

    const failed = [redis, postgres].some((c) => c.status === 'fail');
    const body = {
      status: failed ? 'fail' : 'ok',
      checks: { redis, postgres },
    };

    if (failed) throw new ServiceUnavailableException(body);
    return body;
  }

  private async checkRedis(): Promise<CheckResult> {
    if (!this.redis) return { status: 'not_configured' };
    const started = Date.now();
    try {
      const pong = await this.redis.ping();
      if (pong !== 'PONG') {
        return { status: 'fail', error: `unexpected reply: ${pong}` };
      }
      return { status: 'ok', latency_ms: Date.now() - started };
    } catch (err) {
      return {
        status: 'fail',
        error: err instanceof Error ? err.message : String(err),
      };
    }
  }

  private async checkPostgres(): Promise<CheckResult> {
    if (!this.pg) return { status: 'not_configured' };
    const started = Date.now();
    try {
      await this.pg.query('SELECT 1');
      return { status: 'ok', latency_ms: Date.now() - started };
    } catch (err) {
      return {
        status: 'fail',
        error: err instanceof Error ? err.message : String(err),
      };
    }
  }
}
