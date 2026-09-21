# Pod

A Pod is the smallest deployable unit in Kubernetes.

```text
Kubernetes
    ↓
   Pod
    ↓
Container

Pod
├── Application container
└── Sidecar container
```

Note: A Pod can contain multiple containers called multi-container Pods

## Basic Structure 

```text
apiVersion → Which Kubernetes API/version?
kind       → What do I want to create?
metadata   → What is its identity?
spec       → How should it be configured?
```

## Pod Creation

```yaml
---
apiVersion: v1
kind: Pod
metadata:
    name: hpcc-pod
    namespace: dev
    labels:
        app: hpcc

spec:
    containers:
        - name: hpcc-app
          image: nginx:latest
          ports:
            - containerPort: 80
          resources:
            requests:
                cpu: "100m"
                memory: "128Mi"
            limits:
                cpu: "200m"
                memory: "256Mi"
```

# ReplicaSet

ReplicaSet ensures the desired number of matching Pod replicas are running. It uses label selectors to identify Pods and a Pod template to create them. The ReplicaSet controller in kube-controller-manager performs reconciliation. In production, ReplicaSets are normally managed by Deployments because Deployments add rollout, rollback, update strategy, and revision management.

A ReplicaSet is a Kubernetes workload controller that ensures a specified number of identical Pod replicas are running at any given time. A ReplicaSet is managed/reconciled by the ReplicaSet controller, which runs as part of the kube-controller-manager on the control plane.

```yaml
---
apiVersion: apps/v1
kind: ReplicaSet
metadata:
    name: hpcc-replicaset
    namespace: dev
    labels:
        app: hpcc

spec:
    replicas: 3

    selector:
        matchLabels:
            app: hpcc
    
    template:
        metadata:
            labels:
                app: hpcc

        spec:
            containers:
              - name: hpcc-app
                image: nginx:latest
                ports:
                    - containerPort: 80
                resources:
                    requests:
                        cpu: "100m"
                        memory: "128Mi"
                    limits:
                        cpu: "200m"
                        memory: "256Mi"
```


## Troble shoot when the specified servers are not up with replica set.

```shell
# Look at the ReplicaSet Events
kubectl describe rs hpcc-replicaset -n dev

# get RS
kubectl get rs hpcc-replicaset -n dev

# delete
kubectl delete rs hpcc-replicaset -n dev
```


# Deployment 

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
    name: hpcc-deployment
    namespace: dev
    labels:
        app: hpcc

spec:
    replicas: 4

    strategy:
        type: RollingUpdate
        rollingUpdate:
            maxSurge: 25%
            maxUnavailable: 25%


    selector:
        matchLabels:
            app: hpcc
    
    template:
        metadata:
            labels:
                app: hpcc

        spec:
            containers:
              - name: hpcc-app
                image: nginx:1.28
                ports:
                    - containerPort: 80
                resources:
                    requests:
                        cpu: "100m"
                        memory: "128Mi"
                    limits:
                        cpu: "200m"
                        memory: "256Mi"
```

## Deploymene RollOut

Note: One important detail: not every kubectl apply creates a new ReplicaSet. A new ReplicaSet is created when the Deployment's Pod template changes

### How long are old ReplicaSets kept? 
```
spec:
  revisionHistoryLimit: 10
```
The default is generally 10 old ReplicaSets/revisions retained for rollback history.


```shell
[root@control-plane-1 Apps]# kubectl get deployment,rs,pod -n dev
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hpcc-deployment   4/4     4            4           21m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/hpcc-deployment-5fcfc8b9fc   4         4         4       2m34s
replicaset.apps/hpcc-deployment-776c4fb587   0         0         0       21m

NAME                                   READY   STATUS    RESTARTS   AGE
pod/hpcc-deployment-5fcfc8b9fc-2n75p   1/1     Running   0          2m34s
pod/hpcc-deployment-5fcfc8b9fc-64khv   1/1     Running   0          2m28s
pod/hpcc-deployment-5fcfc8b9fc-msxj8   1/1     Running   0          2m27s
pod/hpcc-deployment-5fcfc8b9fc-ptwg6   1/1     Running   0          2m34s
[root@control-plane-1 Apps]#
[root@control-plane-1 Apps]# kubectl rollout undo deployment hpcc-deployment -n dev
deployment.apps/hpcc-deployment rolled back
[root@control-plane-1 Apps]# 
[root@control-plane-1 Apps]# kubectl get deployment,rs,pod -n dev
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hpcc-deployment   4/4     4            4           23m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/hpcc-deployment-5fcfc8b9fc   0         0         0       4m36s
replicaset.apps/hpcc-deployment-776c4fb587   4         4         4       23m

