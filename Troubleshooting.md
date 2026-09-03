For troubleshooting visually to see the VM:

    ssh -L 5900:127.0.0.1:5900 asarra@NixOSIP
    VNC: localhost:5900

For troubleshooting on the client:

    sudo virsh domblklist colt-vm
    sudo virsh destroy colt-vm
    sudo virsh detach-disk colt-vm sda --persistent
    sudo virsh start colt-vm
