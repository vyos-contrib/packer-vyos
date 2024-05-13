

# platform = "none" # will not install any specific platform
# - qemu will install qemu-guest-agent
platform            = "qemu"

# cloud-init values:
# debian - will install/replace cloud-init packages 
# vyos - will keep cloud-init packages from vyos
cloud_init          = "debian"

# if true configure grub to use serial console as default
grub_serial         = true

# equuleus:   debian 11 (branch 1.3.*)
# sagitta:    debian 12 (branch 1.4.*)
# circinus:   debian 12 (branch 1.5.*)
# current:    debian 12 (branch 1.5.*)
vyos_release        = "equuleus"