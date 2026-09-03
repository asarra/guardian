Install steps for the fresh minimal NixOs through this configuration (physical access):
- nmtui
- ping google.de
- cd /etc/nixos && sudo git clone https://github.com/asarra/guardian
- cd guardian && sudo mv configuration.nix install.sh deploy.sh ..
- cd .. && sudo rm -rf guardian
- sudo bash ./install.sh

On the client:
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
- With a tailscale connected client you can now connected to the docker services
