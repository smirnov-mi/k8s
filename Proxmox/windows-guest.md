# installing a windows guest VM in Proxmox

Nov.2023 based on https://medium.com/@0ka/how-to-install-windows-server-2022-in-proxmox-ve-25aa2e6bdf15

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
    
    Change administrator password when prompted. (must not be a trivial, e.g. Admin2022)

## Generalize the image

https://learn.microsoft.com/en-us/windows-hardware/manufacture/desktop/sysprep--generalize--a-windows-installation?view=windows-11


(Boot in Audit mode ??)


in the command line run:

    %WINDIR%\system32\sysprep\sysprep.exe /generalize /shutdown /oobe


