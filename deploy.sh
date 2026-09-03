#!/usr/bin/env bash
set -euo pipefail

# 0. Check if this is the 1st boot to avoid missing packages
[ ! -f /var/lib/colt-vm-booted ] && touch /var/lib/colt-vm-booted && exit 0

# 1. Provision storage directory
mkdir -p /var/lib/my-vms
[ -f /var/lib/my-vms/colt-disk.qcow2 ] || qemu-img create -f qcow2 /var/lib/my-vms/colt-disk.qcow2 50G
[ -f /var/lib/my-vms/coreos.iso ] || curl -L -o /var/lib/my-vms/coreos.iso https://github.com/asarra/colt/releases/download/latest/coreos.iso

# 2. Reset the default libvirt network (No XML files required)
virsh net-destroy default 2>/dev/null || true
virsh net-undefine default 2>/dev/null || true

# Recreate standard NAT network dynamically without using file pointers
echo "<network><name>default</name><forward mode='nat'/><bridge name='virbr0' stp='on' delay='0'/><ip address='192.168.122.1' netmask='255.255.255.0'><dhcp><range start='192.168.122.2' end='192.168.122.254'/></dhcp></ip></network>" | virsh net-define /dev/stdin
virsh net-start default
virsh net-autostart default

# 3. Clean up the old instance if it exists
virsh destroy colt-vm 2>/dev/null || true
virsh undefine colt-vm --nvram 2>/dev/null || true

# 4. Pure libvirt VM generation via standard flags
virt-install \
  --name colt-vm \
  --memory 8192 \
  --vcpus 8 \
  --cpu host-passthrough \
  --os-variant fedora-coreos-stable \
  --boot firmware=efi \
  --disk path=/var/lib/my-vms/colt-disk.qcow2,bus=scsi,target=sda \
  --disk path=/var/lib/my-vms/coreos.iso,device=cdrom,bus=scsi \
  --network network=default,model=virtio \
  --host-device pci_0000_26_00_0 \
  --host-device pci_0000_26_00_1 \
  --host-device pci_0000_26_00_2 \
  --host-device pci_0000_26_00_3 \
  --graphics vnc,listen=127.0.0.1 \
  --console pty,target_type=serial \
  --boot hd,cdrom,menu=on \
  --autostart \
  --noautoconsole \
  --wait 0

echo "Deployment finished. VM is running and registered to libvirt system lifecycle triggers."
