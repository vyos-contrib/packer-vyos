
# vars:
# - .env                  building vars: control building process
# - vyos.pkrvars.hcl      image vars: define image parameters - git default
# - local.pkrvars.hcl     image vars: define image parameters - clone vyos.pkrvars.hcl to override it locally



ssh_username        = "vyos"
ssh_password        = "vyos"

# same as file name without .iso
vm_name             = "vyos-1.4.0-epa3-amd64"

# platform = "none" # will not install any specific platform
# - qemu will install qemu-guest-agent
platform            = "qemu"

# cloud-init values:
# debian - will install/replace cloud-init packages 
# vyos - will keep cloud-init packages from vyos
# comment - don't install cloud-init at all
cloud_init          = "debian"

# which kind of datasource should be used
# nocloud_configdrive => use this as default, will turn on NoCloud, ConfigDrive on cloud-init datasource_list
# blank - don't set default datasource_list
cloud_init_datasource = "nocloud_configdrive"

# Set grub_serial=1 to turn grub default=1, ie: use serial console. it is need to adjust on hypervisor
# 
# for proxmox:
#   qm set 9000 --serial0 socket --vga serial0
grub_serial         = 0

# equuleus:   debian 11 (branch 1.3.*)
# sagitta:    debian 12 (branch 1.4.*)
# circinus:   debian 12 (branch 1.5.*)
# current:    debian 12 (branch 1.5.*)
vyos_release        = "sagitta"

# false will start vnc for console
headless            = false

# in MB (10GB x 1024 = 10240, minimum 2048)
disk_size           = 2048



# todo:
# - disable/enable ssh 
# - disable/enable dhcp
# - set interface/gateway 
# - keep vyos/vyos user/password or customize it
# - customize to install any other agent or package as needed like
# extra_packages      = []