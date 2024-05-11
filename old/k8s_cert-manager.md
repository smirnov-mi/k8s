# HOWTO   k8s  cert-manager   +  nginx-ingress + phpLDAPadmin as test

2019.09.02


## PRE-requisites:    nginx-ingress

**set  YOUR IP !**
```
root@max1-master-01:~/tmp1/helm-charts# helm install stable/nginx-ingress --name ingress --namespace ingress --set rbac.create=true --set controller.kind=DaemonSet --set controller.service.type=ClusterIP --set controller.service.externalIPs='{116.202.0.65}' --set controller.stats.enabled=true --set controller.metrics.enabled=true --tls
```




## CERT-MANAGER
Read: https://docs.cert-manager.io/en/latest/getting-started/install/kubernetes.html


### OLD INSTALLATION:
```
root@max1-master-01:~/tmp1/helm-charts/stable# 

helm install --name cert-manager --namespace ingress --set ingressShim.defaultIssuerName=letsencrypt-prod --set ingressShim.defaultIssuerKind=ClusterIssuer --set createCustomResource=true stable/cert-manager --tls
```


### 1st way - no HELM (PROVED WORKING):

```
root@max1-master-01:~# 
kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v0.9.1/cert-manager.yaml
kubectl apply -f https://raw.githubusercontent.com/jetstack/cert-manager/release-0.9/deploy/manifests/00-crds.yaml
```

**Check Logs and new pods:**

```
root@max1-master-01:~# kuget po |grep cert
cert-manager   cert-manager-86f74d9b9f-9tlpt                           1/1     Running   1          17h
cert-manager   cert-manager-cainjector-59d69b9b-dqtvb                  1/1     Running   1          17h
cert-manager   cert-manager-webhook-cfd6587ff-vqpmf                    1/1     Running   0          17h
root@max1-master-01:~# kubectl -n cert-manager logs -f $(kubectl -n cert-manager get pod -l "app=cert-manager" -o jsonpath='{.items[0].metadata.name}')
```



### 2nd way - with HELM (not verified yet):

https://cert-manager.readthedocs.io/en/latest/tasks/issuing-certificates/ingress-shim.html

could try the 
```
--set ingressShim.defaultIssuerName=letsencrypt-prod \
--set ingressShim.defaultIssuerKind=ClusterIssuer
```

**Create Namespace and install cert-manager**
```
kubectl create namespace ingress
kubectl label namespace ingress certmanager.k8s.io/disable-validation=true

helm repo add jetstack https://charts.jetstack.io
helm repo update
kubectl delete clusterrole "cert-manager-cainjector" "cert-manager-webhook:webhook-requester"

helm install  --name cert-manager   --namespace ingress   --version v0.9.1   jetstack/cert-manager --tls
```


**Check Pods and Logs of the new pod:**
```
root@max1-master-01:~# kuget po |grep cert

kubectl -n ingress logs -f $(kubectl -n ingress get pod -l "app=cert-manager" -o jsonpath='{.items[0].metadata.name}')
```



**Verify:**

```
root@max1-master-01:~# kuget Issuer
NAMESPACE   NAME                            AGE
ingress     cert-manager-webhook-ca         24m
ingress     cert-manager-webhook-selfsign   24m
```

**Create OUR issuer (ClusterIssuer - for all namespaces)**
```
root@max1-master-01:~# cat cert-manager-issuer.yaml
apiVersion: certmanager.k8s.io/v1alpha1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
  namespace: ingress
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: your-email@maxxxx.de
    privateKeySecretRef:
      name: letsencrypt-prod
    http01: {}


root@max1-master-01:~# kubectl apply -f cert-manager-issuer.yaml
clusterissuer.certmanager.k8s.io/letsencrypt-prod created
```


**Install phpldapadmin (with ingress , incl. certificate)**


    certmanager.k8s.io/cluster-issuer: **letsencrypt-prod**

must be set to your Issuer's name. 


