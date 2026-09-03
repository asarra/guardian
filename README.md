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
- # for troubleshooting with VNC: ssh -L 5900:127.0.0.1:5900 asarra@NixOSIP && localhost:5900
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
