# Monitoring Stack

Prometheus + Grafana + Loki observability stack for Crab platform.

## Quick Start

```bash
# Start the main app first
docker compose up -d

# Start monitoring stack
cd monitoring
docker compose up -d
```

## Access

| Service | URL | Credentials |
|---------|-----|-------------|
| Grafana | http://localhost:3100 | admin / crab_admin |
| Prometheus | http://localhost:9090 | - |
| Loki | http://localhost:3101 | - |

## Metrics Exposed

Each service exposes metrics at `GET /metrics`:

- `http_requests_total` — Total HTTP requests (labels: method, path, status)
- `http_request_duration_seconds` — Request duration histogram
- `websocket_connections_active` — Current WebSocket connections
- `ride_pending_requests` — Rides waiting for driver
- `food_orders_active` — Active food orders
- `payment_transactions_total` — Payment transactions processed

## Alerts

Configured alerts in `prometheus/alerts.yml`:

| Alert | Condition | Severity |
|-------|-----------|----------|
| ServiceDown | Service unreachable for 1m | Critical |
| HighResponseTime | p95 > 500ms for 5m | Warning |
| HighErrorRate | 5xx rate > 5% for 5m | Critical |
| HighMemoryUsage | > 450MB for 5m | Warning |
| DatabaseConnectionPoolExhausted | > 80 connections for 2m | Critical |
| RedisHighMemory | > 85% usage for 5m | Warning |
| RideServiceQueueBacklog | > 50 pending rides for 3m | Warning |

## Architecture

```
Services ──metrics──▶ Prometheus ──query──▶ Grafana
    │                     │
    │                     └── Alertmanager (optional)
    │
    └──logs──▶ Loki ──query──▶ Grafana
```
