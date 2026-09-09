#!/usr/bin/env bash
set -euo pipefail

# Reset the default libvirt network
virsh net-destroy default 2>/dev/null || true
virsh net-undefine default 2>/dev/null || true

# Recreate standard NAT network dynamically without using file pointers
echo "<network><name>default</name><forward mode='nat'/><bridge name='virbr0' stp='on' delay='0'/><ip address='10.0.0.1' netmask='255.255.255.0'><dhcp><range start='10.0.0.2' end='10.0.0.254'/></dhcp></ip></network>" | virsh net-define /dev/stdin
virsh net-start default
virsh net-autostart default
