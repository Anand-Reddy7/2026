# Helm

Helm is a package manager for Kubernetes that lets us package, configure, install, upgrade and manage Kubernetes applications using Helm charts.

A Helm chart primarily packages Kubernetes manifests/templates and associated configuration.


```sh
# Create
helm create hpcc-chart

# Validate
helm lint ./hpcc-chart

# Render
helm template hpcc-dev ./hpcc-chart

# Install
helm install hpcc-dev ./hpcc-chart -n dev

# Install or upgrade
helm upgrade --install hpcc-dev ./hpcc-chart -n dev

# Environment values
helm upgrade --install hpcc-dev ./hpcc-chart \
  -n dev -f values-dev.yaml

# List
helm list -n dev
helm list -A

# Status
helm status hpcc-dev -n dev

# Values
helm get values hpcc-dev -n dev

# Rendered deployed manifests
helm get manifest hpcc-dev -n dev

# History
helm history hpcc-dev -n dev

# Upgrade
helm upgrade hpcc-dev ./hpcc-chart -n dev

# Rollback
helm rollback hpcc-dev 2 -n dev

# Uninstall
helm uninstall hpcc-dev -n dev

# Repositories
helm repo list
helm repo add <name> <url>
helm repo update
helm search repo <keyword>

# Inspect external chart
helm show values <chart>

# Package
helm package hpcc-chart

# Debug
helm install hpcc-dev ./hpcc-chart \
  -n dev --dry-run --debug
```

```
                       ONE HELM CHART
                         hpcc-chart
                             │
              ┌──────────────┼──────────────┐
              │              │              │
              ▼              ▼              ▼
       values-dev.yaml values-stage.yaml values-prod.yaml
              │              │              │
              ▼              ▼              ▼
           DEV             STAGE           PROD
              │              │              │
        hpcc-dev         hpcc-stage      hpcc-prod
        1 replica        2 replicas      4 replicas
```

```sh
helm upgrade --install hpcc-prod ./hpcc-chart \
  -n prod \
  --create-namespace \
  -f ./hpcc-chart/values-prod.yaml

helm upgrade --install hpcc-prod ./hpcc-chart \
  -n prod \
  --create-namespace \
  -f ./hpcc-chart/values-stage.yaml
```