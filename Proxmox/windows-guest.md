# installing a windows guest VM in Proxmox

Nov.2023 based on https://medium.com/@0ka/how-to-install-windows-server-2022-in-proxmox-ve-25aa2e6bdf15

and https://pve.proxmox.com/wiki/Windows_2022_guest_best_practices

## Download images

### OS image (180 days free)
https://www.microsoft.com/en-us/evalcenter/download-windows-server-2022

### VirtIO drivers
https://pve.proxmox.com/wiki/Windows_VirtIO_Drivers


## Create a W2022 Virtual Machine

    Upload the Server ISO to Proxmox Storage. Click local (pve) → ISO images -> Select the ISO file -> Press Upload.

    Repeat the previous step for the VirtIO Driver ISO.
    Click ‘Create VM’ at the top right of Proxmox. Provide a VM ID, name and select the Server ISO image from the OS tab. Select Windows as the guest OS.

    Under System, enable the “Qemu Agent”. Select the relevant EFI and TPM storage.
    Under Disks, change the Bus/Driver to SCSI and select your relevant storage. Under CPU, increase the cores to 2+. Under memory, increase or leave the MiB set. Depending on your use case. Confirm and save.
    Under Network, select the VirtIO (paravirtualised).
    Once created, click into it and view the Hardware details. Add a new CD/DVD drive and select the VirtIO drivers.
    
    Right-click VM, Select Start, open virtual machine and wait for boot to complete (If you get a BdsDxe: failed to load Boot0001 error, press esc as soon as the VM boots).
    Follow the installer steps until the installation type selection. Press Custom (advanced).
    Click ‘Load Driver’ -> Browse to the CD drive where the VirtIO driver was mounted, select folder “viosci/2k22/amd64”, select “Redhat VirtIO SCSI pass-through controller”, click next to install.
    Finally, click into Options, and change ‘Start at Boot’ to yes.

    Check the boot order in the VM settings, set the device with the windows-iso at the first place, ensure you see the virtIO drivers iso as well.

    
    Follow the installer steps until the installation type selection. Press Custom (advanced).
    
    Click ‘Load Driver’ -> Browse to the CD drive where the VirtIO driver was mounted, select folder “viosci/2k22/amd64”, select “Redhat VirtIO SCSI pass-through controller”, click next to install.

    Choose the drive and continue the steps.
    
    Change administrator password when prompted. (must not be trivial, e.g. Admin2022)

## Add device drivers

as usual, add device drivers (located on the "virtio" disk). 


## Install windows updates (optional)

usual windows software update + reboot

## install OpenSSH (optional)

OpenSSH on Windows:

https://learn.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse?tabs=gui

Run in PowerShell:

```
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Install the OpenSSH Client
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0

# Install the OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start the sshd service
Start-Service sshd

# OPTIONAL but recommended:
Set-Service -Name sshd -StartupType 'Automatic'

# Confirm the Firewall rule is configured. It should be created automatically by setup. Run the following to verify
if (!(Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue | Select-Object Name, Enabled)) {
    Write-Output "Firewall Rule 'OpenSSH-Server-In-TCP' does not exist, creating it..."
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
} else {
    Write-Output "Firewall rule 'OpenSSH-Server-In-TCP' has been created and exists."
}
```

DONE.







## Install cloud-init

https://cloudbase.it/cloudbase-init/#download

download link (latest beta): https://cloudbase.it/downloads/CloudbaseInitSetup_x64.msi

1.1.5dev11 (installed to run as LocalSystem)

Evaluating this:  https://yetiops.net/posts/proxmox-terraform-cloudinit-windows/






## Generalize the image (sysprep)

https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation?view=windows-11


(Boot in Audit mode ??)


in the command line run:

    %WINDIR%\system32\sysprep\sysprep.exe /generalize /shutdown /oobe



## Sysprep and Answer-file

*->* https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/use-answer-files-with-sysprep?view=windows-11

https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep-process-overview?view=windows-11

https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep-command-line-options?view=windows-11

https://pve.proxmox.com/wiki/Windows_2012_guest_best_practices

https://www.thomas-krenn.com/de/wiki/Sysprep_f%C3%BCr_Windows_10/11_und_Windows_Server_2022

cloud-init howto: https://forum.proxmox.com/threads/how-to-create-windows-cloudinit-templates-on-proxmox-7-3-patch-included.123338/


...


## create an ISO on PVE server

create a config file on the PVE server, then convert it into an ISO image, and place into the ISO storage location, e.g.


```
-rw-r--r-- 1 root root          8 Apr 19 21:36 windows-1-config.ini

root@pve:/var/lib/vz/template/iso# mkisofs -J -l -R -V "Label CD" -iso-level 4 -o windows-srv1.iso windows-1-config.ini
Warning: Creating ISO-9660:1999 (version 2) filesystem.
Warning: ISO-9660 filenames longer than 31 may cause buffer overflows in the OS.
Total translation table size: 0
Total rockridge attributes bytes: 261
Total directory bytes: 0
Path table size(bytes): 10
Max brk space used 0
183 extents written (0 MB)
root@pve:/var/lib/vz/template/iso# ll
total 5539436
-rw-r--r-- 1 root root     374784 Apr 19 21:41 output.iso
-rw-r--r-- 1 root root  627519488 Apr 19 09:00 virtio-win-0.1.240.iso
-rw-r--r-- 1 root root 5044094976 Apr 19 11:18 W2022_SERVER_EVAL_x64FRE_en-us.iso
-rw-r--r-- 1 root root          8 Apr 19 21:36 windows-1-config.ini
-rw-r--r-- 1 root root     374784 Apr 19 21:42 windows-srv1.iso

```

it will be shown in the local ISO location of the PVE server



## Creating ISO via Packer

https://holdmybeersecurity.com/2020/10/03/creating-a-windows-10-64-bit-vm-on-proxmox-with-packer-v1-6-3-and-vault/





