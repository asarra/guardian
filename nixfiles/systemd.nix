{ pkgs, ... }:

let
  mkSystemSimple = { description, exec, timeout ? 30 }: { # Helper template
    description = description; # Manual: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html
    after = [ "network.target" "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      User = "root";
      ExecStart = exec;
      TimeoutStopSec = timeout;
    };
  };
in {
  systemd = {
    services = { # https://discourse.nixos.org/t/screen-locker-crashing/33510
      systemd-logind.restartIfChanged = false; # SDDM and lightdm screen locker crash fix
      NetworkManager.restartIfChanged = false;

      colt-vm = mkSystemSimple {
        description = "Colt VM";
        exec = ''
          ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
            -enable-kvm -m 8G -smp 8 -vga none -nographic -cpu host,kvm=off \
            -drive if=pflash,format=raw,readonly=on,file=/run/current-system/sw/share/OVMF/OVMF_CODE.fd \
            -drive if=pflash,format=raw,snapshot=on,file=/run/current-system/sw/share/OVMF/OVMF_VARS.fd \
            -device pcie-root-port,id=p \
            -drive file=/var/lib/my-vms/colt-guest.qcow2,if=virtio \
            -device vfio-pci,host=26:00.0,bus=p,multifunction=on \
            -device vfio-pci,host=26:00.1,bus=p
        '';
      };

      #second-vm

    };
  };
}
