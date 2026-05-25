# Observability

Source: `apps/backend/shared/src/observability/`, `monitoring/`, `docker-compose.monitoring.yml`

## Stack

`docker-compose.monitoring.yml` boots the platform-wide telemetry side-car. It joins the `crab-network` external Docker network created by the main compose file so it can scrape the backend services by container name.

| Service             | Image                                            | Host port | Role |
|---------------------|--------------------------------------------------|-----------|------|
| `prometheus`        | `prom/prometheus:v2.48.0`                        | 9090      | Pulls `/metrics` from each backend service. 30 day retention via `--storage.tsdb.retention.time=30d`. Loads `prometheus/prometheus.yml` + `prometheus/alerts.yml`. |
| `grafana`           | `grafana/grafana:10.2.0`                         | 3100      | UI for metrics and logs. Provisioned with the Prometheus + Loki datasources and `Crab` dashboard folder via `monitoring/grafana/provisioning/`. Default login `admin / crab_admin` (override in env). |
| `loki`              | `grafana/loki:2.9.0`                             | 3101      | Log aggregator. Backend services ship their JSON logs through Promtail (run separately if/when log collection is enabled). |
| `postgres-exporter` | `prometheuscommunity/postgres-exporter:v0.15.0`  | 9187      | Postgres metrics, scraped as job `postgres`. |
| `redis-exporter`    | `oliver006/redis_exporter:v1.55.0`               | 9121      | Redis metrics, scraped as job `redis`. |

A second compose at `monitoring/docker-compose.yml` defines an extended profile that adds `promtail`, `cadvisor`, and `node-exporter` for container and host metrics on top of the same Prometheus, Grafana, and Loki instances.

Bring the stack up with the main app already running:

```bash
docker compose -f docker-compose.monitoring.yml up -d
```

## Per-service surface

Every NestJS backend imports `ObservabilityModule` from `@crab/backend-shared` (`apps/backend/shared/src/observability/observability.module.ts`). Importing it once at the app root wires:

- `RequestIdMiddleware` - generates or propagates `X-Request-Id`. Accepts UUID v4 or alphanumeric ids 8-64 chars; replaces anything else to block log injection.
- `AccessLogMiddleware` - emits one structured log per finished request via the shared pino logger.
- `MetricsMiddleware` - records `http_requests_total` and `http_request_duration_seconds`.
- `HealthController` - mounts `GET /healthz` and `GET /readyz`.
- `MetricsController` - mounts `GET /metrics` (text/plain Prometheus exposition).

`main.ts` excludes the platform endpoints from the API prefix:

```ts
app.setGlobalPrefix('api/v1', {
  exclude: ['health', 'healthz', 'readyz', 'metrics'],
})
```

### Health endpoints

- `GET /healthz` always returns `200 { status: 'ok', uptime_s }` while the event loop is responsive.
- `GET /readyz` checks optional Redis (`HEALTH_REDIS_CLIENT`) and Postgres (`HEALTH_PG_CLIENT`) clients in parallel. If a check fails it throws `503` with a per-check breakdown:

  ```json
  { "status": "fail",
    "checks": {
      "redis":    { "status": "ok",   "latency_ms": 3 },
      "postgres": { "status": "fail", "error": "connection refused" } } }
  ```

  Unbound dependencies report `not_configured` and do not fail the probe.

### Metrics endpoint

`GET /metrics` exposes the `prom-client` default registry via `MetricsController`. Default Node metrics (event loop, GC, CPU, heap) are registered the first time `ensureHttpMetrics()` runs, plus two HTTP series:

```text
http_requests_total{route, method, status}
http_request_duration_seconds_bucket{route, method}  buckets:
  0.005 0.01 0.025 0.05 0.1 0.25 0.5 1 2.5 5 10
```

Routes are normalised to the Express template (`/users/:id`) so high-cardinality ids do not blow up the time series.

### Tracing

