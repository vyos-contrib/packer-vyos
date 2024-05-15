packer {
  required_plugins {
    qemu = {
      version = "~> 1"
      source  = "github.com/hashicorp/qemu"
    }
  }
}


# dont edit those vars below, customize in local.auto.pkrvars.hcl using local.example.pkrvars.hcl
variable "vm_name" {
  default = "vyos-image-1.3.6"
}

variable "numvcpus" {
  default = "4"
}

variable "memsize" {
  default = "2048"
}

variable "disk_size" {
  default = "1024"
}

variable "iso_checksum" {
  default = "file:iso/SHA256SUM"
}

variable "ssh_username" {
  default = "vyos"
}

variable "ssh_password" {
  default = "vyos"
}

variable "boot_wait" {
  default = "5s"
}

# - qemu: will build qcow2 image
# - none: not supported
variable "platform" {
  type        = string
  default     = "qemu"
}

# cloud-init values:
# debian - will install/replace cloud-init packages 
# vyos - will keep cloud-init packages from vyos
variable "cloud_init" {
  type        = string
  default     = "vyos"
}

# equuleus:   debian 11 (branch 1.3.*)
# sagitta:    debian 12 (branch 1.4.*)
# circinus:   debian 12 (branch 1.5.*)
# current:    debian 12 (branch 1.5.*)
variable "vyos_release" {
  default = "circinus"
}

# build will fail if headless is false, only use headless false if you prepared X11/vnc setup
variable "headless" {
  default = true
}

variable "host_port_min" {
  default = env("HOST_PORT_FIXED") != "" ? env("HOST_PORT_FIXED") : 2222
}
variable "host_port_max" {
  default = env("HOST_PORT_FIXED") != "" ? env("HOST_PORT_FIXED") : 4444
}

variable "vnc_port_min" {
  default = env("VNC_PORT_FIXED") != "" ? env("VNC_PORT_FIXED") : 5900
}
variable "vnc_port_max" {
  default = env("VNC_PORT_FIXED") != "" ? env("VNC_PORT_FIXED") : 6000
}

variable "sleep_before_shutdown" {
  default = env("SLEEP_BEFORE_SHUTDOWN") != "" ? env("SLEEP_BEFORE_SHUTDOWN") : 0
}

# this is actually boot time between grub and user login. Need to be increased if your system in heavy load. A wait time too long will increase build time.
variable "sleep_after_grub" {
  default = "45" # in seconds
}

# set grub_serial=1 to turn grub default=1, ie: use serial console. it is need to adjust on hypervisor
variable "grub_serial" {
  type        = string
  default     = 1
}

# which kind of datasource should be used
# nocloud_configdrive => use this as default, will turn on NoCloud, ConfigDrive on cloud-init datasource_list
# blank - don't set default datasource_list
variable "cloud_init_datasource" {
  default = "nocloud_configdrive"
}

locals {
  iso_path        = "iso/${var.vm_name}-build2.qcow2"  # not used at all since qemuargs -drive override it
  output_dir      = "output/vyos-image2/${regex_replace(timestamp(), "[: ]", "-")}"
}

