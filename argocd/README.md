# Argo CD

Prereq. DNS name for web-interface

Optional: Cert-manager. Can be deployed as ArgoCD app later.

## Current state

**1.May.2024** - upd. 6.7.15 to 6.7.18

26.Apr.2024 - upd. to 6.7.15

1.Apr.2024 - 6.2.3 (with values saved), then update to 6.7.3

09.Mar.2024 - v. 6.2.3

 
## installation via Rancher - Apps


check for old installations (old CRDs) and remove them:

```
kubectl api-resources  | grep -i argo
```


See rancher-values.yaml for Ingress etc.




get the init. admin password:

```
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```


For more details see:

https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#ingress-configurationh



##  private repo


- ArgoCD w. private repositories - OK.
- Create a new git repo (private)
- Create a key, add pub (no write access) to the new repo
- Add a new repo in Argo-CD (in GUI, check both checkboxes, enter priv. key)
- Create a new application in Argo-CD


## see also

https://github.com/smirnov-mi/my-charts-pr/blob/main/README.md



