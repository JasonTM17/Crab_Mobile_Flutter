# Resilience

In-house resilience primitives shared across Crab backend services.
Pure TypeScript, depends only on `ioredis` and the existing `@nestjs/*` peers.

## Pieces

- `RedisRateLimitGuard` + `@RateLimit()` — sliding-window limiter backed by Redis (atomic Lua).
- `IdempotencyInterceptor` — replay-safe POST/PATCH/PUT via `Idempotency-Key` header.
- `CircuitBreaker` + `CircuitBreakerFactory` — timeout, rolling failure window, OPEN/HALF_OPEN/CLOSED.
- `GracefulShutdownService` — ordered drain on SIGTERM/SIGINT with 30s grace.
- `ResilienceModule.forRoot({ redis: { inject } })` — global module wiring everything.

## Wire-up

```ts
// app.module.ts
ResilienceModule.forRoot({
  redis: { inject: 'REDIS_CLIENT' }, // your existing ioredis provider
  shutdown: { graceMs: 30_000 },
});
```

## Rate limit

```ts
import { RateLimit, RedisRateLimitGuard } from '@crab/backend-shared/resilience';

@UseGuards(RedisRateLimitGuard)
@Controller('auth')
export class AuthController {
  @RateLimit({ limit: 5, windowMs: 60_000, keyBy: 'ip' })
  @Post('login')
  login() { /* ... */ }
}
```

## Idempotency

```ts
import { IdempotencyInterceptor } from '@crab/backend-shared/resilience';

@UseInterceptors(IdempotencyInterceptor)
@Controller('payments')
export class PaymentsController {
  @Post('charge')
  charge(@Body() dto: ChargeDto) { /* ... */ }
}
// Client must send: Idempotency-Key: <8-128 chars [A-Za-z0-9_\-:.]>
```

## Circuit breaker

```ts
import { CircuitBreakerFactory } from '@crab/backend-shared/resilience';

@Injectable()
export class UserClient {
  constructor(private readonly breakers: CircuitBreakerFactory) {}

  async getUser(id: string) {
    return this.breakers.execute(
      'user-service',
      () => this.http.get(`/users/${id}`),
      () => ({ id, name: 'unknown' }), // fallback when OPEN
      { timeoutMs: 2000, errorThresholdPct: 50, volumeThreshold: 20 },
    );
  }
}
```

## Graceful shutdown hooks

```ts
constructor(private readonly shutdown: GracefulShutdownService) {
  shutdown.register({
    name: 'http-server',
    order: 20,
    fn: async () => httpServer.close(),
  });
  shutdown.register({
    name: 'bullmq-queue',
    order: 40,
    fn: async () => queue.close(),
  });
}
```

Recommended order: `10` readiness flip, `20` HTTP, `30` Socket.IO, `40` queues, `50` DB, `60` Redis.

## Notes

- Rate-limit guard fails open on Redis errors (logged) so a Redis blip does not 503 traffic.
- Idempotency caches at most 64 KB serialized; larger responses are skipped.
- Circuit breaker is in-process; for cross-pod consensus pair with health-based load-balancer.
- All keys are prefixed (`rl:`, `idemp:`) so namespace audit is grep-able in Redis.