source "qemu" "vyos" {
  boot_command = [
    "<wait2s><enter>",
    "<wait${var.sleep_after_grub}s>", 
    "${var.ssh_username}<enter><wait>",
    "${var.ssh_password}<enter><wait>",
    "configure<enter><wait>",
    "set interfaces ethernet eth0 address 'dhcp'<enter><wait>",
    "set system name-server '8.8.8.8'<enter><wait>",
    "set service ssh port '22'<enter><wait>",
    "commit<enter><wait>",
    "save<enter><wait>",
    "exit<enter><wait10s>", # wait 10 seconds before reboot (dev purposes)
  ]

  accelerator       = "kvm"

  iso_checksum      = var.iso_checksum
  iso_url           = local.iso_path          # not used at all since qemuargs -drive override it

  boot_wait         = var.boot_wait

  http_directory    = "http"
  
  shutdown_command  = "sleep ${var.sleep_before_shutdown}; sudo shutdown -P now"

  communicator      = "ssh"

  host_port_min     = var.host_port_min
  host_port_max     = var.host_port_max

  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password

  ssh_timeout       = "30m"
 
  memory            = var.memsize
  cpus              = var.numvcpus
  disk_size         = var.disk_size

  vnc_port_min      = var.vnc_port_min
  vnc_port_max      = var.vnc_port_max

  headless          = var.headless

  output_directory = "${local.output_dir}"
  
  net_device        = "virtio-net"
  disk_interface    = "virtio"

  qemuargs = [
    ["-m", "2048"],
    ["-smp", "4"],
    ["-cpu", "host"],
    ["-netdev",  "user,id=user.0,", "hostfwd=tcp::{{ .SSHHostPort }}-:22"],
    ["-device", "virtio-net,netdev=user.0"],
    #["-drive", "file=iso/${var.vm_name}.qcow2,if=virtio,cache=writeback,discard=ignore,format=qcow2"]
    #["-drive", "file=iso/${var.vm_name}.qcow2,if=none,id=drive-virtio0,format=qcow2,cache=writeback,aio=io_uring,detect-zeroes=on"]
    ["-drive", "file=iso/${var.vm_name}-build2.qcow2,if=virtio,cache=writeback,format=qcow2,aio=io_uring,detect-zeroes=on"]
  ]
}

build {
  name = "vyos"

  source "source.qemu.vyos" {
    name              = "vyos_qemu_qcow2"
    vm_name           = "${var.vm_name}-${source.name}.qcow2"
    format            = "qcow2"
  }

  provisioner "shell-local" {
    inline = [
      "mkdir -p ${local.output_dir}"
    ]
  }

  # preparing provisioner
  provisioner "shell" {
    execute_command = "VYOS_RELEASE='${var.vyos_release}' {{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/vyos/init.sh",
    ]
  }

  # configure vyos 
  provisioner "shell" {
    execute_command = "VYOS_RELEASE='${var.vyos_release}' {{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/vyos/configure.sh",
    ]
  }

  # installing apt repos and custom packages
  provisioner "shell" {
    execute_command = "VYOS_RELEASE='${var.vyos_release}' CLOUD_INIT='${var.cloud_init}' {{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/vyos/apt-repo-debian.sh",
      "scripts/vyos/apt-repo-vyos.sh",
      "scripts/vyos/apt-install.sh",
    ]
  }

  # preparing cloud-init
  provisioner "shell" {
    execute_command = "VYOS_RELEASE='${var.vyos_release}' CLOUD_INIT='${var.cloud_init}' CLOUD_INIT_DATASOURCE='${var.cloud_init_datasource}' {{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/vyos/cloud-init-debian.sh",
      "scripts/vyos/cloud-init-vyos.sh",
      "scripts/vyos/cloud-init-datasource.sh",
    ]
  }

  # if PLATFORM=qemu will install qemu packages
  provisioner "shell" {
    execute_command = "VYOS_RELEASE='${var.vyos_release}' PLATFORM='${var.platform}' {{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/vyos/platform-qemu.sh"
    ]
  }

  # if grub_serial=1 change grub default to serial
  provisioner "shell" {
    execute_command = "VYOS_RELEASE='${var.vyos_release}' GRUB_SERIAL='${var.grub_serial}' {{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/vyos/grub-serial.sh"
    ]
  }

  # image cleanup 
  provisioner "shell" {
    execute_command = "VYOS_RELEASE='${var.vyos_release}' {{ .Vars }} sudo -E bash '{{ .Path }}'"
    scripts = [
      "scripts/vyos/cleanup.sh",
    ]
  }

  # copy qcow2 to final destination
  post-processors {
    post-processor "shell-local" { 
      inline = [
        "cp 'iso/${var.vm_name}-build2.qcow2' iso/${var.vm_name}.img",
        "cd iso/ && sha256sum ${var.vm_name}.img > ${var.vm_name}.img.checksum && cd ../" ,
        "cat iso/*.checksum > iso/SHA256SUM",
        "rm -rf '${local.output_dir}'"
      ]
    }  
  }
}