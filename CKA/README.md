# A summary of the most relevant CKA subjects

I recently mastered the CKA certification (Febr. 2024).
I used a lot of different sources for learning, a lot of great youtube videos, 
some online collections and official training env. by killer.sh


This is the summary of the **must have** topics for the CKA exam. 
Practice these a lot and think of similar scenarios. 
Be prepared for tricky questions like "start a pod with ReadWriteOnce access to the volume", 
"ingress the service xyz, the ingress should also be exposed on nodes" 
or "upgrade the node and ensure you drain it before that".


The rules might change as the time goes by, 
e.g. you are not allowed to use any assistance (person) or documentation other than this from kubernetes.io, 
you are allowed to take a 15 min break.


Practice on [Killercoda](https://killercoda.com/killer-shell-cka) environment (it's free).

Try to memorize as much as you can, as the exam adds stress and adrenaline, 
the environment is not fast, copy-paste is not perfect, 
you would be glad you KNOW how to do stuff instead of searching through the documentation.


**Absolutely MUST HAVE tasks** are ETCD BACKUP and CLUSTER PATCHING, these must be trained a lot.



## Objectives

27.02.2024
<details>

```

Storage (10%)
Understand storage classes, persistent volumes
Understand volume mode, access modes and reclaim policies for volumes
Understand persistent volume claims primitive
Know how to configure applications with persistent storage

Troubleshooting (30%)
Evaluate cluster and node logging
Understand how to monitor applications
Manage container stdout & stderr logs
Troubleshoot application failure
Troubleshoot cluster component failure
Troubleshoot networking

Workloads & Scheduling (15%)
Understand deployments and how to perform rolling update and rollbacks
Use ConfigMaps and Secrets to configure applications
Know how to scale applications
Understand the primitives used to create robust, self-healing, application deployments
Understand how resource limits can affect Pod scheduling
Awareness of manifest management and common templating tools

Cluster Architecture, Installation & Configuration (25%)
Manage role based access control (RBAC)
Use Kubeadm to install a basic cluster
Manage a highly-available Kubernetes cluster
Provision underlying infrastructure to deploy a Kubernetes cluster
Perform a version upgrade on a Kubernetes cluster using Kubeadm
Implement etcd backup and restore

Services & Networking (20%)
Understand host networking configuration on the cluster nodes
Understand connectivity between Pods
Understand ClusterIP, NodePort, LoadBalancer service types and endpoints
Know how to use Ingress controllers and Ingress resources
Know how to configure and use CoreDNS
Choose an appropriate container network interface plugin

```
  <summary>
  List of knowledge areas 
  </summary>
</details>


 


## 1 - Cluster (or one Node) upgrade to a specific k8s version

Upgrading a controlplane, worker node or the whole cluster to a **specific** k8s version.

<details>

Use documentation: [k8s upgrade](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/)

### Upgrading first controlnode

```
apt update
apt-cache madison kubeadm
```

Drain the node

update kubeadm to the version asked
```
apt-get install -y kubeadm='1.29.x-*'
```

FOLLOW THE INSTRUCTIONS!

First controlplane:

```
kubeadm upgrade plan

kubeadm upgrade apply v1.29.2 #just use over version if asked
```

This might take a few minutes, follow the instructions then, e.g.

[upgrade/kubelet] Now that your control plane is upgraded, please proceed with upgrading your kubelets if you haven't already done so.

### Upgrade other control nodes

Same but without the "kubeadm upgrade plan"

Then upgrade the worker nodes.

### Upgrade worker nodes

see [official howto docs](https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes)


Upgrade kubeadm

Call "kubeadm upgrade"

Drain the node

Upgrade kubelet and kubectl

Uncordon the node


  <summary>
  Solution
  </summary>
</details>




## 2 - ETCD backup and restore

Make a backup of etcd running on cluster3-controlplane1 and save it on the controlplane node at /tmp/etcd-backup.db.

Then create any kind of Pod in the cluster.

Finally restore the backup, confirm the cluster is still working and that the created Pod is no longer with us.

Use a killercoda env to practice this: [https://killercoda.com/playgrounds/scenario/cka](https://killercoda.com/playgrounds/scenario/cka)


<details>

See docs: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

**get facts** (cert, ca, key)
```
grep etcd /etc/kubernetes/manifests/kube-apiserver.yaml 
```

**create a snapshot**
```bash
ETCDCTL_API=3 etcdctl --cert=/etc/kubernetes/pki/etcd/server.crt \ 
  --key=/etc/kubernetes/pki/etcd/server.key --cacert=/etc/kubernetes/pki/etcd/ca.crt snapshot save snapshot.db
```

**optional: run a small pod**
```bash
k run my-test-pod --image=nginx:alpine
```

**restore a snapshot into new folder**
```bash
ETCDCTL_API=3 etcdctl --data-dir /var/lib/etcd-backup  snapshot restore snapshot.db \
--cacert /etc/kubernetes/pki/etcd/ca.crt \
--cert /etc/kubernetes/pki/etcd/server.crt \
--key /etc/kubernetes/pki/etcd/server.key
```

**stop all static pods**
```bash
mv /etc/kubernetes/manifests/*.yaml .
```

**wait a few moments, check with**
```bash
crictl ps
```

**edit etcd.yaml to look up the new path**


**move all yamls back**
```bash
mv ./*.yaml /etc/kubernetes/manifests/
```

**optional: verify the new pod is not here**
```bash
k get po my-test-pod
```



  <summary>
  Solution
  </summary>
</details>




## 3 - Join Node to the cluster

Add a new node to a cluster. 

You can use the Killercoda CKA playground and delete a node01 first:
```
k drain node01 --ignore-daemonsets
k delete node node01
```

<details>

first create a join token on a controlplane
```
kubeadm token create --print-join-comman
```

Then execute the printed command on a new node (additional actions listed below might be required):
```
# rm /etc/kubernetes/kubelet.conf /etc/kubernetes/pki/ca.crt

kubeadm join 172.30.1.2:6443 --token d5115h.d4uap9x5z0pdncf4 --discovery-token-ca-cert-hash sha256:6e41de7a00c20668116b3808d6b411e022e07e6cb6de0130067ac1a8c321d34a #--ignore-preflight-errors=Port-10250
```
  <summary>
  Solution
  </summary>
</details>



## 4 - Troubleshoot (kubelet)

service not running, mostly because the conf. is wrong and/or kubelet binary is misplaced

I only had to "systemctl restart kubelet".

Other scenarios can involve misspelled paths in kubelet.conf and moved or renamed  binary



## 5 - Reschedule pods to another node


<details>

it's cordon and drain the node. 

```
kubectl cordon node01
kubectl drain node01 --ignore-daemonsets 
```
  <summary>
  Solution
  </summary>
</details>

## 6 - PV, PVC, Deployment

## 6.1 

Create a PV (hostPath), a PVC, a depl / pod to mount it

## 6.2 

Create a PVC of an existing StorageClass



## 7 - Pod exposure through Node Port

kubectl expose pod1 --port=80 --type=NodePort


then edit the service, if a spec. nodeport is required.



## 8 - DaemonSet (on all nodes incl. controlplane)

### 8.1 DaemonSet

Use Namespace ns8 for the following.
Create a DaemonSet named ds-important with image httpd:2.4-alpine
 and labels id=ds-important and uuid=0b-59-41-93-c008.
The Pods it creates should request 15 millicore cpu and 15 mebibyte memory. 
The Pods of that DaemonSet should run on all nodes, also controlplanes.

### 8.2 Deployment on all nodes

Use Namespace ns8 for the following. 
Create a Deployment named depl-imp with label id=very-imp 
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

### see also

https://kubernetes.io/docs/concepts/services-networking/network-policies/



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

<details>

```
kubectl config get-contexts -o=name

grep ontext ~/.kube/config ....

kubectl config use-context my-dev-cluster
```

  <summary>
  Solution 
  </summary>
</details>


## 12 - Schedule a pod on a controlplane

### 12.1 nodeName

If the nodes have no taints:

<details>

```
spec:
  nodeName: controlplane
```
  <summary>
  Add foll. to pod.yaml 
  </summary>
</details>


### 12.2 add tolerations

Describe the control node, look for taints, then add tolerations to the pod/depl spec

<details>

```
# show nodes with taints (incl their taints)
kubectl get nodes -o jsonpath='{.items[*].spec.taints}'

#or 
kubectl get no
kubectl describe no CONTROLPLANE -o yaml |grep -A5 Taints
```

```
spec:
  tolerations:
  - key: node-role.kubernetes.io/controlplane
    operator: Exists
    effect: NoSchedule
  - key: node-role.kubernetes.io/etcd
    operator: Exists
    effect: NoExecute
```
  <summary>
  Solution 
  </summary>
</details>


## 13 - Ingress two services

### with domain.name
expose two services on: domain.name/one and domain.name/two


### without

Expose a service svc1 on the path /path.
Verify from the internal IP using curl -kL ip:port/path 



## 14 - Run a pod with image xyz and secrets/configmaps mounted or used as a env

Use documentation, create one (or two) secrets, create a pod, edit it's yaml




## 15 - Review / Verify Certificates, Valid dates etc.

<details>

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
  <summary>
  Solution 
  </summary>
</details>


## 16 - One pod with 3 containers, same storage (not PV)

Search for emptyDir type of storage.

Also they might ask to encapsulate an env variable into a pod, smth like MY_NODE_NAME


## 17 - add a sidecar container

Add a sidecar container to the existing pod. It should read and output the logs from the original container. 
Add a non-persistent volume for the log folder and use it in both containers.




## 18 -  Pod with ReadinessProbe / LivenessProbe

see docs: https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/



## 19 - HPA horizontal pod autoscale

create an HPA for deployment XYZ 

<details>

```
kubectl autoscale deployment xyz --min=1 --max=5 --cpu-percent=80

```
  <summary>
  Solution 
  </summary>
</details>

Note: in real life the pods must have the cpu request / limit set, so the hpa can work.



## 20 - cluster events / sorting output

Display events or pods sorted by creation time.

<details>

```
k get po -A  --sort-by=.metadata.creationTimestamp
k get po -A  --sort-by=.metadata.uid

k get events -A --sort-by=.metadata.creationTimestamp
```
  <summary>
  Solution 
  </summary>
</details>


## 21 - metrics / resource usage

Display usage by nodes; by pods AND it's containers


<details>

```
k top no

k top po --containers -A
```
  <summary>
  Solution 
  </summary>
</details>


## 22 - k8s components overview / informationw

Which components run as pod, as service, static-pod ?

What CNI driver is installed and where it's config?



## 23 - Manual scheduling

Requires a non RKE cluster for training. Use e.g. killercoda

<details>

Kill / stop scheduler:

```
mv /etc/kubernetes/manifests/kube-scheduler /root/
```

run pod, it won't be scheduled, schedule it manually (add nodeName: to spec) 

start scheduler:
```
mv /root/kube-scheduler.yaml /etc/kubernetes/manifests/
```
  <summary>
  Solution 
  </summary>
</details>


## 24 - Changing an existing deployment

### 24.1 scale-up / -down a deployment / replicaset

<details>

Straight-forward:

```
k scale deployment depl1 --replicas=3
```
  <summary>
  Solution 
  </summary>
</details>

### 24.2 change the image of the existing deployment/rs

<details>

```
# find the names/images:
k get -n ns deploy depl1 -o yaml |egrep -i "name|image"

# set a new image:
k set -n ns image deployment depl-name container-name=newimage

```
  <summary>
  Solution 
  </summary>
</details>

## 25 - Pods with PriorityClass

priorityClass, priority pods, usage 



## 26 - Init Container

Adding an init container to an existing pod.



## 27 - Cronjobs
