# Argo CD

Prereq. DNS name for web-interface

https://artifacthub.io/packages/helm/argo/argo-cd?modal=install

    helm repo add argo https://argoproj.github.io/argo-helm
    helm install my-argo-cd argo/argo-cd --version 7.1.2

upgrade:

    helm upgrade --history-max=5 --install=true --namespace=argo --timeout=10m0s --values=/home/shell/helm/values-argo-cd-7.1.3.yaml --version=7.1.3 --wait=true argo-cd /home/shell/helm/argo-cd-7.1.3.tgz



Optional: Cert-manager. Can be deployed as ArgoCD app later (**TODO**).

## Current state

**15.Sep.2024** - upd. 7.1.3 > 7.5.2 (2.12.3)

```bash
helm upgrade --history-max=5 --install=true --namespace=argo --timeout=10m0s --values=/home/shell/helm/values-argo-cd-7.5.2.yaml --version=7.5.2 --wait=true argocd /home/shell/helm/argo-cd-7.5.2.tgz
```


<details>

```txt
09.Jun.2024 - upd. 7.1.2 > 7.1.3 (2.11.3)
08.Jun.2024 - fresh install on a new cluster, 7.1.2 (2.11.3)
11.May.2024 - upd. 6.7.18 > 6.8.1 (2.11.0)
01.May.2024 - upd. 6.7.15 > 6.7.18
26.Apr.2024 - upd. to 6.7.15
02.Apr.2024 - install 6.2.3, update to 6.7.3
09.Mar.2024 - install 6.2.3
```
  <summary>
  previous
  </summary>
</details>
 
## installation via Rancher - Apps


check for old installations (old CRDs) and remove them:

```
kubectl api-resources  | grep -i argo
```


See [rancher-values.yaml](https://github.com/smirnov-mi/how-to/blob/main/argocd/rancher-values-small.yaml) for Ingress etc.




get the init. admin password:

```
kubectl -n default get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```


For more details see:

https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/#ingress-configurationh



##  private repo

[argocd/private-repo.md](https://github.com/smirnov-mi/k8s/blob/main/argocd/private-repo.md)


## see also

https://github.com/smirnov-mi/my-charts-pr/blob/main/README.md



