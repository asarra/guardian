Install steps for the NixOs through this configuration:
- cd /etc/nixos && sudo git clone https://github.com/asarra/guardian
- cd guardian && sudo mv configuration.nix install.sh ..
- cd .. && sudo rm -rf guardian
- sudo bash ./install.sh

On the client:
- ssh asarra@IP
