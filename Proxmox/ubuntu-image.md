# Proxmox prepare Ubuntu image and template

## get and prepare the image

pve>
```
cd /var/lib/vz/template/iso/ &&
wget https://cloud-images.ubuntu.com/minimal/releases/jammy/release/ubuntu-22.04-minimal-cloudimg-amd64.img -O /var/lib/vz/template/iso/ubuntu-22.04_minimal_cloud.img
```

install libguestfs-toos on the PVE server, to be able to modify the image
```
apt update -y && apt install libguestfs-tools -y
```

Modify image to our needs:
```
virt-customize -a /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img --install qemu-guest-agent &&
virt-customize -a /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img --root-password password:Proxmox &&
virt-customize -a /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img --run-command "echo -n > /etc/machine-id"
```

## create a template

```
qm create 9001 --name "ubuntu2204-ci" --memory 2048 --cores 2 --net0 virtio,bridge=vmbr0 &&
qm importdisk 9001 /var/lib/vz/template/iso/jammy-server-cloudimg-amd64.img local-disk2 &&
qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-disk2:9001/vm-9001-disk-0.raw &&
qm set 9001 --boot c --bootdisk scsi0 &&
qm set 9001 --ide2 local-disk2:cloudinit &&
qm set 9001 --serial0 socket --vga serial0 &&
qm set 9001 --agent enabled=1 &&
qm resize 9001 scsi0 3G &&
qm template 9001
```


