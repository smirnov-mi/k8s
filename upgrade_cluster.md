# How to upgrade Kubernetes "baremetal" cluster.

**Note, it's only possible to upgrade max. to the next major version at a time**

e.g. 1.13.7 -> 1.14.3 or 1.16.0 -> 1.16.2

All pods will be restarted.


The upgrade workflow at high level is the following:

- Upgrade a first control plane node.
- Upgrade additional control plane nodes.
- Upgrade worker nodes.


**See official documentation.**

**Upgrading controlplanes**:
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/

**If it's only about worker nodes**, follow the
https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/upgrading-linux-nodes/


taking an etcd snapshot might be a good idea, see [etcd_backups.md](etcd_backups.md)



## k8s upgrade

24.02.2024    1.29.0-1.1 -> 1.29.2-1.1


https://github.com/kubernetes/kubernetes/blob/master/CHANGELOG/CHANGELOG-1.18.md#known-issues

https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/kubeadm-upgrade/




## 0) drain node, upgrade the OS + packages

```
apt-mark hold kubeadm kubectl kubelet
apt update
apt upgrade -y
reboot
```




## 1) Master1 (first control plane node):


### prepare packages, DRAIN the master1 node, upgrade packages, upgrade plan, apply plan



# 24.02.2024    1.29.0-1.1 -> 1.29.2-1.1


```

    4  apt update
    5  k drain controlplane
    6  k drain controlplane --ignore-daemonsets
    7  apt-cache madison kubeadm
    8  apt install kubeadm=1.29.2-1.1
    9  kubeadm --version
   10  kubeadm version
   11  kubeadm upgrade plan
   12  kubeadm upgrade apply v1.29.2
   13  apt install kubelet=1.29.2-1.1 kubectl=1.29.2-1.1
   14  systemctl restart kubelet
   15  systemctl status  kubelet
   16  k uncordon controlplane
   17  k get no
   20  k drain node01 --ignore-daemonsets --delete-emptydir-data
   21  ssh node01


    3  apt update
    4  apt install kubeadm=1.29.2-1.1
    5  kubeadm upgrade node
    6  apt install kubelet=1.29.2-1.1 kubectl=1.29.2-1.1
    7  systemctl daemon-reload
    8  systemctl restart kubelet
    9  exit


   22  k uncordon node01
   23  k get no
   26  k get events --sort-by=.metadata.creationTimestamp







root@max2-master-01:~# kubelet --version
Kubernetes v1.17.2
root@max2-master-01:~# apt-cache madison kubeadm
   kubeadm |  1.18.2-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.18.1-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages
   kubeadm |  1.18.0-00 | http://apt.kubernetes.io kubernetes-xenial/main amd64 Packages


KNVER=1.18.2

apt-get update && apt-get install kubeadm=${KNVER}-00
apt-mark hold kubeadm
kubeadm version

kubectl drain max2-master-01  --ignore-daemonsets

kubeadm upgrade plan
kubeadm upgrade apply v1.18.2
```


Manually update CNI plugins, e.g. coredns https://coredns.io/ (skipping for now)

 https://github.com/coredns/deployment/blob/master/kubernetes/Upgrading_CoreDNS.md

 https://kubernetes.io/docs/concepts/cluster-administration/addons/

```

apt-get install kubelet=${KNVER}-00 kubectl=${KNVER}-00
apt-mark hold kubelet kubectl kubeadm && systemctl restart kubelet && unset KNVER

kubectl uncordon master1
```



## 2) on other master nodes:


```
root@max2-master-02:~# KNVER=1.18.2
root@max2-master-02:~# apt-get update && apt-get install kubeadm=${KNVER}-00
root@max2-master-02:~# apt-mark hold kubeadm
root@max2-master-02:~# kubeadm version
```

```

kubectl drain max2-master-0  --ignore-daemonsets
```

```
 root@max2-master-01:~# kubeadm upgrade node
```


```
apt-get install kubelet=${KNVER}-00 kubectl=${KNVER}-00
apt-mark hold kubelet kubectl kubeadm && systemctl restart kubelet && unset KNVER

kubectl uncordon master-02
```


## 3) for each worker node:

```
KNVER=1.18.2 && apt-mark unhold kubeadm && apt-get update && \
apt-get install -y kubeadm=${KNVER}-00 && apt-mark hold kubeadm
```


```
  master-node# NODE=max2-worker-04 && kubectl drain $NODE --ignore-daemonsets --delete-local-data
```


```
kubeadm upgrade node && \
apt-mark unhold kubelet kubectl && \
apt-get install -y kubelet=${KNVER}-00 kubectl=${KNVER}-00 && \
apt-mark hold kubelet kubectl kubeadm && systemctl restart kubelet && unset KNVER
```


reboot #(not really needed, but I'll do it)

```
  master-node# kubectl uncordon $NODE && unset NODE 
```


DONE.
