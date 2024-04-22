
# Setup the Terraform

create [provider.tf](https://github.com/smirnov-mi/how-to/blob/main/proxmox/tf-mc-local/provider.tf) and
[sample-server.tf](https://github.com/smirnov-mi/how-to/blob/main/proxmox/tf-mc-local/srv-ubuntu1.tf),
see [how-to](https://github.com/smirnov-mi/how-to/tree/main/proxmox/tf-mc-local) and

https://pve.proxmox.com/wiki/Cloud-Init_Support

https://github.com/Telmate/terraform-provider-proxmox/blob/master/examples/cloudinit_example.tf


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


