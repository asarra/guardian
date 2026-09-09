{
  description = "Guardian hypervisor flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko }: {
    nixosConfigurations.installerISO = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"

        ({ pkgs, ... }: {
          # Optimizing the installer image
          boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
          boot.supportedFilesystems = [ "ext4" "ntfs" "vfat" ];
          documentation.enable = nixpkgs.lib.mkForce false;
          documentation.nixos.enable = nixpkgs.lib.mkForce false;

          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          networking.networkmanager.enable = pkgs.lib.mkForce false;
          networking.wireless = {
            enable = true;
            networks."${builtins.getEnv "WLAN_SSID"}".psk = builtins.getEnv "WLAN_PASS";
          };

          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true;
          };

          users.groups.guardian = {};
          users.users.asarra = {
            isNormalUser = true;
            group = "guardian";
            extraGroups = [ "wheel" ];
            password = builtins.getEnv "SSH_PASS";
          };

          environment.systemPackages = [
            (pkgs.writeScriptBin "bootstrap" ''
              #!/usr/bin/env bash
              set -e
              git clone https://github.com/asarra/guardian /tmp/guardian
              cd /tmp/guardian
              nix run github:nix-community/disko -- --mode destroy,format,mount ./disk-configuration.nix --yes-wipe-all-disks

              # pre-reboot user password injection
              mkdir -p /mnt/etc/nixos
              mkpasswd -m yescrypt "${builtins.getEnv "SSH_PASS"}" | tee /mnt/etc/nixos/secret-password > /dev/null
              chmod 600 /mnt/etc/nixos/secret-password

              # moving the vm deployment to the expected target folder
              mkdir -p /mnt/etc/nixos/vms
              mv /tmp/guardian/vms/deploy-colt-vm.sh /mnt/etc/nixos/vms
              mv /tmp/guardian/vms/deploy-vm-network.sh /mnt/etc/nixos/vms

              # pre-reboot wifi injection for network manager
              mkdir -p /mnt/etc/NetworkManager/system-connections
              tee /mnt/etc/NetworkManager/system-connections/wlan.nmconnection > /dev/null <<EOF
              [connection]
              id=${builtins.getEnv "WLAN_SSID"}
              type=wifi
              [wifi]
              mode=infrastructure
              ssid=${builtins.getEnv "WLAN_SSID"}
              [wifi-security]
              auth-alg=open
              key-mgmt=wpa-psk
              psk=${builtins.getEnv "WLAN_PASS"}
              [ipv4]
              method=auto
              [ipv6]
              method=auto
              EOF
              chmod 600 /mnt/etc/NetworkManager/system-connections/wlan.nmconnection

              nixos-install --flake /tmp/guardian#guardian --no-root-passwd
              echo "Installation was successful. Restarting..."
              reboot
            '')
          ];
        })
      ];
    };

    nixosConfigurations.guardian = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        disko.nixosModules.disko
        ./disk-configuration.nix
        ./configuration.nix
      ];
    };
  };
}
