## Install argo cd yaml file:
```bash
curl -o argocd-install.yaml https://raw.githubusercontent.com/argoproj/argo-cd/v2.9.3/manifests/install.yaml
```


## Destroy eveything:
```bash
terraform destroy -auto-approve
```
## Start fresh after destroy/ first time running:
```bash
terraform apply -auto-approve && \
export KUBECONFIG="$(pwd)/output/kubeconfig.yaml" && \
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s && \
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)" && \
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

## ***********************************************************************

## Stop and keep data:
```bash
# FIRST CTRL + C  TO STOP PORT FORWARDING
docker stop my-k3s-cluster-server-0 my-k3s-cluster-agent-0 my-k3s-cluster-agent-1
```

## Start up again:
```bash
docker start my-k3s-cluster-server-0 my-k3s-cluster-agent-0 my-k3s-cluster-agent-1

# Wait ~10 seconds for k3s to initialize, then:
export KUBECONFIG="$(pwd)/output/kubeconfig.yaml"
kubectl wait --for=condition=ready pod -l app.kubernetes.io/name=argocd-server -n argocd --timeout=300s
echo "Password: $(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
kubectl port-forward svc/argocd-server -n argocd 8080:443
```

