## Install T3n Repo
```sh
helm repo add t3n https://storage.googleapis.com/t3n-helm-charts
helm repo update
```

## Install Mosquitto Chart
```sh
helm install mosquitto t3n/mosquitto -f values.yaml
```
