# HOWTO   k8s  OpenEBS 

2019.09.04


OpenEBS makes persistent storage devices on k8s,

which allows containers be re-scheduled on every node (and still have their storage).

https://docs.openebs.io/v082/docs/next/prerequisites.html#ubuntu



## PRE-requisites:    

https://docs.openebs.io/v082/docs/next/prerequisites.html#ubuntu


Do on all workers:

```
apt install open-iscsi
systemctl enable iscsid && sudo systemctl start iscsid
```



## Go


https://github.com/openebs/charts

```
root@max1-master-01:~/tmp1# helm repo add openebs-charts https://openebs.github.io/charts/
"openebs-charts" has been added to your repositories

root@max1-master-01:~/tmp1# helm repo update
Hang tight while we grab the latest from your chart repositories...
...Skip local chart repository
...Successfully got an update from the "openebs-charts" chart repository
...Successfully got an update from the "jetstack" chart repository
...Successfully got an update from the "stable" chart repository
Update Complete.
```


```
root@max1-master-01:~/tmp1# cat ~/.helm/repository/cache/openebs-charts-index.yaml


root@max1-master-01:~/tmp1# helm install --namespace openebs --name openebs openebs-charts/openebs --tls


root@max1-master-01:~/tmp1# kuget storageclass
NAME                        PROVISIONER                                                AGE
openebs-cstor-sparse        openebs.io/provisioner-iscsi                               16s
openebs-jiva-default        openebs.io/provisioner-iscsi                               17s
openebs-snapshot-promoter   volumesnapshot.external-storage.k8s.io/snapshot-promoter   16s
```




## TEST 

https://github.com/openebs/charts/blob/master/docs/example-sts-openebs-localpv.yaml


Create pods with PVC / PVs


```
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: busybox-sts
  namespace: default
spec:
  replicas: 3
  serviceName: ""
  selector:
    matchLabels:
      openebs.io/app: busybox-sts
  template:
    metadata:
      labels:
        openebs.io/app: busybox-sts
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                openebs.io/app: busybox-sts
            topologyKey: kubernetes.io/hostname
      containers:
      - command:
        - sh
        - -c
        - 'date > /mnt/store1/date.txt; hostname >> /mnt/store1/hostname.txt; sync; sleep 5; sync; tail -f /dev/null;'
        image: busybox
        imagePullPolicy: IfNotPresent
        name: busybox-sts
        volumeMounts:
        - mountPath: /mnt/store1
          name: vol1
  volumeClaimTemplates:
  - metadata:
      name: vol1
    spec:
      accessModes:
      - ReadWriteOnce
      storageClassName: openebs-cstor-sparse
      resources:
        requests:
          storage: 40M
```


```
kubectl apply -f openebs-test-appl.yaml
```

```
root@max1-master-01:~# kuget po|grep busy
default        busybox-sts-0                                                     1/1     Running   0          8m20s
default        busybox-sts-1                                                     1/1     Running   0          7m9s
default        busybox-sts-2                                                     1/1     Running   0          6m

root@max1-master-01:~# kuget pvc
NAMESPACE   NAME                 STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS           AGE
default     vol1-busybox-sts-0   Bound    pvc-418d4904-ce66-11e9-8a41-9600002a139b   40M        RWO            openebs-cstor-sparse   8m27s
default     vol1-busybox-sts-1   Bound    pvc-6c35e518-ce66-11e9-8a41-9600002a139b   40M        RWO            openebs-cstor-sparse   7m16s
default     vol1-busybox-sts-2   Bound    pvc-951bbde6-ce66-11e9-8a41-9600002a139b   40M        RWO            openebs-cstor-sparse   6m7s
```


Delete a pod, it will be automatically restarted (maybe on some other node)


**Works!**


=======

## Managing openEBS ## (2 b continued)

https://www.credativ.de/blog/howtos/postgresql-auf-kubernetes-mit-hilfe-von-openebs/


```
root@max1-master-01:~# kubectl get disks
NAME                                      SIZE          STATUS   AGE
disk-694cf95d4025294fc3c3c0e60bdea8d0     10737418240   Active   19h
disk-704f37d8861bb96ddcfb435897e30f90     10737418240   Active   19h
disk-cc0644133f70f6c8fd45e01c214eb581     10737418240   Active   19h
sparse-703d2eeb377de7f67e4c0a7498ad6529   10737418240   Active   19h
sparse-b3e8b1ee3ee606adb658d08fc782d950   10737418240   Active   19h
sparse-d5068da9bab429706cba3739705b9c3e   10737418240   Active   19h
sparse-d786cd81de456b0c82588fc428974a3a   10737418240   Active   19h

root@max1-master-01:~# kubectl get storagePoolClaim
NAME                AGE
cstor-sparse-pool   19h
```

