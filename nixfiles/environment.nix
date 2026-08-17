{ config, pkgs, lib, ... }:

{
  programs = {
    mtr.enable = true; # installs network diagnostic tool
    virt-manager.enable = true; # installs virtualisation client
  };

  environment = {
    systemPackages = with pkgs; [
      git
      btop fastfetch
    ];
  };

  virtualisation = {
    #docker = { # Installs docker and sets it up
    #  enable = false; # https://wiki.nixos.org/wiki/Docker#Rootless_Docker
    #  rootless.enable = true;
    #  rootless.setSocketVariable = true;
    #  rootless.daemon.settings.data-root = "~/.local/share/docker"; # https://discourse.nixos.org/t/rootless-docker-systemd-resolved-and-dns-inside-containers/47030/4
    #};

    libvirtd.enable = true; # If you cannot activate the "default" internet, reboot and try it again with virsh # https://bbs.archlinux.org/viewtopic.php?id=284089
  };
}
