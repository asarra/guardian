Install steps for the fresh minimal NixOs through this configuration:
- nmtui
- ping google.de
- cd /etc/nixos && sudo git clone https://github.com/asarra/guardian
- cd guardian && sudo mv configuration.nix install.sh ..
- cd .. && sudo rm -rf guardian
- sudo bash ./install.sh

On the client:
- ssh asarra@NixOSIP
- systemctl status colt-vm.service
- exit
- ssh -vvv -J asarra@NixOSIP:2222 -i .ssh/colt core@localhost

- nano ~/.ssh/config
```
Host jumphost
    HostName NixOSIP
    User asarra
    IdentityFile ~/.ssh/id_ed25519

Host coreos
    HostName localhost
    User core
    ProxyJump jumphost
    IdentityFile ~/.ssh/colt
```
- ssh coreos
