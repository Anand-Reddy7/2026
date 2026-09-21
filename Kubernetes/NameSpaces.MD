## NameSpaces

A Namespace is a logical partition inside a Kubernetes cluster.

```text
Kubernetes Cluster
│
├── Namespace: dev
│     ├── Pods
│     ├── Deployments
│     ├── Services
│     └── ConfigMaps
│
├── Namespace: test
│     ├── Pods
│     ├── Deployments
│     └── Services
│
└── Namespace: prod
      ├── Pods
      ├── Deployments
      └── Services
```

## Commands

```shell
kubectl get namespaces (or) kubectl get ns
kubectl create ns dev
kubectl delete ns dev
kubectl describe ns dev
kubectl get resourcequota -n dev
kubectl get all -n dev
kubectl get resourcequota,limitrange -n dev
```

## Create Namespace with Resource Quota

```yaml
# ==========================
# Dev NameSpace
# ==========================
---
apiVersion: v1
kind: Namespace
metadata:
  name: dev

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-resource-quota
  namespace: dev

spec:
  hard:
    requests.cpu: "500m"
    requests.memory: "1Gi"
    limits.cpu: "1"
    limits.memory: "2Gi"
    pods: "10"

# ==========================
# Prod NameSpace
# ==========================
---
apiVersion: v1
kind: Namespace
metadata:
  name: prod

---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: prod-resource-quota
  namespace: prod

spec:
  hard:
    requests.cpu: "1"
    requests.memory: "1Gi"
    limits.cpu: "2"
    limits.memory: "3Gi"
    pods: "20"
```

```shell
[root@control-plane-1 Cluster]# kubectl get resourcequota -n dev
NAME                 REQUEST                                                    LIMIT                                   AGE
dev-resource-quota   pods: 0/10, requests.cpu: 0/500m, requests.memory: 0/1Gi   limits.cpu: 0/1, limits.memory: 0/2Gi   2m48s
[root@control-plane-1 Cluster]# kubectl get resourcequota -n prod
NAME                  REQUEST                                                 LIMIT                                   AGE
prod-resource-quota   pods: 0/20, requests.cpu: 0/1, requests.memory: 0/1Gi   limits.cpu: 0/2, limits.memory: 0/3Gi   32s
[root@control-plane-1 Cluster]# 
```

## If Pods created in the above Namespace without spesifying the resources then what will happen ?

```shell
[root@control-plane-1 Apps]# kubectl apply -f hpcc_pods.yml
Error from server (Forbidden): error when creating "hpcc_pods.yml": pods "hpcc-pod" is forbidden: failed quota: dev-resource-quota: must specify limits.cpu for: hpcc-app; limits.memory for: hpcc-app; requests.cpu for: hpcc-app; requests.memory for: hpcc-app
[root@control-plane-1 Apps]# 
```