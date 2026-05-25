# Docker Deployment / Triển Khai Docker

Crab ships multiple Compose files. This guide defines their intended use so contributors do not confuse full-stack, infra-only, production-like, and monitoring profiles.

Crab có nhiều file Compose. Hướng dẫn này phân biệt full-stack, infra-only, production-like và monitoring để tránh nhầm lẫn.

## Compose Files / Các File Compose

| File | Purpose | Notes |
| --- | --- | --- |
| `docker-compose.yml` | Canonical full local stack | Infrastructure, backend services, and web-admin |
| `docker-compose.dev.yml` | Backend-focused development variant | Keep for compatibility; prefer root full stack unless you need this exact profile |
| `docker/docker-compose.infra.yml` | Infra-only local stack | Use when running services directly with `pnpm dev` |
| `docker-compose.prod.yml` | Production-like compose | Requires env values from `.env.production.example` |
| `docker-compose.monitoring.yml` | Canonical monitoring sidecar stack | Prometheus, Grafana, Loki, Promtail, cAdvisor, node-exporter |

## Full Local Stack / Full Stack Local

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

## Infra-only Development / Chỉ Chạy Hạ Tầng

```bash
docker compose -f docker/docker-compose.infra.yml up -d
pnpm dev
```

Use this when backend services are run from source rather than as containers.

Dùng khi backend services chạy từ source thay vì container.

## Production-like Validation / Kiểm Tra Production-like

```bash
docker compose --env-file .env.production.example -f docker-compose.prod.yml config
```

Do not place real secrets in `.env.production.example`; use local env files or a secret manager.

Không đặt secret thật trong `.env.production.example`; dùng local env file hoặc secret manager.

## Monitoring / Quan Sát

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

`monitoring/docker-compose.yml` được giữ làm tham chiếu cho tới khi hợp nhất hoàn toàn thư mục monitoring.

## Health / Health Check

```bash
curl http://localhost:3000/health
curl http://localhost:3000/healthz
curl http://localhost:3000/readyz
curl http://localhost:3000/metrics
```

Health endpoints are outside `/api/v1`.

Health endpoints nằm ngoài `/api/v1`.
