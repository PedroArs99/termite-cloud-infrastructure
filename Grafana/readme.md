## Create Grafana Namespace
```sh
kubectl apply -f namespace.yaml
```

## Install Grafana Repo
```sh
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update
```

## Install Grafana Chart
```sh
helm install grafana grafana/grafana -f values.yaml
```