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

