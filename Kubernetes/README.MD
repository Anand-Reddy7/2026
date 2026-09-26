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

# Write a Python Program to deploy the Deployment & Service. Also check the rollback status. if Deployment failed them rollout to the old deployment.

```py
# kubectl apply -f deployment.yml
# kubectl apply -f service.yml
# kubectl rollout status deployment/my-app --timeout=120s
# kubectl rollout undo deployment/my-app
import subprocess
import sys


def run(command):
    print(f"Running: {command}")

    result = subprocess.run(
        command,
        shell=True
    )

    return result.returncode == 0


# 1. Apply deployment
if not run("kubectl apply -f deployment.yml"):
    print("Failed to apply deployment.yml")
    sys.exit(1)


# 2. Apply service
if not run("kubectl apply -f service.yml"):
    print("Failed to apply service.yml")
    sys.exit(1)


# 3. Check deployment rollout
if not run("kubectl rollout status deployment/my-app --timeout=120s"):

    print("Deployment failed. Starting rollback...")

    # 4. Rollback deployment
    if run("kubectl rollout undo deployment/my-app"):
        print("Rollback initiated successfully.")
    else:
        print("Rollback failed.")

    sys.exit(1)


print("Deployment completed successfully.")
```


