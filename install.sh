#!/usr/bin/env bash
# Run as root
bootctl remove
nixos-rebuild switch # Making sure configuration.nix has been applied
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "${SCRIPT_DIR}/deploy.sh"
bash "${SCRIPT_DIR}/deploy.sh"
reboot # Restarting since some services only take action after reboot. Even on Nix
