
# Introdution

As VyOS is becoming more popular, building and automating images are essential. Packer is flexible and 
can create custom images easily for any cloud and bare metal needs.

While VyOS has its own tools for creating images and building like [vyos-vm-images](https://github.com/vyos/vyos-vm-images)
or [vyos-build](https://github.com/vyos/vyos-build), they lack features hashicorp packer can provide for automating images.
vyos-vm-images use ansible for build images, you can do almost any lower level customatization using this great tool. 
vyos-build can be customizated and create custom images as well. 

Some notes about packer-vyos:
* packer-vyos audience is for devops who understand how packer works
* packer-vyos use qemu for default building
* packer-vyos image can access internet inside building VM and download custom packages


## How build process works:

* you should provides an vyos.iso for builder
* iso can be a LTS/oficial one or nightly iso or you can use [vyos-build](https://docs.vyos.io/en/equuleus/contributing/build-vyos.html) to build an iso
* packer-vyos will install VyOS same way than manually installations
    * packer-vyos will start vyos.iso image in a qemu VM, VyOS will run in Live CD mode inside a qemu VM
    * packer will provide DHCP server, 1 ipv4, 1 gateway with NAT for qemu images
    * packer will provide a http server serving http/* folder files to VyOS, so we can use it to customize image
    * packer can provide for development with headless=false mode a vnc server, so we can see what is running on VM console
    * packer-vyos will send keyboard commands to VyOS Live CD like default vyos / vyos username/password
    * packer-vyos will configure networking to use dhcp ```set interface ethernet eth0 address dhcp```, than ```commit```
    * packer-vyos will customize images using scripts/vyos/*.sh according to rules inside vyos.pkr.hcl
    * after all scripts packer-vyos will install image to disk using VyOS ```install image```
    * packer will write image on output-* folder

# Features

* add debian 11/12 sources in apt-sources.d before install
* remove debian 11/12 sources in apt-sources.d before install
* install custom packages using apt install
* install cloud-init from the upstream Debian repository or the custom version provided by VyOS
* do any shell command or vyos command before to install
* cleanup and prepare everything to turn vyos into cloud image
* simple parameters as disk size or image name can be customized easily
* install qemu-guest-agent
* customize to install any other agent or package as needed
* grub with kvm/serial
* disable/enable ssh 
* disable/enable dhcp
* set interface/gateway 
* keep vyos/vyos user/password or customize it
* it is possible to build custom images for bare metal, docker or any virtualization or cloud providers
* also it is possible to integrate building process using other [packer builders](https://developer.hashicorp.com/packer/integrations?components=builder) 
besides qemu like aws, azure, cloudstack, docker, gcp, proxmox, vagrant, virtualbox, vmware and others

# Requirements

* packer-vyos is develop using ubuntu 24 LTS, but should run in debian, you can try other distros
* packer-vyos use qemu, build inside a VM needs vmx/svm instruction. VMs inside proxmox need cpu=host
    * check if virtualization is enabled
    ```
    egrep '(vmx|svm)' --color=always /proc/cpuinfo
    ```
    * enabling neasted virtualization in proxmox:
    ```
    qm set <vmid> --cpu host
    ```
* use root to build, for production use a dedicated vm only for packer build with cpu=host


## Packages requirements:

```
apt install make
apt install qemu-system 
```

## headless=false 

For headless=false follow development instructions bellow.

# Debugging / development

* headless=true is recommended
* to turn headless=true use vncviewer (apt install tigervnc-viewer)
* for compilling packages remotely use Xvfb (apt install xvfb)
* for forward X11 ports use ssh forwarding (ssh -X -v or ssh -Y -v if -X doesn't works)
* edit vnc-connect.sh and ajuste VNC ports, it is possible to get ports dinamicly saving packer log to a file and parsing, but for now put VNC_PORT_FIXED=5900 on .env and it will work. As soon as VNC server open port vncviewer will run and it. If you connect to ssh using X11 port forwarding, it should open console on your local desktop. Windows WSL2 offer X11 Server native and it works. 
* in headless/remote ssh, before make build you need to start Xvfb. ```make x11server``` start X11 server, but you can put on init with something like https://gist.github.com/jterrace/2911875
* for SSH access put in .env SLEEP_BEFORE_SHUTDOWN=600 to keep SSH on for 10 minutes after scripts run. Also put HOST_PORT_FIXED=2222 for open SSH in VM 127.0.0.1 in port 2222. ```ssh vyos@127.0.0.1 -p 2222``` default password is vyos.

# Install

## Usage
* local.pkrvars.hcl if exists or will use default vars vyos.pkrvars.hcl if local not exists
* if .env exists will load
    * example.env is provided in git repo as base of .env. .env file has building vars, which control building process


## Initialize packer
Packer need to load plugins first.

Use:
* ```make init```, for first time init
* ```make upgrade```, when want to upgrade plugins

## Build
* ```make build```, for build images