NAME                                   READY   STATUS    RESTARTS   AGE
pod/hpcc-deployment-776c4fb587-8tg4q   1/1     Running   0          21s
pod/hpcc-deployment-776c4fb587-d4fsx   1/1     Running   0          18s
pod/hpcc-deployment-776c4fb587-dvql6   1/1     Running   0          17s
pod/hpcc-deployment-776c4fb587-pgnz8   1/1     Running   0          21s
[root@control-plane-1 Apps]# 

[root@control-plane-1 Apps]# kubectl rollout history deployment/hpcc-deployment -n dev
deployment.apps/hpcc-deployment 
REVISION  CHANGE-CAUSE
2         <none>
3         <none>

[root@control-plane-1 Apps]# 

## With RollingUpdate, Kubernetes doesn't simply destroy everything first. Your rollout strategy and Pod readiness determine how far the transition can proceed.

[root@control-plane-1 Apps]# kubectl get deployment,rs,pod -n dev
NAME                              READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/hpcc-deployment   3/4     2            3           40m

NAME                                         DESIRED   CURRENT   READY   AGE
replicaset.apps/hpcc-deployment-5fcfc8b9fc   0         0         0       22m
replicaset.apps/hpcc-deployment-776c4fb587   3         3         3       40m
replicaset.apps/hpcc-deployment-7d47789467   2         2         0       34s

NAME                                   READY   STATUS         RESTARTS   AGE
pod/hpcc-deployment-776c4fb587-8tg4q   1/1     Running        0          18m
pod/hpcc-deployment-776c4fb587-d4fsx   1/1     Running        0          17m
pod/hpcc-deployment-776c4fb587-pgnz8   1/1     Running        0          18m
pod/hpcc-deployment-7d47789467-q9g8j   0/1     ErrImagePull   0          34s
pod/hpcc-deployment-7d47789467-vqpfb   0/1     ErrImagePull   0          34s
[root@control-plane-1 Apps]# 
```

## Deployment RollOut details

```shell
kubectl rollout status deployment/hpcc-deployment -n dev

kubectl rollout history deployment/hpcc-deployment -n dev

kubectl rollout undo deployment/hpcc-deployment -n dev

kubectl rollout undo deployment/hpcc-deployment --to-revision=2 -n dev

kubectl rollout pause deployment/hpcc-deployment -n dev

kubectl rollout resume deployment/hpcc-deployment -n dev

kubectl describe deployment hpcc-deployment -n dev
```



# Service

A Kubernetes Service provides a stable network endpoint for a dynamic group of Pods.

```text
                 Service
              10.96.x.x:80
                   │
             ┌─────┼─────┐
             ↓     ↓     ↓
           Pod-1 Pod-2 Pod-3
```

Pods may:

```shell
crash,
restart,
scale up/down,
be replaced during Deployment rollouts,
```

while the Service remains stable.

## Service types

```text
Kubernetes Service
│
├── ClusterIP
│      └── Internal cluster access
│
├── NodePort
│      └── Exposes through a port on nodes // Default NodePort range is 30000–32767
│
├── LoadBalancer
│      └── Integrates with an external/cloud load balancer
│
└── ExternalName
       └── DNS alias to an external name
```

```text
Services
├── ClusterIP       ✅ Done
├── NodePort        ✅ Done
├── LoadBalancer    ← NEXT
├── ExternalName
├── Headless Service
├── Service discovery / DNS
└── EndpointSlice   ← understand more deeply
```

```yaml
---
apiVersion: apps/v1
kind: Deployment
metadata:
    name: hpcc-deployment
    namespace: dev
    labels:
        app: hpcc

