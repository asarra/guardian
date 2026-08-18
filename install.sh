#!/usr/bin/env bash
# Run as root
bootctl remove
nixos-rebuild switch # Making sure configuration.nix has been applied
virsh net-autostart default # Autostarts internet connection for VMs
reboot # Restarting since some services only take action after reboot. Even on Nix
