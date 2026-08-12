{ config, pkgs, lib, ... }:

{
  # Login setup
  services.xserver.displayManager.startx.enable = true; # brings us straight to tty
  programs = {
    mtr.enable = true; # installs network diagnostic tool
    virt-manager.enable = true; # installs virtualisation client

    # Development
    zsh = {
      enable = true;
      syntaxHighlighting.enable = true;
      autosuggestions.enable = true;
      ohMyZsh.enable = true; # https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/
      ohMyZsh.plugins = [ "git" "autojump" ];
      ohMyZsh.theme = "robbyrussell";
      shellAliases = {};
    };
  };

  environment = {
    systemPackages = with pkgs; [
      git busybox
      btop fastfetch tree autojump
    ];
  };

  virtualisation = {
    #docker = { # Installs docker and sets it up
    #  enable = false; # https://wiki.nixos.org/wiki/Docker#Rootless_Docker
    #  rootless.enable = true;
    #  rootless.setSocketVariable = true;
    #  rootless.daemon.settings.data-root = "~/.local/share/docker"; # https://discourse.nixos.org/t/rootless-docker-systemd-resolved-and-dns-inside-containers/47030/4
    #};

    libvirtd = { # Installs libvirt and sets it up
      enable = true; # If you cannot activate the "default" internet, reboot and try it again with virsh # https://bbs.archlinux.org/viewtopic.php?id=284089
      qemu.ovmf.enable = true;
      qemu.ovmf.packages = [ pkgs.OVMFFull.fd ];
    };
  };
}