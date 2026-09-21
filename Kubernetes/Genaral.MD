# K8s

## Kubernetes YAML validation

```shell
# 1. Client-side check
kubectl apply -f namespaces.yaml --dry-run=client

# 2. Server-side validation
kubectl apply -f namespaces.yaml --dry-run=server

# 3. Review what will be applied
kubectl diff -f namespaces.yaml

# 4. Actually apply
kubectl apply -f namespaces.yamlply -f namespaces.yaml --dry-run=server
```

# ApiVsrions

```text
v1
├── Pod
├── Service
├── Namespace
├── ConfigMap
├── Secret
├── ServiceAccount
├── PersistentVolume
├── PersistentVolumeClaim
├── ResourceQuota
└── LimitRange

apps/v1
├── Deployment
├── ReplicaSet
├── StatefulSet
└── DaemonSet

batch/v1
├── Job
└── CronJob

networking.k8s.io/v1
├── Ingress
├── IngressClass
└── NetworkPolicy

rbac.authorization.k8s.io/v1
├── Role
├── RoleBinding
├── ClusterRole
└── ClusterRoleBinding

storage.k8s.io/v1
└── StorageClass

autoscaling/v2
└── HorizontalPodAutoscaler

policy/v1
└── PodDisruptionBudget
```