```
root@max1-master-01:~# cat tmp6/phpLDAPadmin-helm-chart/templates/ingress.yaml
{{- if .Values.ingress.enabled }}
{{- range .Values.ingress.hosts }}
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: {{ template "phpldapadmin.fullname" $ }}
  labels:
    app: {{ template "phpldapadmin.name" $ }}
    chart: {{ template "phpldapadmin.chart" $ }}
    release: {{ $.Release.Name | quote }}
    heritage: {{ $.Release.Service | quote }}
  annotations:
    certmanager.k8s.io/cluster-issuer: letsencrypt-prod
    nginx.ingress.kubernetes.io/proxy-buffering: "on"
    nginx.ingress.kubernetes.io/proxy-buffers-number: "16"
    nginx.ingress.kubernetes.io/proxy-buffer-size: "128k"
    nginx.ingress.kubernetes.io/proxy-read-timeout: "864000"
    nginx.ingress.kubernetes.io/proxy-connect-timeout: "864000"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "864000"
    #proxy_buffer_size 128k;
    #proxy_read_timeout 864000;
    #proxy_buffers 16 64k;
    #proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    #proxy_set_header X-Forwarded-Proto https;
    #proxy_set_header X-Real-IP $remote_addr;
    {{- if .tls }}
    ingress.kubernetes.io/secure-backends: "true"
    {{- end }}
    {{- if .certManager }}
    kubernetes.io/tls-acme: "true"
    {{- end }}
    {{- range $key, $value := .annotations }}
    {{ $key }}: {{ $value | quote }}
    {{- end }}
    #required if other path is used:
    nginx.ingress.kubernetes.io/rewrite-target:  /
spec:
  rules:
  - host: {{ .name }}
    http:
      paths:
        #- path: {{ default "/" .path }}
        - path: /ldap/
        #- path: /
          backend:
            #serviceName: {{ template "phpldapadmin.fullname" $ }}
            serviceName: {{ "phpldapadmin" }}
            servicePort: 80
{{- if .tls }}
  tls:
  - hosts:
    - {{ .name }}
    secretName: {{ .tlsSecret }}
{{- end }}
---
{{- end }}
{{- end }}

```


```
root@max1-master-01:~/tmp6# helm install --name phpldapadmin --tls   --set LDAP.host=ldap://openldap-service.default.svc.cluster.local:389 --namespace ldap phpLDAPadmin-helm-chart/
```


**Verify:**

```
root@max1-master-01:~/tmp6# kubectl -n ingress logs -f $(kubectl -n ingress get pod -l "app=cert-manager" -o jsonpath='{.items[0].metadata.name}')

root@max1-master-01:~# kubectl describe -n ldap ingress
```

```
https://demo-cluster2.maxxxx.de/ldap/
```


**If you see no errors and the page is https:  then we are good!**


**Check the Image version:**

```
root@max1-master-01:~# 
kubectl -n cert-manager describe po $(kubectl -n cert-manager get pod -l "app=cert-manager" -o jsonpath='{.items[0].metadata.name}')|grep "Image:"

    Image:         quay.io/jetstack/cert-manager-controller:v0.9.1
```


##Troubleshooting

**TEST2 - create a test cert.:**

**Create a ClusterIssuer to test the webhook works okay**
```
cat <<EOF > test-resources.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: cert-manager-test
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Issuer
metadata:
  name: test-selfsigned
  namespace: cert-manager-test
spec:
  selfSigned: {}
---
apiVersion: certmanager.k8s.io/v1alpha1
kind: Certificate
metadata:
  name: selfsigned-cert
  namespace: cert-manager-test
spec:
  commonName: demo-cluster2.maxxxx.de
  secretName: selfsigned-cert-tls
  issuerRef:
    name: test-selfsigned
EOF
```

**Create the test resources**
```
kubectl apply -f test-resources.yaml
```

```
# Check the status of the newly created certificate
# You may need to wait a few seconds before cert-manager processes the
# certificate request
```
```
root@max1-master-01:~# kubectl describe certificate -n cert-manager-test selfsigned-cert
Name:         selfsigned-cert
Namespace:    cert-manager-test
Labels:       <none>
Annotations:  <none>
API Version:  certmanager.k8s.io/v1alpha1
Kind:         Certificate
Metadata:
  Creation Timestamp:  2019-08-30T15:01:53Z
  Generation:          3
  Resource Version:    9727596
  Self Link:           /apis/certmanager.k8s.io/v1alpha1/namespaces/cert-manager-test/certificates/selfsigned-cert
  UID:                 1a7bfd13-cb37-11e9-8abf-9600002a139a
Spec:
  Common Name:  demo-cluster2.maxxxx.de
  Issuer Ref:
    Name:       test-selfsigned
  Secret Name:  selfsigned-cert-tls
Status:
  Conditions:
    Last Transition Time:  2019-08-30T15:01:54Z
    Message:               Certificate is up to date and has not expired
    Reason:                Ready
    Status:                True
    Type:                  Ready
  Not After:               2019-11-28T15:01:54Z
Events:
  Type     Reason          Age   From          Message
  ----     ------          ----  ----          -------
  Warning  IssuerNotReady  48s   cert-manager  Issuer test-selfsigned not ready
  Normal   CertIssued      48s   cert-manager  Certificate issued successfully
```

**Clean up the test resources**
```
kubectl delete -f test-resources.yaml
```
========


