# Argo CD

## installation via Rancher - Apps

2024.03.09 - v. 6.2.3

check for old installations (old CRDs) and remove them:

```
kubectl api-resources  | grep -i argo
```



see rancher-values.yaml for Ingress etc.


init. admin password:

```
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```


For more details see:

https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#ingress-configurationh



##  private repo


- ArgoCD w. private repositories - OK.
- Create a new git repo (private)
- Create a key, add pub (no write access) to the new repo
- Add a new repo in Argo-CD (enter priv. key there)
- Create a new application in Argo-CD




