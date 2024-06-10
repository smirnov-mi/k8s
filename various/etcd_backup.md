# ETCD backup in k8s

See docs: https://kubernetes.io/docs/tasks/administer-cluster/configure-upgrade-etcd/

get facts (cert, ca, key)

    grep etcd /etc/kubernetes/manifests/kube-apiserver.yaml 

create a snapshot

    ETCDCTL_API=3 etcdctl --cert=/etc/kubernetes/pki/etcd/server.crt \ 
    --key=/etc/kubernetes/pki/etcd/server.key --cacert=/etc/kubernetes/pki/etcd/ca.crt snapshot save snapshot.db

restore a snapshot into new folder

stop all static pods

edit etcd.yaml to look up the new path

move all yamls back
