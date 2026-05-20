# Observability

Self-contained observability surface for every Crab backend service: structured
logs, Prometheus metrics, OpenTelemetry traces, request-id correlation, and
health probes. Lives entirely under `@crab/backend-shared` so services consume
it through the existing shared barrel.

## What you get

| Concern         | Implementation                                                |
|-----------------|---------------------------------------------------------------|
| Logs            | `pino` JSON in prod, `pino-pretty` in dev                     |
| Request id      | `RequestIdMiddleware` — reads/writes `X-Request-Id`           |
| Access log      | `AccessLogMiddleware` — one structured line per request       |
| HTTP metrics    | `MetricsMiddleware` — `http_requests_total`, `_duration_seconds` |
| Prometheus      | `GET /metrics` (text/plain)                                   |
| Health probes   | `GET /healthz` (always 200), `GET /readyz` (Redis + Postgres) |
| Tracing         | OTLP-HTTP exporter, W3C trace context, http+ioredis+pg auto   |

## Wiring (3 lines in `main.ts`)

```ts
import { initTracing } from '@crab/backend-shared/observability';
await initTracing({ serviceName: 'auth-service' });
const app = await NestFactory.create(AppModule);
app.setGlobalPrefix('api/v1', { exclude: ['healthz', 'readyz', 'metrics'] });
```

In `AppModule`:

```ts
import { ObservabilityModule, HEALTH_REDIS_CLIENT, HEALTH_PG_CLIENT } from '@crab/backend-shared/observability';

@Module({
  imports: [ObservabilityModule],
  providers: [
    { provide: HEALTH_REDIS_CLIENT, useExisting: 'REDIS' }, // optional
    { provide: HEALTH_PG_CLIENT, useExisting: 'PG_POOL' },  // optional
  ],
})
export class AppModule {}
```

`initTracing` MUST run before `NestFactory.create` so OpenTelemetry can patch
`http`, `ioredis`, `pg`, and `mongodb` before any module imports them.

## Environment variables

| Name                              | Default      | Description                                |
|-----------------------------------|--------------|--------------------------------------------|
| `SERVICE_NAME`                    | crab-backend | Logical service name in logs/metrics       |
| `LOG_LEVEL`                       | info / debug | pino level (`trace`/`debug`/`info`/`warn`/`error`/`fatal`) |
| `NODE_ENV`                        | -            | `production` enables JSON-only logs        |
| `OTEL_EXPORTER_OTLP_ENDPOINT`     | -            | OTLP-HTTP collector base URL. Empty = tracing disabled. |
| `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT` | -         | Override traces-only endpoint              |
| `OTEL_LOG_LEVEL`                  | -            | Set to `debug` for OTel internal logs      |

## Logged fields

`request_id`, `user_id`, `route`, `method`, `status`, `latency_ms`, plus pino's
default `ts` / `level` / `msg`. Authorization, cookies, and known token fields
are redacted.

## Running

No bootstrap-time config beyond env. The `/metrics` endpoint is always live;
default Node metrics (CPU, RSS, event-loop lag) are collected automatically.
