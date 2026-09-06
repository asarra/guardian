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
          networking.networkmanager.enable = pkgs.lib.mkForce false;
          networking.wireless = {
            enable = true;
            networks."${builtins.getEnv "WLAN_SSID"}".psk = builtins.getEnv "WLAN_PASS";
          };

          services.openssh = {
            enable = true;
            settings.PasswordAuthentication = true;
          };

          users.users.guardian.password = builtins.getEnv "SSH_PASS";
          users.users.guardian.isSystemUser = true;

          environment.systemPackages = [
            (pkgs.writeScriptBin "bootstrap" ''
              #!/usr/bin/env bash
              set -e
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
