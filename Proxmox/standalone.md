#   Setup Proxmox on a standalone server

## Prereq.

## Setup

OFFICIAL DOCS:  https://pve.proxmox.com/pve-docs/


### Main

install debian (not required though?)

download a Proxmox PVE iso image, boot from it

check ssh your-ip

and http, e.g. https://192.168.123.59:8006/


## tuning

### disable enterprise apt repositories and add test-repos and keys

https://pve.proxmox.com/wiki/Package_Repositories#sysadmin_test_repo


### add second local disk for storage (if required)


### Firewall

Datacenter - FIrewall - Options - 

disable Firewall and ebtables for acceptable network speed.



### Setup Terraform and add API-Token

https://www.thomas-krenn.com/de/wiki/Terraform_mit_Proxmox_VE_Tutorial#API_Token_erstellen_in_PVE

```
API Token erstellen in PVE

API-Token creation, in the Datacenter - Permissions -> API-Tokens -> Add. 
Privilege Separation must be set to No, or the checkbox in the API Tokens must be unchecked.

example output:

root@pam!terraform2
b057aea1-a092-49c3-b530-a53fd9e6fccc
```

### TF provider 

https://registry.terraform.io/providers/Telmate/proxmox/latest/docs





