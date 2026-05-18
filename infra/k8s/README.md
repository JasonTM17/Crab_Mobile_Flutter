# Crab Kubernetes Manifests

## Quick start

```bash
# 1. Edit secrets
kubectl apply -f 00-namespace.yaml
# Edit 02-secret.yaml first
kubectl apply -f 01-configmap.yaml -f 02-secret.yaml

# 2. Deploy data services (postgres, mongo, redis)
kubectl apply -f 20-postgres.yaml -f 21-mongodb.yaml -f 22-redis.yaml

# 3. Deploy backend services
kubectl apply -f 10-gateway.yaml
kubectl apply -f 11-auth-service.yaml
# ... etc

# 4. Deploy ingress
kubectl apply -f 30-ingress.yaml

# Or run all at once
./deploy.sh
```

## Capacity planning

- Gateway: 3-20 replicas (CPU-based HPA)
- Ride/Food services: 3-15 replicas
- Other services: 2-8 replicas
- Postgres: 1 primary (consider operator like Zalando for HA)
- Redis: 1 (consider Redis Cluster for HA + GEO commands)

## Production checklist

- [ ] Replace all REPLACE_ME secrets
- [ ] Configure cert-manager for TLS
- [ ] Set up persistent storage class
- [ ] Configure network policies
- [ ] Set up monitoring (Prometheus + Grafana)
- [ ] Set up log aggregation (Loki)
- [ ] Configure backups for PostgreSQL + MongoDB
