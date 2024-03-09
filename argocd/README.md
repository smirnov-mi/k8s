# Argo CD

## installation via RAncher - Apps

2024.03.09 - v. 6.2.3


see rancher-values.yaml for Ingress etc.


init. admin password:

```
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```



