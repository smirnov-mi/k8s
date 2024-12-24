# Local volumes

Volumes from local nodes' storage.

Based on : https://lapee79.github.io/en/article/use-a-local-disk-by-local-volume-static-provisioner-in-kubernetes/

Reproduced on 24.12.2024, v1.30.7+rke2r1


## Intro

In the Kubernetes system, local disks can be used through **HostPath**, **LocalVolume**.

**HostPath**: The volume itself does not contain scheduling information. If you want to fix each pod on a node, you need to configure scheduling information, such as nodeSelector, for the pod.

**LocalVolume**: The volume itself contains scheduling information, and the pods using this volume will be fixed on a specific node, which can ensure data continuity.


**Local Persistent Volumes** allow you to access local disk by using the standard PVC object.


## Create StorageClass with WaitForFirstConsumer Binding Mode

 This mode instructs Kubernetes to wait to bind a PVC until a Pod using it is scheduled.

### Creating a StorageClass

```bash
cat << EOF | kubectl apply -f -
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
EOF


$ k create -f local-storage-1-storageclass.yaml
storageclass.storage.k8s.io/local-storage created

$ k get storageclass
NAME            PROVISIONER                    RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-storage   kubernetes.io/no-provisioner   Delete          WaitForFirstConsumer   false                  4s

```


### Create Local PersistentVolume

Create PersistentVolume with a reference to local-storage StorageClass.
Note the **path**, it **must be created manually on the node**, add chmod 700 on it.

Requires a **nodename** label of the corresponding node, get it with:

```bash
k get no --show-labels
```


```bash
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: test-local-pv
spec:
  capacity:
    storage: 1Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: local-storage
  local:
    path: /data/volumes/pv1
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - k8s-worker-01
EOF
```

Test with :

```
kubectl get pv
```



### Create a PersistentVolumeClaim

Create PersistentVolumeClaim with a reference to local-storage StorageClass

```bash
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: test-pvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-storage
  resources:
    requests:
      storage: 1Gi
```


### Create a POD with local persistent volume

```bash

apiVersion: v1
kind: Pod
metadata:
  name: test-local-vol
  labels:
    name: test-local-vol
spec:
  containers:
  - name: app
    image: busybox
    command: ['sh', '-c', 'echo "The local volume is mounted!" > /mnt/test.txt && sleep 3600']
    volumeMounts:
      - name: local-persistent-storage
        mountPath: /mnt
  volumes:
    - name: local-persistent-storage
      persistentVolumeClaim:
        claimName: test-pvc

```