spec:
    replicas: 4

    strategy:
        type: RollingUpdate
        rollingUpdate:
            maxSurge: 25%
            maxUnavailable: 25%


    selector:
        matchLabels:
            app: hpcc
    
    template:
        metadata:
            labels:
                app: hpcc

        spec:
            containers:
              - name: hpcc-app
                image: nginx:1.28
                ports:
                    - containerPort: 80
                resources:
                    requests:
                        cpu: "100m"
                        memory: "128Mi"
                    limits:
                        cpu: "200m"
                        memory: "256Mi"

# Cluster IP service
---
apiVersion: v1
kind: Service
metadata:
    name: hpcc-service
    namespace: dev

spec:
    selector:
        app: hpcc

    type: ClusterIP

    ports:
    - protocol: TCP
      port: 8080
      targetPort: 80

# NodePort
---
apiVersion: v1
kind: Service
metadata: 
    name: hpcc-service
    namespace: dev

spec:
    selector:
        app: hpcc
    
    type: NodePort

    ports:
    - protocol: TCP
      port: 80 //service Port
      targetPort: 80 // Container Port
      NodePort: 30080 // NodePort

# LoadBalancer
---
apiVersion: v1
kind: Service
metadata: 
    name: hpcc-service
    namespace: dev

spec:
    selector:
        app: hpcc
    
    type: LoadBalancer

    ports:
    - protocol: TCP
      port: 80
      targetPort: 80
      nodePort: 30080 // If not declared LB will create a random port of NodePort
```

```shell
[root@control-plane-1 Apps]# kubectl get endpointslice -n dev -o wide
NAME                 ADDRESSTYPE   PORTS   ENDPOINTS                       AGE
hpcc-service-czjb7   IPv4          80      192.168.226.94,192.168.226.95   3m39s
[root@control-plane-1 Apps]# 
```

# ExternalName Service

```text
Pod
 │
 │ connects to "database"
 ↓
Kubernetes DNS
 │
 │ database.dev.svc.cluster.local
 ↓
mydb.company.com
 │
 ↓
External database
```

```yaml
kind: Service
metadata:
  name: database
spec:
  type: ExternalName
  externalName: production-db.company.internal
```

An ExternalName Service provides a Kubernetes DNS name that aliases an external DNS hostname. It doesn't create a ClusterIP or proxy traffic to Pods. Kubernetes DNS returns a CNAME pointing to the configured external hostname.


# Headless Service

A Headless Service is still a Kubernetes Service, but Kubernetes does not assign a ClusterIP to it.

A Headless Service is a Kubernetes Service configured with clusterIP: None. Kubernetes doesn't allocate a virtual ClusterIP for it. DNS discovery exposes the backend endpoints, allowing clients to discover and connect to individual instances. It's commonly used with StatefulSets and distributed systems where individual instance discovery and stable network identity are important.

```
clusterIP: None 

Normal Service
DNS → ClusterIP → backend Pod

Headless Service
DNS → backend endpoints directly

```

# Service Discovery (how does one application running in Kubernetes find another application?)

Service Discovary works with DNS, normally provided by CoreDNS.

Kubernetes primarily provides Service Discovery through DNS. A Service gets a DNS name based on its Service name and namespace, such as hpcc-service.dev.svc.cluster.local. Pods in the same namespace can normally use just hpcc-service. CoreDNS resolves the Service name to its ClusterIP for a normal Service, and Kubernetes Service networking then routes traffic to backend endpoints represented through EndpointSlices. Headless and ExternalName Services have different DNS behavior.

```shell
FQDN — Fully Qualified Domain Name.

hpcc-service . dev . svc . cluster.local
     │          │     │         │
     │          │     │         └── cluster DNS domain
     │          │     └──────────── Service
     │          └────────────────── namespace
     └───────────────────────────── Service name
```

```text
dev namespace

frontend Pod
     │
     │ http://hpcc-service
     ▼
hpcc-service
     ↓
hpcc Pods
```

# EndpointSlices

Service = stable front door. EndpointSlice = list of actual backend endpoints behind that Service.

EndpointSlice is the Kubernetes API resource used to represent the backend network endpoints associated with a Service. For selector-based Services, Kubernetes automatically creates and updates EndpointSlices as matching Pods are created, deleted, or change readiness. EndpointSlices replaced the older Endpoints approach for better scalability by allowing endpoints for a Service to be distributed across multiple objects.

```text
Service
   │
   │ selector
   ▼
EndpointSlice
   │
   ├── backend endpoint
   ├── backend endpoint
   └── backend endpoint
```