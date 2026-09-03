Install steps for the fresh minimal NixOs through this configuration:
- nmtui
- ping google.de
- cd /etc/nixos && sudo git clone https://github.com/asarra/guardian
- cd guardian && sudo mv configuration.nix install.sh deploy.sh ..
- cd .. && sudo rm -rf guardian
- sudo bash ./install.sh

On the client:
- ssh asarra@NixOSIP
- virsh -c qemu:///system domifaddr colt-vm && exit
- nano ~/.ssh/config
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
