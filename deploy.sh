#!/usr/bin/env bash
set -euo pipefail

# 1. Provision storage directory
sudo mkdir -p /var/lib/my-vms
[ -f /var/lib/my-vms/colt-disk.qcow2 ] || sudo qemu-img create -f qcow2 /var/lib/my-vms/colt-disk.qcow2 50G
[ -f /var/lib/my-vms/coreos.iso ] || sudo curl -L -o /var/lib/my-vms/coreos.iso https://github.com/asarra/colt/releases/download/latest/coreos.iso

# 2. Reset the default libvirt network (No XML files required)
sudo virsh net-destroy default 2>/dev/null || true
sudo virsh net-undefine default 2>/dev/null || true

# Recreate standard NAT network dynamically without using file pointers
echo "<network><name>default</name><forward mode='nat'/><bridge name='virbr0' stp='on' delay='0'/><ip address='192.168.122.1' netmask='255.255.255.0'><dhcp><range start='192.168.122.2' end='192.168.122.254'/></dhcp></ip></network>" | sudo virsh net-define /dev/stdin
sudo virsh net-start default
sudo virsh net-autostart default

# 3. Clean up the old instance if it exists
sudo virsh destroy colt-vm 2>/dev/null || true
sudo virsh undefine colt-vm --nvram 2>/dev/null || true

# 4. Pure libvirt VM generation via standard flags
sudo virt-install \
  --name colt-vm \
  --memory 8192 \
  --vcpus 8 \
  --cpu host-passthrough \
  --os-variant fedora-coreos-stable \
  --boot firmware=efi \
  --disk path=/var/lib/my-vms/colt-disk.qcow2,bus=virtio,boot_order=1 \
  --disk path=/var/lib/my-vms/coreos.iso,device=cdrom,bus=scsi,boot.order=2 \
  --network network=default,model=virtio \
  --host-device pci_0000_26_00_0 \
  --host-device pci_0000_26_00_1 \
  --host-device pci_0000_26_00_2 \
  --host-device pci_0000_26_00_3 \
  --graphics vnc,listen=127.0.0.1 \
  --console pty,target_type=serial \
  --boot cdrom,hd,menu=on \
  --autostart \
  --noautoconsole \
  --import \
  --wait 0

echo "Deployment finished. VM is running and registered to libvirt system lifecycle triggers."
