# ConfigMaps


```shell
envFrom → load multiple ConfigMap values.
configMapKeyRef → load one specific value.
```

## envFrom

```yaml
# ConfigMaps
---
apiVersion: v1
kind: ConfigMap
metadata:
    name: hpcc-configmap
    namespace: dev

data:
    ENVIRONMENT: "dev"
    VERSION: "1.28"
    APP_NAME: "hpcc"

# Deployment
---
apiVersion: apps/v1
kind: Deployment
metadata:
    name: hpcc-deployment
    namespace: dev
    labels:
        app: hpcc

spec:
    replicas: 3

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
                image: nginx:latest
                ports:
                    - containerPort: 80

                envFrom:
                    - configMapRef:
                        name: hpcc-configmap

                readinessProbe:
                    httpGet:
                        path: /
                        port: 80
                    initialDelaySeconds: 5
                    periodSeconds: 5 

                resources:
                    requests:
                        cpu: "100m"
                        memory: "128Mi"
                    limits:
                        cpu: "200m"
                        memory: "256Mi"

# How to access inside the container
[root@control-plane-1 Apps]# kubectl exec -it hpcc-deployment-6c88c85f58-dck9p -n dev -- /bin/sh
# echo $ENVIRONMENT
dev
# echo $VERSION
1.28
```

### Application Level you can use like Below

```py
import os

app_name = os.getenv("APP_NAME")
environment = os.getenv("ENVIRONMENT")
log_level = os.getenv("LOG_LEVEL")

print(app_name)
print(environment)
print(log_level)
```


## configMapKeyRef

```yaml
containers:
  - name: hpcc-app
    image: nginx:latest

    env:
      - name: ENVIRONMENT
        valueFrom:
          configMapKeyRef:
            name: hpcc-config
            key: ENVIRONMENT

      - name: LOG_LEVEL
        valueFrom:
          configMapKeyRef:
            name: hpcc-config
            key: LOG_LEVEL
```

## ConfigMap as files

ConfigMaps aren't limited to simple environment variables. Suppose your application requires:

```
application.properties
```

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: hpcc-config
  namespace: dev
data:
  application.properties: |
    environment=dev
    log.level=INFO
    server.name=hpcc
```

```yaml
spec:
  containers:
    - name: hpcc-app
      image: nginx:latest

      volumeMounts:
        - name: hpcc-config-volume
          mountPath: /config

  volumes:
    - name: hpcc-config-volume
      configMap:
        name: hpcc-config
```

### Container level we can see that here 

```shell
kubectl exec -it <pod-name> -n dev -- \
  cat /config/application.properties
```

Note: If ConfigMap data was injected as an environment variable, an already-running container's environment does not dynamically change.Usually the Pod needs to be recreated/restarted for the environment-variable value to be picked up.

```shell
kubectl rollout restart deployment/hpcc-deployment -n dev
```



# Secrets

Kubernetes Secrets are API objects designed for sensitive information. Their data values are Base64 encoded, which is not encryption. In production, access should be restricted with RBAC, encryption at rest should be configured for Secret data in etcd, and organizations often integrate external secret-management systems such as a cloud secret manager or Vault


## stringData vs data

With stringData, you write normal text:

### stringData:

```
  DB_USERNAME: "hpccadmin"
  DB_PASSWORD: "MySecret123"
```
Kubernetes handles the encoding.

### With data

you provide Base64-encoded values yourself:
```
data:
  DB_USERNAME: aHBjY2FkbWlu
  DB_PASSWORD: TXlTZWNyZXQxMjM=
```

We can generate them like below
```
echo -n 'hpccadmin' | base64
echo -n 'MySecret123' | base64
```

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: hpcc-secret
  namespace: dev

type: Opaque

stringData:
  DB_USERNAME: "hpccadmin"
  DB_PASSWORD: "MySecret123"

# Accessing in the deployment as a Key
containers:
  - name: hpcc-app
    image: nginx:latest

    ports:
      - containerPort: 80

    env:
      - name: DB_USERNAME
        valueFrom:
          secretKeyRef:
            name: hpcc-secret
            key: DB_USERNAME

      - name: DB_PASSWORD
        valueFrom:
          secretKeyRef:
            name: hpcc-secret
            key: DB_PASSWORD

# Acceeing all the values at a time
envFrom:
  - secretRef:
      name: hpcc-secret

# as a Mount
volumeMounts:
  - name: hpcc-secret-volume
    mountPath: /etc/hpcc/secrets
    readOnly: true

volumes:
  - name: hpcc-secret-volume
    secret:
      secretName: hpcc-secret
```