`apps/backend/shared/src/observability/tracing.ts` exposes `initTracing({ serviceName })`. It MUST be called BEFORE `NestFactory.create(...)` so OpenTelemetry auto-instrumentations can patch `http`, `pg`, `ioredis`, `mongodb`, and `nestjs-core` before module load. Tracing is a no-op unless `OTEL_EXPORTER_OTLP_ENDPOINT` (or `OTEL_EXPORTER_OTLP_TRACES_ENDPOINT`) is set, so dev with no collector pays no cost. The exporter automatically appends `/v1/traces` if the endpoint URL omits it. SDK shutdown is wired to `SIGTERM`.

## Log shape

The shared logger (`apps/backend/shared/src/observability/logger.ts`) uses `pino`. JSON output in production, pretty output in dev when stdout is a TTY. ISO-8601 timestamp under `ts`. Standard field names live in `LOG_FIELDS`:

```json
{ "ts": "2026-05-21T06:50:00.123Z",
  "level": "info",
  "msg": "request_completed",
  "service": "rating-service",
  "request_id": "f3b1...c5",
  "user_id": "u_42",
  "route": "/ratings/:id",
  "method": "GET",
  "status": 200,
  "latency_ms": 7.42,
  "trace_id": "...",
  "span_id": "..." }
```

`AccessLogMiddleware` raises the level on the response status: `>=500 -> error`, `>=400 -> warn`, otherwise `info`. Aborted connections (client disconnect before the response finishes) log as `warn` with synthetic status `499`.

Sensitive fields are redacted at the logger level: `req.headers.authorization`, `req.headers.cookie`, `req.headers["x-api-key"]`, `res.headers["set-cookie"]`, plus any `*.password`, `*.token`, `*.access_token`, `*.refresh_token` paths. Redactions render as `[REDACTED]`.

## Prometheus targets

`monitoring/prometheus/prometheus.yml` declares static targets per service. Hostnames match the docker-compose service names so DNS resolves inside the `crab-network`:

```text
gateway:3000           job=gateway
auth-service:3001      job=auth-service       label service=auth
user-service:3002      job=user-service       label service=user
ride-service:3003      job=ride-service       label service=ride
food-service:3004      job=food-service       label service=food
payment-service:3005   job=payment-service    label service=payment
chat-service:3006      job=chat-service       label service=chat
notification-service:3007  job=notification-service  label service=notification
rating-service:3008    job=rating-service     label service=rating
postgres-exporter:9187 job=postgres
redis-exporter:9121    job=redis
```

Scrape interval and evaluation interval are both 15s. Alert rules live in `monitoring/prometheus/alerts.yml`.

## Grafana dashboards

Provisioning files: `monitoring/grafana/provisioning/`.

- `datasources.yml` registers `Prometheus` (default) and `Loki`.
- `dashboards.yml` mounts `/etc/grafana/provisioning/dashboards` as a file-based provider for the `Crab` folder, with `foldersFromFilesStructure: true` so subdirectories become Grafana folders. Drop dashboard JSON exports into `monitoring/grafana/provisioning/dashboards/<area>/<name>.json` and they are auto-loaded on container start.

## How to add a new metric

1. In your service module, create a `prom-client` instrument and register it on the default registry:

   ```ts
   import { Counter } from 'prom-client'
   import { register } from 'prom-client'

   export const ratingsCreated = new Counter({
     name: 'ratings_created_total',
     help: 'Number of ratings written',
     labelNames: ['target_type', 'context'],
     registers: [register],
   })
   ```

2. Increment from the call site:

   ```ts
   ratingsCreated.inc({ target_type: dto.targetType, context: dto.context })
   ```

3. Confirm it shows up at `GET /metrics` on the service.
4. Confirm it is scraped at `http://localhost:9090/targets` and queryable in Grafana.
5. Keep label cardinality bounded. Use enums (status, target_type) and resolved route templates. Never label by raw user id, ride id, or order id.

## Related docs

- [../README.md](../README.md)
- [./DEPLOYMENT.md](./DEPLOYMENT.md)
