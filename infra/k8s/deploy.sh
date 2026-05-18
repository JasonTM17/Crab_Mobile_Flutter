#!/usr/bin/env bash
set -euo pipefail

NAMESPACE=crab
KUBECTL="${KUBECTL:-kubectl}"

echo "[*] Applying namespace + config"
$KUBECTL apply -f 00-namespace.yaml
$KUBECTL apply -f 01-configmap.yaml
$KUBECTL apply -f 02-secret.yaml

echo "[*] Applying data services"
for f in 20-*.yaml 21-*.yaml 22-*.yaml; do
  $KUBECTL apply -f "$f"
done

echo "[*] Waiting for postgres..."
$KUBECTL wait --for=condition=Ready pod -l app=postgres -n $NAMESPACE --timeout=120s

echo "[*] Applying backend services"
for f in 1[0-9]-*.yaml; do
  $KUBECTL apply -f "$f"
done

echo "[*] Applying ingress"
$KUBECTL apply -f 30-ingress.yaml

echo "[*] Status:"
$KUBECTL get pods -n $NAMESPACE
