# Proxmox prepare Ubuntu image and template


based on: 

https://www.thomas-krenn.com/de/wiki/Terraform_mit_Proxmox_VE_Tutorial

https://github.com/Telmate/terraform-provider-proxmox/blob/master/docs/resources/vm_qemu.md

https://pve.proxmox.com/wiki/Cloud-Init_Support



## get and prepare the image

Ubuntu 22.04 TLS minimal cloud image:

pve>
```
cd /var/lib/vz/template/iso/ &&
wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img -O /var/lib/vz/template/iso/ubuntu-22.04_minimal_cloud.img
```

Ubuntu 24.04 TLS minimal cloud image: 

```
pve:/var/lib/vz/template/iso# 
wget https://cloud-images.ubuntu.com/minimal/releases/noble/release/ubuntu-24.04-minimal-cloudimg-amd64.img
```



install libguestfs-toos on the PVE server, to be able to modify the image
```
apt update -y && apt install libguestfs-tools -y
```

Modify image to our needs:
```
IMAGE=/var/lib/vz/template/iso/ubuntu-24.04-minimal-cloudimg-amd64.img

virt-customize -a $IMAGE --install qemu-guest-agent &&
virt-customize -a $IMAGE --root-password password:Proxmox &&
virt-customize -a $IMAGE --run-command "echo -n > /etc/machine-id"
```

## create a template


```
TEMPL_NAME=ubuntu2404-ci
TEMPL_NUM=9004
IMAGE=/var/lib/vz/template/iso/ubuntu-24.04-minimal-cloudimg-amd64.img       #if not set yet

qm create $TEMPL_NUM --name $TEMPL_NAME --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 &&
qm importdisk $TEMPL_NUM $IMAGE local-disk2 &&
qm set $TEMPL_NUM --scsihw virtio-scsi-pci --scsi0 local-disk2:$TEMPL_NUM/vm-$TEMPL_NUM-disk-0.raw &&
qm set $TEMPL_NUM --boot c --bootdisk scsi0 &&
qm set $TEMPL_NUM --ide2 local-disk2:cloudinit &&
qm set $TEMPL_NUM --serial0 socket --vga serial0 &&
qm set $TEMPL_NUM --agent enabled=1

#OPTIONAL: qm resize $TEMPL_NUM scsi0 3G       #too little for 24.04, which is 3.5G

qm template $TEMPL_NUM
```


### Setup the Terraform 

create [provider.tf](https://github.com/smirnov-mi/how-to/blob/main/proxmox/tf-mc-local/provider.tf) and 
[sample-server.tf](https://github.com/smirnov-mi/how-to/blob/main/proxmox/tf-mc-local/srv-ubuntu1.tf), 
see [how-to](https://github.com/smirnov-mi/how-to/tree/main/proxmox/tf-mc-local) and

https://pve.proxmox.com/wiki/Cloud-Init_Support



