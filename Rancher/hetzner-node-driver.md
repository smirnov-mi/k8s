# Hetzner API Node driver

## Adding new node driver for the first time

Rancher can install/remove cluser nodes using API of the resp. provider.
For HETZNER there's an API driver provided by:

see: [github.com/JonasProgrammer/docker-machine-driver-hetzner](https://github.com/JonasProgrammer/docker-machine-driver-hetzner/releases/)


Add the latest URL (....tar.gz) to **Cluster Management - Drivers - Node Driver - Add new...**




Setup of the "Hetzner v2" version:


Download URL:
```
https://github.com/JonasProgrammer/docker-machine-driver-hetzner/releases/download/5.0.2/docker-machine-driver-hetzner_5.0.2_linux_amd64.tar.gz
```
Custom UI URL:
```
https://storage.googleapis.com/hcloud-rancher-v2-ui-driver/component.js
```
Whitelist domains:
```
storage.googleapis.com
```


## Node Templates

Rancher: Cluster Management - RKE1 Conf. - Node Templates


## Add Node Template (in Rancher)



### create a new token in Hetzner

examle:
```
9Hvm8fSjMYjItrs6uzq0xNxxOA3WxihMLBJPQgL2lntrpqGDsE68kOkiKK4Ozlax
```

### cloud-init (optional)

see https://github.com/smirnov-mi/how-to/blob/8d183902ea97dfef7a221651202e199786ec8c9b/rancher/hetzner/RKE-node-cloud-init.txt

### add label (optional)

for worker nodes - add Label, so the Loadbalancer can automatically address them:

```
Key: load-balancer 
  value: LB4-1
```


## Updating node driver

**Do not create a second version** of the same node driver, as it can't be removed as long as it's in use (configured to be used in any template)

So you have to edit the current one.

https://github.com/rancher/rancher/issues/43609


