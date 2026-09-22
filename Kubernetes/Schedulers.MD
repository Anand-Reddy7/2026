# Schedulers

![image](images/Scheduler.png)

- Show Lables
```sh
kubectl get nodes --show-labels
```

- Create a Label for Nodes

```sh
kubectl label node worker-1 env=prod
kubectl label node worker-2 env=prod
kubectl label node worker-1 env=dev
```

- Remove a Label for Node 

```sh
kubectl label node worker-1 env-
kubectl label node worker-2 env-
```

# nodeSelector (AND-style value set)

The scheduler decides where the Pod should run based on resources, constraints, taints, etc.

But sometimes you have a requirement:
```
"This application must run only on nodes that have SSD storage."
That's where node labels + nodeSelector can be used.
```

Importent:

- nodeSelector provides simple exact-match, AND-style label selection.
- nodeSelector isn't convenient for expressing this OR-style value set.


```yml
apiVersion: v1
kind: Pod
metadata:
  name: hpcc-scheduler-test
  namespace: prod

spec:
  nodeSelector:
    env: prod
    env: dev

  containers:
    - name: nginx
      image: nginx:latest
```

## What happens if no node matches?

```
You should find a scheduling failure explaining that nodes didn't match the Pod's node selector/affinity.

This is exactly the kind of thing you investigate when a production Pod is stuck in Pending.
```

# nodeName

nodeName directly assigns the Pod to a specific node rather than expressing a label-based scheduling requirement.

```sh
nodeName: worker-1
```

# Node Affinity ( OR-style value set )

Node Affinity is a more powerful and flexible version of nodeSelector. It lets you tell the scheduler which nodes a Pod must run on or which nodes it should prefer.

Node Affinity lets us express requirements such as:

```
MUST run on:
    disk = ssd OR nvme

SHOULD PREFER:
    zone = zone-a

MUST NOT run on:
    environment = dev
```

```yml
affinity:
  nodeAffinity:

    requiredDuringSchedulingIgnoredDuringExecution:

      nodeSelectorTerms:
        - matchExpressions:
            - key: disk
              operator: In
              values:
                - ssd
                - nvme
```

## requiredDuringSchedulingIgnoredDuringExecution

```
Rule matches     → Pod can be scheduled
Rule doesn't     → Pod cannot be scheduled
```

After the Pod is already running, a later label change doesn't normally cause Kubernetes to evict it because this rule no longer matches.


## preferredDuringSchedulingIgnoredDuringExecution

## Node Affinity operators

This is where Node Affinity becomes much more powerful than nodeSelector.

```yml
In
NotIn
Exists
DoesNotExist
Gt
Lt
```

# Pod Affinity.

Pod Affinity tells Kubernetes to place a Pod near other Pods matching particular labels.

Try to place my frontend Pod on a node where a backend Pod is already running.

```
Node Affinity
→ Schedule based on NODE labels

Pod Affinity
→ Schedule based on OTHER POD labels
```


```yml
apiVersion: v1
kind: Pod
metadata:
  name: frontend
  namespace: prod
  labels:
    app: frontend

spec:

  affinity:
    podAffinity:

      requiredDuringSchedulingIgnoredDuringExecution:

        - labelSelector:
            matchExpressions:
              - key: app
                operator: In
                values:
                  - backend

          topologyKey: kubernetes.io/hostname

  containers:
    - name: frontend
      image: nginx:latest
```

# Pod Anti-Affinity (Do not schedule this Pod onto a node that already has another matching app=hpcc Pod.)

Pod Affinity = place my Pod near certain other Pods.

Pod Anti-Affinity = avoid placing my Pod in the same topology domain as certain other Pods.

```yml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: hpcc-deployment
  namespace: prod

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
      affinity:
        podAntiAffinity:

          requiredDuringSchedulingIgnoredDuringExecution:

            - labelSelector:
                matchExpressions:
                  - key: app
                    operator: In
                    values:
                      - hpcc

              topologyKey: kubernetes.io/hostname

      containers:
        - name: hpcc-app
          image: nginx:latest
```

# Taints and Tolarations

A taint is placed on a NODE to repel Pods. A toleration is placed on a POD to allow that Pod to tolerate the taint.

```
Imagine your cluster has:

worker-1 → normal applications
worker-2 → normal applications
worker-3 → dedicated GPU node

worker-3 is expensive and should be reserved for special workloads.

Without any restriction, the scheduler could potentially put an ordinary nginx Pod there.
```

### Taint the Node

```sh
kubectl taint nodes <node-name> key=value:effect

kubectl taint nodes worker-1 workload=hpcc:NoSchedule
```

### What is the effect?

```sh
NoSchedule
PreferNoSchedule
NoExecute
```

### NoSchedule (Don't schedule new Pods onto this node unless they tolerate the taint.)
```
                     Existing Pod     New Pod

NoSchedule              stays          blocked

NoExecute             evicted*         blocked
```


```yml
apiVersion: v1
kind: Pod
metadata:
  name: hpcc-taint-test
  namespace: prod
spec:

  tolerations:
    - key: "workload"
      operator: "Equal"
      value: "hpcc"
      effect: "NoSchedule"

  containers:
    - name: nginx
      image: nginx:latest
```

```
Taints are applied to nodes to repel Pods, while tolerations are applied to Pods to allow them to tolerate matching node taints. NoSchedule prevents new non-tolerating Pods from being scheduled, PreferNoSchedule is a soft avoidance rule, and NoExecute can additionally evict existing non-tolerating Pods. A toleration does not attract a Pod to a node; when I need dedicated nodes, I typically combine taints/tolerations with nodeSelector or Node Affinity to both restrict other workloads and place the intended workloads there.
```