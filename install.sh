#!/usr/bin/env bash
# Run as root
bootctl remove
nixos-rebuild switch # Making sure configuration.nix has been applied
chmod +x "${SCRIPT_DIR}/deploy.sh"
bash "${SCRIPT_DIR}/deploy.sh"
reboot # Restarting since some services only take action after reboot. Even on Nix
