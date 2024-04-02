# k8s
general k8s things


## useful


### combine multiple contexts

having a few kube-configs as separate files under .kube ,

you can combine them into one file and use context then.


```

~/.kube$ KUBECONFIG=config:config_t1 kubectl config view --merge --flatten > config.new

```

see also: https://devopscube.com/kubernetes-kubeconfig-file/


### Cronjobs & Sidecar in 1.28+

Kubernetes jobs https://medium.com/teamsnap-engineering/properly-running-kubernetes-jobs-with-sidecars-in-2024-k8s-1-28-ad9b51d17d50



