{ pkgs, ... }:

let
  mkSystemSimple = { description, exec, preStart ? "", timeout ? 30 }: { # Helper template
    description = description; # Manual: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html
    after = [ "network.target" "local-fs.target" ];
    wantedBy = [ "multi-user.target" ];
    preStart = preStart;
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
        preStart = ''
          mkdir -p /var/lib/my-vms
          [ -f /var/lib/my-vms/colt-disk.qcow2 ] || ${pkgs.qemu_kvm}/bin/qemu-img create -f qcow2 /var/lib/my-vms/colt-disk.qcow2 50G
          if [ ! -f /var/lib/my-vms/colt-install.iso ]; then
            URL=$(echo "https://github.com/asarra/guardian" | sed -e 's|github.com|nightly.link|' -e 's|/actions||' -e 's|$|/main/output.zip|')
            ${pkgs.curl}/bin/curl -L -o /var/lib/my-vms/a.zip "$URL"
            ${pkgs.unzip}/bin/unzip -p /var/lib/my-vms/a.zip coreos.iso > /var/lib/my-vms/colt-install.iso
            rm /var/lib/my-vms/a.zip
          fi
        '';
        exec = ''
          ${pkgs.qemu_kvm}/bin/qemu-system-x86_64 \
            -enable-kvm -m 8G -smp 8 -vga none -nographic -cpu host,kvm=off \
            -drive if=pflash,format=raw,readonly=on,file=/run/current-system/sw/share/OVMF/OVMF_CODE.fd \
            -drive if=pflash,format=raw,snapshot=on,file=/run/current-system/sw/share/OVMF/OVMF_VARS.fd \
            -device pcie-root-port,id=p \
            -drive file=/var/lib/my-vms/colt-disk.qcow2,if=virtio \
            -drive file=/var/lib/my-vms/colt-install.iso,media=cdrom \
            -device vfio-pci,host=26:00.0,bus=p,multifunction=on \
            -device vfio-pci,host=26:00.1,bus=p
        '';
        };

      #second-vm

    };
  };
}
