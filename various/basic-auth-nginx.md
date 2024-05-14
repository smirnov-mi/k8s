# Setup a basic nginx auth in Rancher

https://blog.jbrosi.ch/2019-3-nginx-ingress-rancher-basic-auth/



# Same setup incl. basic nginx authentication without Rancher


```
ingress:
  enabled: true
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/auth-realm: Authentication required
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-type: basic

  path: /mon(/|$)(.*)
  hosts:
    - demo-cluster2.maxxxx.com

...

storageclass: "rook-ceph-block"



root@max1-master-01:~/tmp-13-netdata# kubectl create ns monitor
namespace/monitor created
root@max1-master-01:~/tmp-13-netdata# helm install netdata --namespace monitor netdata/


root@max1-master-01:~/tmp-13-netdata# htpasswd -c auth maxxxx
New password:
Re-type new password:
Adding password for user maxxxx
root@max1-master-01:~/tmp-13-netdata# kubectl -n monitor create secret generic - basic-auth --from-file=auth
secret/basic-auth created
```


