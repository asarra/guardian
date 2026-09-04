Setup steps after a fresh, minimal, bare metal NixOs install on the local machine (physical access):
-
- nmtui
- ping google.de
- cd /etc/nixos && sudo git clone https://github.com/asarra/guardian
- cd guardian && sudo mv configuration.nix install.sh deploy.sh ..
- cd .. && sudo rm -rf guardian
- sudo bash ./install.sh

On the client:
-
- ssh asarra@NixOSIP
- virsh -c qemu:///system domifaddr colt-vm
- journalctl -u deploy-colt-vm.service
- exit && nano ~/.ssh/config
```
Host jumphost
    HostName NixOSIP
    User asarra

Host coreos
    HostName CoreOSIP
    User core
    ProxyJump jumphost
    IdentityFile ~/.ssh/colt
```
- ssh coreos
- sudo systemctl enable tailscaled.service
- sudo tailscale up
- sudo systemctl start tailscale-serve.service
- tailscale serve status

With a tailscale connected client you can now connect to the docker services.

Note:
-
More VMs and native containers can be added to the hypervisor host machine.
Currently we only run a guest vm which is Fedora CoreOs that transitions into uCore.

Why?
-
I tried out Proxmox and other hypervisors before. I noticed that I want something that is declarative, has native Wi-Fi support, is lightweight, secure and gives me total control. That is why I decided to combine tech that I already know and handle my requirements the best. NixOs (declarative, native Wi-Fi support, and gives total control of the system through one config file) + KVM/Qemu/libvirt (kernel native and lightweight) as the combined hypervisor.
And as the guest OS I picked uCore (Fedora CoreOS) because it is designed to be a cattle. Set and forget. Instantly replaceable with a new guest instance. It is also declarative and handles docker/podman containers very well and in a very secure way. I am passing through my GPU to the AI application (docker container) inside of it.
