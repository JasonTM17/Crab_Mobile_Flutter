# Docker Deployment

<!-- DOCKER-EN:START -->
## English Docker Deployment

Crab ships multiple Compose files. This guide defines their intended use so contributors do not confuse full-stack, infra-only, production-like, and monitoring profiles.

## Compose Files

| File | Purpose | Notes |
| --- | --- | --- |
| `docker-compose.yml` | Canonical full local stack | Infrastructure, backend services, and web-admin |
| `docker-compose.dev.yml` | Backend-focused development variant | Kept for compatibility; prefer the root full stack unless you need this exact profile |
| `docker/docker-compose.infra.yml` | Infra-only local stack | Use when running services directly with `pnpm dev` |
| `docker-compose.prod.yml` | Production-like compose | Requires env values from `.env.production.example` |
| `docker-compose.monitoring.yml` | Canonical monitoring sidecar stack | Prometheus, Grafana, Loki, Promtail, cAdvisor, node-exporter |

## Full Local Stack

```bash
docker compose up -d
docker compose ps
docker compose logs -f gateway
```

| Service | Host port |
| --- | --- |
| Gateway | `3000` |
| Web Admin | `5173` |
| PostgreSQL | `5432` |
| MongoDB | `27017` |
| Redis | `6379` |
| MinIO | `9000`, `9001` |

## Infra-only Development

```bash
docker compose -f docker/docker-compose.infra.yml up -d
pnpm dev
```

Use this when backend services are run from source rather than as containers.

## Production-like Validation

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml config
```

Do not place real secrets in `.env.production.example`; use local env files or a secret manager.

## Monitoring

```bash
docker compose -f docker-compose.monitoring.yml up -d
```

| Service | Host port |
| --- | --- |
| Prometheus | `9090` |
| Grafana | `3009` |
| Loki | `3100` |
| cAdvisor | `8081` |

`monitoring/docker-compose.yml` is retained as reference until the monitoring folder is fully consolidated.

## Health

```bash
curl http://localhost:3000/health
curl http://localhost:3000/healthz
curl http://localhost:3000/readyz
curl http://localhost:3000/metrics
```

Health endpoints are outside `/api/v1`.
<!-- DOCKER-EN:END -->

<!-- DOCKER-VI:START -->
## Vietnamese Docker Deployment

Crab có nhiều file Compose. Hướng dẫn này phân biệt full-stack, infra-only, production-like và monitoring để tránh nhầm lẫn.

## Các File Compose

| File | Mục đích | Ghi chú |
| --- | --- | --- |
| `docker-compose.yml` | Full local stack chính thức | Hạ tầng, backend services và web-admin |
| `docker-compose.dev.yml` | Biến thể development tập trung backend | Giữ để tương thích; ưu tiên full stack ở root nếu không cần profile này |
| `docker/docker-compose.infra.yml` | Local stack chỉ hạ tầng | Dùng khi chạy services trực tiếp bằng `pnpm dev` |
| `docker-compose.prod.yml` | Production-like compose | Cần env values từ `.env.production.example` |
| `docker-compose.monitoring.yml` | Monitoring sidecar stack chính thức | Prometheus, Grafana, Loki, Promtail, cAdvisor, node-exporter |

## Full Local Stack

```bash
docker compose up -d
docker compose ps
docker compose logs -f gateway
```

| Service | Host port |
| --- | --- |
| Gateway | `3000` |
| Web Admin | `5173` |
| PostgreSQL | `5432` |
| MongoDB | `27017` |
| Redis | `6379` |
| MinIO | `9000`, `9001` |

## Chỉ Chạy Hạ Tầng

```bash
docker compose -f docker/docker-compose.infra.yml up -d
pnpm dev
```

Dùng khi backend services chạy từ source thay vì container.

## Kiểm Tra Production-like

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml config
```

Không đặt secret thật trong `.env.production.example`; dùng local env file hoặc secret manager.

## Quan Sát

```bash
docker compose -f docker-compose.monitoring.yml up -d
```

| Service | Host port |
| --- | --- |
| Prometheus | `9090` |
| Grafana | `3009` |
| Loki | `3100` |
| cAdvisor | `8081` |

`monitoring/docker-compose.yml` được giữ làm tham chiếu cho tới khi hợp nhất hoàn toàn thư mục monitoring.

## Health

```bash
curl http://localhost:3000/health
curl http://localhost:3000/healthz
curl http://localhost:3000/readyz
curl http://localhost:3000/metrics
```

Health endpoints nằm ngoài `/api/v1`.
<!-- DOCKER-VI:END -->
