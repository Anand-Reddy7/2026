# K8s

```
KUBERNETES ROADMAP

1. Cluster Fundamentals
   ├── Control Plane / Worker architecture       ✅
   ├── kubeadm cluster                           ✅
   ├── etcd / API Server / Scheduler basics      ✅
   ├── containerd                                ✅
   └── Calico networking                         ✅

2. Core Objects
   ├── Namespace                                 ✅
   ├── Pod                                       ✅
   ├── ReplicaSet                                ✅
   └── Deployment                                ✅

3. Services & Networking Basics
   ├── ClusterIP                                 ✅
   ├── NodePort                                  ✅
   ├── LoadBalancer                              ✅
   ├── ExternalName                              ✅
   ├── Headless Service                          ✅
   ├── CoreDNS / Service Discovery               ✅
   └── EndpointSlice                             ✅

4. Application Configuration
   ├── Readiness / Liveness / Startup probes     ✅
   ├── ConfigMap                                 ✅
   └── Secret                                    ✅

5. Resources
   ├── Requests / Limits                         ✅
   ├── ResourceQuota                             ✅
   ├── LimitRange concepts                       ✅
   └── Metrics Server / kubectl top              ✅

6. Storage
   ├── Container filesystem                      ✅
   ├── emptyDir                                  ✅
   ├── hostPath                                  ✅
   ├── PV / PVC                                  ✅
   ├── Static provisioning                       ✅
   ├── Access Modes                              ✅
   ├── Reclaim Policies                          ✅
   ├── StorageClass                              ✅
   ├── Dynamic Provisioning                      ✅
   └── CSI / Cloud Storage                       ✅


7. Workload Controllers                         ⏳ NEXT
   ├── StatefulSet
   ├── DaemonSet
   ├── Job
   └── CronJob

8. Ingress                                      ⏳
   ├── Ingress resource
   ├── Ingress Controller
   ├── Host-based routing
   ├── Path-based routing
   └── TLS / HTTPS

9. Scheduling                                   ⏳
   ├── nodeSelector
   ├── Node Affinity
   ├── Pod Affinity / Anti-Affinity
   ├── Taints
   └── Tolerations

10. Autoscaling                                 ⏳
    ├── HPA
    ├── CPU / Memory metrics
    └── Scaling behavior

11. Security                                    ⏳
    ├── ServiceAccount
    ├── RBAC
    │   ├── Role
    │   ├── ClusterRole
    │   ├── RoleBinding
    │   └── ClusterRoleBinding
    └── SecurityContext

12. Network Security                            ⏳
    └── NetworkPolicy

13. Production Troubleshooting                  ⏳
    ├── Pending Pods
    ├── CrashLoopBackOff
    ├── ImagePullBackOff
    ├── OOMKilled
    ├── FailedScheduling
    ├── DNS issues
    ├── Service connectivity
    ├── Storage problems
    └── kubectl logs/events/describe/debug

14. Cluster Administration                      ⏳
    ├── kubeconfig / contexts
    ├── cordon
    ├── drain
    ├── uncordon
    ├── etcd backup / restore
    ├── certificates
    ├── kubeadm upgrades
    └── HA concepts
```

## Kubernetes YAML validation

```shell
# 1. Client-side check
kubectl apply -f namespaces.yaml --dry-run=client

# 2. Server-side validation
kubectl apply -f namespaces.yaml --dry-run=server

# 3. Review what will be applied
kubectl diff -f namespaces.yaml

# 4. Actually apply
kubectl apply -f namespaces.yaml
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