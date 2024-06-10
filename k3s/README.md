# k3s - a lightweight kubernetes distribution

*1.Jun.2024*

## installing k3s on ubuntu 24.04


run as root

```bash
curl -sfL https://get.k3s.io | sh -
```

verify

```bash
	systemctl status k3s
```

for details/options see https://rancher.com/docs/k3s/latest/en/installation/install-options/server-config/ 
and

https://www.digitalocean.com/community/tutorials/how-to-setup-k3s-kubernetes-cluster-on-ubuntu


having more than one node, join the cluster

	cat /var/lib/rancher/k3s/server/node-token

get the kubeconfig

	cat /etc/rancher/k3s/k3s.yaml

copy the kubeconfig to your user

	mkdir ~/.kube
	cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
	chown -R $USER:$USER ~/.kube

install kubectl, if not done yet

	sudo apt-get install -y kubectl

install helm

https://helm.sh/docs/intro/install/

	curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

verify helm installation, as YOUR user (not root)

	
	helm list

	NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
	muscat@Ubuntu24-ws:~$ helm list -A
	NAME            NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                           APP VERSION
	traefik         kube-system     1               2024-06-01 16:19:28.006902754 +0000 UTC deployed        traefik-25.0.3+up25.0.0         v2.10.5
	traefik-crd     kube-system     1               2024-06-01 16:19:20.754458048 +0000 UTC deployed        traefik-crd-25.0.3+up25.0.0     v2.10.5

