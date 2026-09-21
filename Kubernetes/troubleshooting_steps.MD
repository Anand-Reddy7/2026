## Example architecture:

```text
Client / Browser
       |
       | http://<Floating-IP>:30080
       v
Floating IP
       |
       v
Worker Node
10.244.0.10:30080
       |
       | NodePort
       v
Kubernetes Service
ClusterIP:80
       |
       | Service selector
       v
EndpointSlice
       |
       v
Pod IP:80
       |
       v
Application Container
nginx:80
```


## Steps

```shell
kubectl get deployment nginx-test
kubectl get pods -l app=nginx-test -o wide
kubectl describe deployment nginx-test
kubectl logs -l app=nginx-test
kubectl get svc nginx-test-service
kubectl describe svc nginx-test-service
kubectl get endpointslice -l kubernetes.io/service-name=nginx-test-service
kubectl get events --sort-by=.metadata.creationTimestamp

## For Cluster
kubectl get nodes -o wide
kubectl get pods -A -o wide
kubectl get svc -A
kubectl get endpointslice -A
```

