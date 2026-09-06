Setup steps after a fresh, minimal, bare metal NixOs install on the local machine (physical access):
-
- Download the pipeline artefact
- cd ~/Downloads && 7z x artifact.zip && 7z x -p'Password' guardian-secure-installer.7z
- sudo dd if=/var/home/nix/Downloads/guardian-installer.iso of=/dev/sdb bs=4M status=progress oflag=sync (run "lsblk", if you do want to be sure)
- cd ~/ansible && ansible-playbook private_tailscale_deployment.yaml -i inventory.ini

On your own machine, you then run: ansible-playbook private_tailscale_deployment.yaml -i inventory.ini.
You need your tailscale authkey, inventory.ini and colt's private key files.
With a tailscale connected client you can then connect to the docker services.

Note:
-
More VMs and native containers can be added to the hypervisor host machine.
Currently we only run a guest vm which is Fedora CoreOs that transitions into uCore.

Why?
-
I tried out Proxmox (fancy, debian based wrapper for KVM and QEMU) and researched other hypervisors before. I noticed that I want something that is declarative, has native Wi-Fi support, is lightweight, very secure and stable, no config drift, and gives me total system control. That is why I decided to combine tech that I already know and handle my requirements the best. NixOs (declarative, native Wi-Fi support, and gives total control of the system through one config file) + KVM/Qemu/libvirt (kernel native and lightweight) as the combined hypervisor.
And as the guest OS I picked uCore (Fedora CoreOS) because it is designed to be a cattle. Set and forget. Instantly replaceable with a new guest instance. It is also declarative and handles docker/podman containers very well and in a very secure way. I am passing through my GPU to the AI application (docker container) inside of it.
