# Kubernetes Deployment

<!-- KUBERNETES-EN:START -->
## English Kubernetes Deployment

Kubernetes manifests live under `infra/k8s/`. They provide a production-oriented starting point, not a fully managed cloud platform.

## Apply Order

```bash
kubectl apply -f infra/k8s/00-namespace.yaml
kubectl apply -f infra/k8s/01-configmap.yaml
kubectl apply -f infra/k8s/02-secret.yaml
kubectl apply -f infra/k8s/
```

## Workloads

| Component | Notes |
| --- | --- |
| Gateway | Public API and Socket.IO entrypoint, HPA enabled |
| Backend services | One Deployment and Service per domain service |
| Web admin | Static UI behind service/ingress |
| PostgreSQL, MongoDB | StatefulSets in current manifests |
| Redis | Deployment with ephemeral storage in current manifests |

## Required Production Changes

- Replace placeholder secrets with a real secret manager or sealed secrets.
- Add proper storage classes and backup policy for databases.
- Configure ingress hosts, TLS, and cert-manager.
- Fix probe paths if any manifest still points to `/api/v1/health`; code exposes `/health`, `/healthz`, `/readyz`, and `/metrics` outside `/api/v1`.
- Add network policies if the cluster supports them.
- Validate resource limits and HPA thresholds under real load.

## Verification

```bash
kubectl get pods -n crab
kubectl get svc -n crab
kubectl get hpa -n crab
kubectl logs -n crab deploy/gateway
```

## Rollback

```bash
kubectl rollout history deployment/gateway -n crab
kubectl rollout undo deployment/gateway -n crab
```

Repeat per service if a service-specific deployment fails.
<!-- KUBERNETES-EN:END -->

<!-- KUBERNETES-VI:START -->
## Vietnamese Kubernetes Deployment

Kubernetes manifests nằm trong `infra/k8s/`. Đây là nền tảng triển khai production-oriented, không phải một cloud platform hoàn chỉnh.

## Thứ Tự Apply

```bash
kubectl apply -f infra/k8s/00-namespace.yaml
kubectl apply -f infra/k8s/01-configmap.yaml
kubectl apply -f infra/k8s/02-secret.yaml
kubectl apply -f infra/k8s/
```

## Workloads

| Thành phần | Ghi chú |
| --- | --- |
| Gateway | Entrypoint public cho API và Socket.IO, có HPA |
| Backend services | Mỗi domain service có một Deployment và Service |
| Web admin | Static UI sau service/ingress |
| PostgreSQL, MongoDB | StatefulSets trong manifests hiện tại |
| Redis | Deployment với ephemeral storage trong manifests hiện tại |

## Việc Cần Làm Trước Production

- Thay placeholder secrets bằng secret manager hoặc sealed secrets.
- Thêm storage class và backup policy phù hợp cho database.
- Cấu hình ingress hosts, TLS và cert-manager.
- Sửa probe path nếu manifest còn dùng `/api/v1/health`; code expose `/health`, `/healthz`, `/readyz`, và `/metrics` ngoài `/api/v1`.
- Thêm network policies nếu cluster hỗ trợ.
- Kiểm tra resource limits và HPA thresholds bằng load thật.

## Kiểm Tra

```bash
kubectl get pods -n crab
kubectl get svc -n crab
kubectl get hpa -n crab
kubectl logs -n crab deploy/gateway
```

## Rollback

```bash
kubectl rollout history deployment/gateway -n crab
kubectl rollout undo deployment/gateway -n crab
```

Lặp lại theo từng service nếu deployment của service đó lỗi.
<!-- KUBERNETES-VI:END -->
