# Proxmox

https://pve.proxmox.com/


## setup

### Install on Hetzner VM 

For test purpose - OK
    
    install debian
    
    ask support to upload the current Proxmox ISO image, we have 8.1 now,
    
    boot the VM from that image and install Proxmox
    
    the root PW will be that from the previous debian installation


### Standalone installation 

network speed issues - disable Datacenter Firewall


https://github.com/smirnov-mi/how-to/tree/main/proxmox


having locale warnings, add foll. into /etc/default/locale file:
```
LANG="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
```


## System Update / Upgrades

IF running a cluser, free up the node first,
only upgrade one node at a time

	# Paketquellen Updaten
	apt update

	# Pakete installieren
	apt dist-upgrade

	# Reboot the server
	systemctl reboot 



## Terraform

### install tf on mac:

```
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
```
https://developer.hashicorp.com/terraform/install


### add a provider

e.g. provider.tf 
```
terraform {

        required_providers {
                proxmox = {
                        source = "telmate/proxmox"
                        #version = "2.9.14"
                        version = "3.0.1-rc1"
                }
        }
}
```

### create a new Token in PVE, add it into your (local PC) env, as e.g.
```
PM_API_TOKEN_ID=terraform-provider@pve-server!my-token
PM_API_TOKEN_SECRET=1c536737-5fe8-2110-b180-1550ab1cXxXx
```



## Rancher driver (TODO)

https://github.com/cuza/rancher-ui-driver-proxmoxve

https://github.com/lnxbil/docker-machine-driver-proxmox-ve

https://github.com/cuza/rancher-ui-driver-proxmoxve




## HA / Cluster 

3 nodes (odd number) required to build a quorum for cluster, regardless of HA on or off

https://youtu.be/08b9DDJ_yf4?si=94nwelC6EPaOZ17h


https://www.youtube.com/watch?v=FQIdhX0xSoQ (DE)

