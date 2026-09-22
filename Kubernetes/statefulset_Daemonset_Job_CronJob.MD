#  STATEFULSET
It provides stable Pod identity, stable network identity, ordered deployment/scaling, and can provide dedicated persistent storage for each replica using volumeClaimTemplates


```
A StatefulSet is a Kubernetes workload controller used when application replicas need a stable identity. Unlike a Deployment, where Pods are generally interchangeable and have generated names, StatefulSet Pods get predictable ordinal names such as mysql-0, mysql-1, and mysql-2.

It provides stable Pod identity, stable network identity, ordered deployment/scaling, and can provide dedicated persistent storage for each replica using volumeClaimTemplates. If mysql-1 is deleted and recreated, it comes back with the same StatefulSet identity and can reuse its existing PVC and persistent data.

We commonly use a Headless Service with a StatefulSet when individual replicas need predictable DNS names. StatefulSets are useful for workloads such as databases, Kafka-like brokers, or distributed systems where individual replica identity and storage matter.
```

```shell
1. Stable Pod identity
   hpcc-db-0
   hpcc-db-1
   hpcc-db-2

2. Stable network identity
   predictable per-Pod DNS

3. Stable per-replica storage
   Pod-0 → PVC-0
   Pod-1 → PVC-1
   Pod-2 → PVC-2
```

```yml
# -----------------------------------------
# 1. Headless Service
# -----------------------------------------
apiVersion: v1
kind: Service
metadata:
  name: hpcc-db
  namespace: prod
spec:
  clusterIP: None
  selector:
    app: hpcc-db
  ports:
    - name: http
      port: 80
      targetPort: 80

---
# -----------------------------------------
# 2. StatefulSet
# -----------------------------------------
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: hpcc-db
  namespace: prod

spec:
  serviceName: hpcc-db
  replicas: 3

  selector:
    matchLabels:
      app: hpcc-db

  template:
    metadata:
      labels:
        app: hpcc-db

    spec:
      containers:
        - name: hpcc-db
          image: nginx:latest

          ports:
            - containerPort: 80

          volumeMounts:
            - name: data
              mountPath: /data

  # Creates a separate PVC for every StatefulSet Pod
  volumeClaimTemplates:
    - metadata:
        name: data
      spec:
        accessModes:
          - ReadWriteOnce

        storageClassName: fast-storage

        resources:
          requests:
            storage: 10Gi
```



# Daemonsets

A DaemonSet is a Kubernetes workload controller that ensures a Pod runs on every eligible node or a selected subset of nodes. It's commonly used for node-level services such as log collectors, monitoring agents, CNI components, security agents and CSI node components. Unlike a Deployment, we don't normally specify a replica count; the number of DaemonSet Pods is driven by the eligible nodes, and when a new eligible node joins, the DaemonSet automatically ensures its Pod runs there.

A node-level log collector generally needs to run on every node where workloads produce logs. With a Deployment, I specify a replica count and Kubernetes doesn't inherently guarantee one replica per node. A DaemonSet automatically maintains a Pod on each eligible node and automatically covers newly added eligible nodes, which makes it appropriate for node-level agents such as log collectors, monitoring agents, networking components and some storage components.

```yml
apiVersion: apps/v1
kind: DaemonSet

metadata:
  name: hpcc-agent
  namespace: prod

spec:
  selector:
    matchLabels:
      app: hpcc-agent

  template:
    metadata:
      labels:
        app: hpcc-agent

    spec:
      containers:
        - name: hpcc-agent
          image: nginx:latest
          ports:
            - containerPort: 80
```

# Job

A Job is used when you want Kubernetes to execute a task until it completes successfully, rather than keep an application running forever.

```text
Job
    ↓
Start Pod
    ↓
Execute task
    ↓
Task succeeds
    ↓
STOP
    ↓
Job = Complete
```

```yml
---
apiVersion: batch/v1
kind: Job
metadata:
  name: hpcc-job
  namespace: prod

spec:
  completions: 6 // 6 pods need to create
  parallelism: 2 // Create 2 pods at a time. Once this 2 done create next
  backoffLimit: 3 // failed one restart 3 times max before crashloop

  ttlSecondsAfterFinished: 60 // Delete pods after specific time of completion

  template:
    spec:
      restartPolicy: Never

      containers:
        - name: hpcc-pod-job
          image: busybox

          command:
            - sh
            - -c
            - | 
              echo "hostname is $(hostname)"
              sleep 10
              echo "Completed !!"
```


# CronJob

Run a Kubernetes Job automatically on a schedule.

```text
Database backup every night
Log cleanup every hour
Report generation every Monday
Batch processing every 10 minutes
```

```yml
---
apiVersion: batch/v1
kind: CronJob

metadata:
  name: hpcc-cronjob
  namespace: prod

spec:
  schedule: "*/1 * * * *"

  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: Never

          containers:
            - name: hpcc-cronjob
              image: busybox
              command:
                - sh
                - -c
                - |
                  echo "CronJob started on $(hostname)"
                  date
                  sleep 10
                  echo "CronJob completed"
```