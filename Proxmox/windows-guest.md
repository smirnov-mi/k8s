# installing a windows guest VM in Proxmox

Nov.2023 based on https://medium.com/@0ka/how-to-install-windows-server-2022-in-proxmox-ve-25aa2e6bdf15

## Download images

### OS image (180 days free)
https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022

### VirtIO drivers
https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers

## Create Virtual Machine

    Upload the Server ISO to Proxmox Storage. Click local (pve) → ISO images -> Select the ISO file -> Press Upload.

    Repeat the previous step for the VirtIO Driver ISO.
    Click ‘Create VM’ at the top right of Proxmox. Provide a VM ID, name and select the Server ISO image from the OS tab. Select Windows as the guest OS.


...

