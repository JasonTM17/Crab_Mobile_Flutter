# Operations Runbook / Sổ Tay Vận Hành

This runbook covers common operating actions for local, staging, and production-like environments.

Runbook này bao phủ các thao tác vận hành thường gặp cho local, staging và môi trường gần production.

## Service Health / Kiểm Tra Health

```bash
curl http://localhost:3000/health
curl http://localhost:3000/healthz
curl http://localhost:3000/readyz
curl http://localhost:3000/metrics
```

In Kubernetes:

```bash
kubectl get pods -n crab
kubectl describe pod <pod-name> -n crab
kubectl logs -n crab deploy/gateway --tail=200
```

## Logs / Log

Docker:

```bash
docker compose logs -f gateway
docker compose logs -f auth-service
```

Kubernetes:

```bash
kubectl logs -f -n crab deploy/gateway
kubectl logs -f -n crab deploy/ride-service
```

## Restart / Khởi Động Lại

Docker:

```bash
docker compose restart gateway
```

Kubernetes:

```bash
kubectl rollout restart deployment/gateway -n crab
```

## Rollback / Khôi Phục Phiên Bản

```bash
kubectl rollout history deployment/gateway -n crab
kubectl rollout undo deployment/gateway -n crab
```

For Docker Compose, redeploy a known-good image tag and run:

Với Docker Compose, đổi về image tag ổn định và chạy:

```bash
docker compose -f docker-compose.prod.yml pull
docker compose -f docker-compose.prod.yml up -d
```

## Backup / Sao Lưu

PostgreSQL example:

```bash
docker compose exec postgres pg_dump -U crab crab > crab-postgres.sql
```

MongoDB example:

```bash
docker compose exec mongodb mongodump --archive=/tmp/crab-mongo.archive
docker compose cp mongodb:/tmp/crab-mongo.archive ./crab-mongo.archive
```

Redis is treated as cache/session/queue infrastructure in this repo; decide persistence requirements before production.

Redis trong repo này chủ yếu là cache/session/queue; cần quyết định yêu cầu persistence trước production.

## Restore / Khôi Phục Dữ Liệu

PostgreSQL:

```bash
docker compose exec -T postgres psql -U crab crab < crab-postgres.sql
```

MongoDB:

```bash
docker compose cp ./crab-mongo.archive mongodb:/tmp/crab-mongo.archive
docker compose exec mongodb mongorestore --archive=/tmp/crab-mongo.archive
```

## Incident Triage / Xử Lý Sự Cố

1. Confirm impact: which surface is down, API, mobile, web-admin, or one service?
2. Check gateway health and logs.
3. Check downstream service logs and readiness.
4. Check database/Redis connectivity.
5. Roll back if the issue follows a recent deployment.
6. Create a post-incident note with root cause, fix, and prevention.

1. Xác nhận phạm vi ảnh hưởng: API, mobile, web-admin hay service cụ thể?
2. Kiểm tra gateway health và logs.
3. Kiểm tra logs/readiness của service phía sau.
4. Kiểm tra kết nối database/Redis.
5. Rollback nếu sự cố xuất hiện sau deployment gần nhất.
6. Ghi post-incident note gồm root cause, fix và prevention.
