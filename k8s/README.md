# Kubernetes Deployment

## Prerequisites

- Kubernetes cluster 1.27+
- kubectl configured
- NGINX Ingress Controller
- cert-manager (for TLS)

## Quick Deploy

```bash
# Create namespace
kubectl apply -f k8s/namespace.yaml

# Create secrets (edit values first!)
cp k8s/secrets.example.yaml k8s/secrets.yaml
# Edit k8s/secrets.yaml with real values
kubectl apply -f k8s/secrets.yaml

# Deploy services
kubectl apply -f k8s/services/

# Deploy ingress
kubectl apply -f k8s/ingress.yaml

# Verify
kubectl get pods -n crab
kubectl get svc -n crab
```

## Scaling

```bash
# Manual scale
kubectl scale deployment gateway -n crab --replicas=4

# HPA is configured for gateway and ride-service
kubectl get hpa -n crab
```

## Monitoring

```bash
# Check pod health
kubectl get pods -n crab -o wide

# View logs
kubectl logs -f deployment/gateway -n crab
kubectl logs -f deployment/auth-service -n crab

# Port forward for debugging
kubectl port-forward svc/gateway 3000:3000 -n crab
```

## Rolling Updates

```bash
# Update image
kubectl set image deployment/gateway gateway=ghcr.io/jasontm17/crab-gateway:v1.1.0 -n crab

# Watch rollout
kubectl rollout status deployment/gateway -n crab

# Rollback if needed
kubectl rollout undo deployment/gateway -n crab
```
