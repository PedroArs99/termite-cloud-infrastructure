## Create Prometheus Namespace
```sh
kubectl apply -f namespace.yaml
```

## Install Prometheus Repo
```sh
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

## Install Grafana Chart
```sh
helm install prometheus prometheus-community/prometheus -f values.yaml
```