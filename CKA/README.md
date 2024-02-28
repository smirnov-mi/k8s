# A summary of the most relevant CKA subjects

I recently prepared myself for a CKA certification. 
I used a lot of different sources, a lot of great youtube videos, 
some online collections and official training env. by killer.sh


This is the summary of the **must have** topics for the CKA exam. 
Practice these a lot and think of similar scenarios. 
Be prepared for tricky questions like "start a pod with ReadWriteOnce access to the volume", 
"ingress the service xyz, the ingress should also be exposed on nodes" 
or "upgrade the node and ensure you drain it before that".


The rules might change as the time goes by, 
e.g. you are not allowed to use any assistance (person) or documentation other than this from kubernetes.io, 
you are allowed to take a 15 min break.


Practice on [Killercoda](https://killercoda.com/killer-shell-cka) environment.

Try to memorize as much as you can, as the exam adds stress and adrenaline, 
the environment is not fast, copy-paste is not perfect, 
you would be glad you KNOW how to do stuff instead of searching through the documentation.


28.02.2024
 


## 1 - Cluster (or one Node) upgrade to a specific version

Upgrading a controlplane, worker node or the whole cluster to a **specific** k8s version.


Use documentation: [k8s upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

### Upgrading first controlnode

```
apt update
apt-cache madison kubeadm
```

Drain the node

update kubeadm
```
apt-get install -y kubeadm='1.29.x-*'
```

FOLLOW THE INSTRUCTIONS!

First controlplane:

```
kubeadm upgrade plan

kubeadm upgrade apply v1.29.2
```
This might take a few minutes, follow the instructions then, e.g.

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.

### Upgrade other control nodes

...


### Upgrade worker nodes

see [official howto docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes)


Upgrade kubeadm

Call "kubeadm upgrade"

Drain the node

Upgrade kubelet and kubectl

Uncordon the node







## 2 - ETCD backup and restore

See docs: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

**get facts**

**create a snapshot**
```
ETCDCTL_API=3 etcdctl --cert=/etc/kubernetes/pki/etcd/server.crt \ 
  --key=/etc/kubernetes/pki/etcd/server.key --cacert=/etc/kubernetes/pki/etcd/ca.crt snapshot save snapshot.db
```

**restore a snapshot into new folder**

**stop all static pods**

**edit etcd.yaml to look up the new path**

**move all yamls back**






## 3 - Join Node to the cluster

Add a new node to a cluster. You can use the Killercoda CKA playground and delete a node01 first:
```
k drain node01 --ignore-daemonsets
k delete node node01
```

Solution:

first create a join token on a controlplane
```
kubeadm token create --print-join-comman
```

Then execute the printed command on a new node (additional actions listed below might be required):
```
# rm /etc/kubernetes/kubelet.conf /etc/kubernetes/pki/ca.crt

kubeadm join 172.30.1.2:6443 --token d5115h.d4uap9x5z0pdncf4 --discovery-token-ca-cert-hash sha256:6e41de7a00c20668116b3808d6b411e022e07e6cb6de0130067ac1a8c321d34a #--ignore-preflight-errors=Port-10250
```


## 4 - Troubleshoot (kubelet)

service not running, mostly because the conf. is wrong and/or kubelet binary is misplaced

I only had to "systemctl restart kubelet".




## 5 - Reschedule pods to another node

```
kubectl cordon node01
kubectl drain node01 --ignore-daemonsets 
```


## 6 - PV, PVC, Deployment

## 6.1 

Create a PV (hostPath), a PVC, a depl / pod to mount it

## 6.2 

Create a PVC of an existing StorageClass



## 7 - Pod exposure through Node Port



## 8 - DaemonSet (on all nodes incl. controlplane)

### 8.1 DaemonSet

Use Namespace project-tiger for the following.
Create a DaemonSet named ds-important with image httpd:2.4-alpine
 and labels id=ds-important and uuid=18426a0b-5f59-4e10-923f-c0e078e82462. 
The Pods it creates should request 10 millicore cpu and 10 mebibyte memory. 
The Pods of that DaemonSet should run on all nodes, also controlplanes.

### 8.2 Deployment on all nodes

Use Namespace project-tiger for the following. 
Create a Deployment named deploy-important with label id=very-important 
(the Pods should also have this label) and 3 replicas. 
It should contain two containers, the first named container1 with image nginx:1.17.6-alpine 
and the second one named container2 with image google/pause.


There should be only ever one Pod of that Deployment running on one worker node. We have two worker nodes: cluster1-node1 and cluster1-node2. Because the Deployment has three replicas the result should be that on both nodes one Pod is running. The third Pod won't be scheduled, unless a new worker node will be added.


In a way we kind of simulate the behaviour of a DaemonSet here, but using a Deployment and a fixed number of replicas.

See: https://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/




## 9 - Network Policy

### 9.1 scenario

Allow container c1 only access c2 on port 2222 and c3 on port 3333

### 9.2 scenario

For namespace ns2, allow pods "service" in namespace ns1 only access pods "db" in namespace ns2

### 9.3 scenario

For namespace ns1, allow only connection towards "db" pods in the namespace ns2 to port 1234




## 10 - Role, RoleBinding, ServiceAccount

Create a new ServiceAccount (or user) processor in Namespace project-hamster.
Create a Role and RoleBinding, both named processor as well.
These should allow the new SA to only create Secrets and ConfigMaps in that Namespace.


Verify with:
```
kubectl auth can-i create secret -n project-hamster --as system:serviceaccount:project-hamster:processor
```

---


## 11 - .kube/config contexts

Show current context with usage of kubectl and without;
show all contexts

```
kubectl config get-contexts -o=name

kubectl config use-context my-dev-cluster
```


## 12 - Schedule a port on a controlplane




## 13 - Ingress two services

### with domain.name
expose two services on domain.name/one and domain.name/two


### without

Eexpose a service svc1 on the path /path.
Verify from the internal IP using curl -kL ip:port/path 



## 14 - Run a pod with image xyz and secrets/configmaps mounted or used as a env

create one (or two) secrets, create a pod, edit it's yaml




## 15 - Review / Verify Certificates, Valid dates etc.

```
kubeadm certs check-expiration

openssl x509 -noout -text -in /etc/kubernetes/pki/apiserver.crt |grep -A2 Valid
        Validity
            Not Before: Feb  4 07:49:33 2024 GMT
            Not After : Feb  3 07:54:33 2025 GMT

openssl x509 -noout -text -in /var/lib/kubelet/pki/kubelet.crt |grep -A2 Valid
        Validity
            Not Before: Feb  4 06:54:35 2024 GMT
            Not After : Feb  3 06:54:35 2025 GMT
```



## 16 - One pod with 3 containers, same storage (not PV)



## 17 - add a sidecar container

Add a sidecar container to the existing pod. It should read and output the logs from the original container. 
Add a non-persistent volume for the log folder and use it in both containers.




## 18 -  Pod with ReadinessProbe / LivenessProbe

see docs: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/



## 19 - HPA horizontal pod autoscale

create an HPA for deployment XYZ 

```
kubectl autoscale deployment xyz --min=1 --max=5 --cpu-percent=80

```

Note: in real life the pods must have the cpu request / limit set, so the hpa can work.



## 20 - cluster events / sorting output


```
k get po -A  --sort-by=.metadata.creationTimestamp
k get po -A  --sort-by=.metadata.uid

k get events -A --sort-by=.metadata.creationTimestamp
```



## 21 - metrics

```
k top po --containers -A

k top no
```



## 22 - k8s components overview

What is running as pod, as service, static-pod ?

What CNI driver is installed and where it's config?



## 23 - Manual scheduling


stop scheduler:
```
mv /etc/kubernetes/manifests/kube-scheduler /root/
```

run pod, it won't be scheduled, schedule it manually (add nodeName: to spec) 

start scheduler:
```
mv /root/kube-scheduler.yaml /etc/kubernetes/manifests/
```



## 24 - scaling up / down a deployment

Straight-forward:

```
k scale deployment depl1 --replicas=3
```




