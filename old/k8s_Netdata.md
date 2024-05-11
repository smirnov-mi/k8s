# 2019 07 12    Netdata monitoring

## General info


https://github.com/netdata/helmchart


## Go

```
root@max2-master-01:~# cd tmp5
root@max2-master-01:~/tmp5# git clone https://github.com/netdata/helmchart.git netdata
```


## PREREQ (nice to have)
nginx-ingress + cert.


## Limitations

There is NO authentication in Netdata. Use e.g. nginx passwords.
Read more:
https://docs.netdata.cloud/docs/netdata-security/


## Storage: local or storageclass

### DATA STORAGE on local disk

```
root@max2-master-01:~# cat netdata_storage_x2.yaml
# Create local data volumes for Netdata
apiVersion: v1
kind: PersistentVolume
metadata:
  name: alarms-netdata-master-0
#  namespace: netdata
  labels:
    name: alarms-netdata-master-0
    app: netdata
    role: master
    component: alarms
#    release: mon
spec:
  capacity:
    storage: 100Mi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/pv-netdata-alarms-0
  claimRef:
    name: alarms-netdata-master-0
    namespace: monitor
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: database-netdata-master-0
#  namespace: mysql
  labels:
    name: database-netdata-master-0
    app: netdata
    role: master
    component: database
#    release: mysqlha
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /data/pv-netdata-db-1
  claimRef:
    name: database-netdata-master-0
    namespace: monitor
```

```

msmirnov@apps:~$ for i in $M2W ; do ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $i mkdir /data/pv-netdata-alarms-0 /data/pv-netdata-db-1 ; done
msmirnov@apps:~$ for i in $M2W ; do ssh -q -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -l root $i chown 201:201 /data/pv-netdata* ; done

root@max2-master-01:~# kubectl create -f netdata_storage_x2.yaml
```



### DATA Storage on a StorageClass

here - openEBS



```
root@max1-master-01:~# kuget storageclass
NAME                        PROVISIONER                                                AGE
openebs-cstor-sparse        openebs.io/provisioner-iscsi                               5d16h
openebs-jiva-default        openebs.io/provisioner-iscsi                               5d16h
openebs-snapshot-promoter   volumesnapshot.external-storage.k8s.io/snapshot-promoter   5d16h
```

cat netdata/templates/pvc.yaml
```
{{- if and .Values.persistence.enabled (not .Values.persistence.existingClaim) }}
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: database-netdata-master-0
  labels:
    app: {{ template "netdata.name" . }}
    chart: {{ template "netdata.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
{{- if .Values.extraLabels }}
{{ toYaml .Values.extraLabels | indent 4 }}
{{- end }}
spec:
  accessModes:
    - {{ .Values.persistence.accessMode | quote }}
  resources:
    requests:
      storage: {{ .Values.persistence.datasize| quote }}
  storageClassName: "{{ .Values.persistence.storageClass }}"
---
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: alarms-netdata-master-0
  labels:
    app: {{ template "netdata.name" . }}
    chart: {{ template "netdata.chart" . }}
    release: {{ .Release.Name }}
    heritage: {{ .Release.Service }}
{{- if .Values.extraLabels }}
{{ toYaml .Values.extraLabels | indent 4 }}
{{- end }}
spec:
  accessModes:
    - {{ .Values.persistence.accessMode | quote }}
  resources:
    requests:
      storage: {{ .Values.persistence.alarmsize | quote }}
{{- if .Values.persistence.storageClass }}
{{- if (eq "-" .Values.persistence.storageClass) }}
  storageClassName: ""
{{- else }}
  storageClassName: "{{ .Values.persistence.storageClass }}"
{{- end }}
{{- end }}
{{- end }}
```


AND add to values.yaml:


```
## Persist data to a persistent volume
persistence:
  enabled: true
  ## database data Persistent Volume Storage Class
  ## If defined, storageClassName: <storageClass>
  ## If set to "-", storageClassName: "", which disables dynamic provisioning
  ## If undefined (the default) or set to null, no storageClassName spec is
  ##   set, choosing the default provisioner.  (gp2 on AWS, standard on
  ##   GKE, AWS & OpenStack)
  ##
  storageClass: "openebs-cstor-sparse"
  accessMode: ReadWriteOnce
  datasize: 2G
  alarmsize: 100M
```




```

root@max2-master-01:~/tmp5# vi netdata/values.yaml

root@max2-master-01:~/tmp5# vi netdata/templates/ingress.yaml
```


add rewrite-target and         path: /mpn/

```

apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  annotations:
    kubernetes.io/ingress.class: nginx
    kubernetes.io/tls-acme: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /
  generation: 4
  labels:
    app: netdata
    chart: netdata-1.1.0
    heritage: Tiller
    release: netdata
  name: netdata
  namespace: monitor
  resourceVersion: "9554394"
  selfLink: /apis/extensions/v1beta1/namespaces/monitor/ingresses/netdata
  uid: a5cb5167-a499-11e9-983b-96000026d4c3
spec:
  rules:
  - host: demo-cluster.maxxxx.de
    http:
      paths:
      - backend:
          serviceName: netdata
          servicePort: http
        path: /mon/
```





```

root@max2-master-01:~/tmp5# helm install --name netdata --namespace monitor ./netdata --tls
root@max2-master-01:~/tmp5# kubectl logs -f -n monitor netdata-master-0
```



## See Result

```
root@max1-master-01:~# kuget po  |grep monit
monitor        netdata-master-0          1/1     Running   0          12h
monitor        netdata-slave-4hl7p       1/1     Running   0          12h
monitor        netdata-slave-5tlnp       1/1     Running   0          12h
monitor        netdata-slave-6v76v       1/1     Running   0          12h
monitor        netdata-slave-bwz8f       1/1     Running   0          12h
monitor        netdata-slave-ghjfb       1/1     Running   0          12h
monitor        netdata-slave-gw69b       1/1     Running   0          12h
monitor        netdata-slave-zvfkg       1/1     Running   0          12h
```

https://demo-cluster.maxxxx.de/mon/





