## Install Helm chart
```sh
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

```sh
helm install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.10.1 \
  --set installCRDs=true
```

## Install the ClusterIssuer
```sh
kubectl apply -f lets-encrypt.clusterissuer.yaml
```
