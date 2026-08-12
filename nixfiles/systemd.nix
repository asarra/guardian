{ pkgs, ... }:

let
  mkUserSimple = { description, exec, timeout ? 10 }: { # Helper template
    description = description; # Manual: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html
    wantedBy = [ "graphical-session.target" ];
    wants    = [ "graphical-session.target" ];
    after    = [ "graphical-session.target" ];
    serviceConfig = {
      Type = "simple";
      ExecStart = exec;
      Restart = "on-failure";
      RestartSec = 1;
      TimeoutStopSec = timeout;
    };
  };
in {
  systemd = {
    services = { # Do not restart since it fucks up the current session # From https://discourse.nixos.org/t/screen-locker-crashing/33510
      systemd-logind.restartIfChanged = false; # SDDM and lightdm screen locker crash fix
      NetworkManager.restartIfChanged = false;
    };

    user.services = {
      #polkit-gnome-authentication-agent-1 = mkUserSimple {
      #  description = "polkit-gnome-authentication-agent-1";
      #  exec = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
      #};
    };
  };
}