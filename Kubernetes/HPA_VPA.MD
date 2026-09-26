# HPA (Horizontal Pod AutoScaling)

Automatically increase or decrease the number of Pod replicas based on workload/metrics.

key concept is a 5-minute (300-second) scale-down stabilization window.

```
HPA
Horizontal Pod Autoscaler
→ changes replica count


VPA
Vertical Pod Autoscaler
→ changes Pod resource requests/recommendations
```

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hpcc-deployment
  namespace: prod
spec:
  replicas: 1

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

          resources:
            requests:
              cpu: 100m
              memory: 128Mi
            limits:
              cpu: 200m
              memory: 256Mi
```

## HPA file

```yml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler

metadata:
  name: hpcc-hpa
  namespace: dev

spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpcc-deployment

  minReplicas: 1
  maxReplicas: 5

  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

### knowing the conceptual formula is useful:

```
Desired Replicas ≈

Current Replicas
      ×
Current Metric
──────────────
Desired Metric
```

```sh
# check the Pod metrics
kubectl top pods -n dev
```


# VPA ( Vertical Pod Autoscaler )

VPA is not generally installed automatically with Kubernetes. You need VPA components/controllers installed before creating VPA resources.


VPA, or Vertical Pod Autoscaler, right-sizes CPU and memory resources for Kubernetes workloads based on observed usage. Unlike HPA, which changes the number of replicas, VPA recommends or applies resource-request changes to individual Pods. It consists conceptually of a recommender and components responsible for applying recommendations. Depending on the cluster capabilities and VPA configuration, applying changes may involve Pod replacement or supported in-place resizing. I would usually begin with recommendation-only mode to evaluate its recommendations before enabling automatic changes.

VPA can also be configured to apply resource recommendations automatically, depending on the VPA version/configuration and cluster capabilities.


```
Changes RESOURCES assigned to Pods

CPU:    100m → 500m
Memory: 128Mi → 512Mi
```

```
VPA observes
    ↓
VPA recommends

CPU: 350m
Memory: 400Mi
    ↓
But Deployment/Pod isn't
automatically resized by VPA
```

```yml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: hpcc-vpa
  namespace: dev

spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: hpcc-deployment

  updatePolicy:
    updateMode: "Off"

# Notes: (updateMode: "Off" does not mean VPA is completely disabled.)
Observe workload
      ↓
Calculate recommendation
      ↓
Show recommendation
      ↓
Do NOT automatically apply it
```

