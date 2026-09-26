# Ingress

Ingress is a Kubernetes API resource for defining HTTP/HTTPS Layer-7 routing from an external entry point to Services inside the cluster. It supports capabilities such as host-based and path-based routing and TLS configuration. The Ingress resource only defines routing rules; an Ingress Controller such as an NGINX-based controller or another supported implementation is required to actually process traffic and enforce those rules.


```
PATH-BASED

example.com/frontend
example.com/orders
example.com/payments


HOST-BASED

frontend.example.com
orders.example.com
payments.example.com
```

```
Internet
   │
   ├── Load Balancer #1
   │       ↓
   │   frontend-service
   │
   ├── Load Balancer #2
   │       ↓
   │   orders-service
   │
   └── Load Balancer #3
           ↓
       payments-service
```

That can mean multiple externally exposed load balancers and more external infrastructure to manage.

Ingress gives us a centralized HTTP/HTTPS routing layer:

```

                     Internet
                         │
                         ▼
                  External endpoint
                         │
                         ▼
                Ingress Controller
                         │
              ┌──────────┼──────────┐
              │          │          │
           /frontend   /orders   /payments
              │          │          │
              ▼          ▼          ▼
          frontend     orders     payments
           Service     Service     Service
              │          │          │
              ▼          ▼          ▼
            Pods       Pods       Pods
```

One entry point can route requests to multiple Services.

## Ingress has TWO important pieces
```
Ingress Resource
       +
Ingress Controller
```

### Ingress Resource

```
/orders   → orders-service
/payments → payments-service
```

Configuration describing how HTTP/HTTPS traffic should be routed.

### Ingress Controller
Something has to actually read those rules and process/proxy the network traffic.

That's the Ingress Controller.

Examples include NGINX-based ingress controllers, Traefik and cloud-provider implementations.

```
Ingress Resource
       │
       │ routing configuration
       ▼
Ingress Controller
       │
       │ actually handles/proxies traffic
       ▼
Services
       ▼
Pods
```

### Path Based Routing
```yml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: hpcc-ingress
  namespace: dev

spec:
  rules:
    - host: example.com
      http:
        paths:

          - path: /hpcc
            pathType: Prefix
            backend:
              service:
                name: hpcc-service
                port:
                  number: 80

          - path: /orders
            pathType: Prefix
            backend:
              service:
                name: orders-service
                port:
                  number: 80
```

### Host Based Routing
```
spec:
  rules:

    - host: app.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: frontend-service
                port:
                  number: 80

    - host: api.example.com
      http:
        paths:
          - path: /
            pathType: Prefix
            backend:
              service:
                name: backend-service
                port:
                  number: 80
```