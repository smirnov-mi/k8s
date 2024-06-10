# k8s
general k8s things


## kodekloud cheat sheet

https://kodekloud.com/pages/k8s-commands-cheatsheet?utm_source=linkedin&utm_medium=social&utm_campaign=dg-kubernetes-skill+-+k8s+Commands+Cheatsheet&utm_content=singlepost-educational



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


# HELM

(https://github.com/smirnov-mi/tech/blob/main/helm/)[https://github.com/smirnov-mi/tech/blob/main/helm/]



