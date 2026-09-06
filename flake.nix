{
  description = "Guardian Hypervisor - Public Flake";

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
              sudo nixos-install --flake /tmp/guardian#guardian --no-root-passwd --config 'boot.loader.grub.devices = [ "/dev/sdb" ];'
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
