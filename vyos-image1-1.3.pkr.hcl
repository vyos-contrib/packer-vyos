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
  default = "vyos-1.3.6"
}

variable "numvcpus" {
  default = "4"
}

variable "memsize" {
  default = "2048"
}

variable "disk_size" {
  default = "10240"
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
  default = "equuleus"
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
  default = "60" # in seconds
}

# set grub_serial=1 to turn grub default=1, ie: use serial console. it is need to adjust on hypervisor
variable "grub_serial" {
  type        = string
  default     = 1
}

locals {
  iso_path        = "iso/${var.vm_name}.iso"
  output_dir      = "output/vyos-image1/${regex_replace(timestamp(), "[: ]", "-")}"
}

source "qemu" "vyos" {
  boot_command = [
    "<enter>",
    "<wait${var.sleep_after_grub}s>", 
    "${var.ssh_username}<enter><wait>",
    "${var.ssh_password}<enter><wait>",
    "configure<enter><wait>",
    "set interfaces ethernet eth0 address 'dhcp'<enter><wait>",
    "set system name-server '8.8.8.8'<enter><wait>",
    "set service ssh port '22'<enter><wait>",
    "commit<enter><wait>",
    "save<enter><wait>",
    "exit<enter><wait>",
    "install image<enter><wait3s>",
    "Yes<enter><wait3s>",
    "Auto<enter><wait3s>",
    "<enter><wait3s>", # vda
    "Yes<enter><wait5s>",
    "<enter><wait15s>", #disk size
    "${var.vm_name}<enter><wait10s>",
    "<enter><wait2s>",
    "${var.ssh_password}<enter><wait>",
    "${var.ssh_password}<enter><wait>",
    "<enter><wait10s>",  # wait 10 seconds before reboot (dev purposes)
  ]

  accelerator       = "kvm"

  iso_checksum      = var.iso_checksum
  iso_url           = local.iso_path

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
    ["-device", "virtio-net,netdev=user.0"]
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
      "mkdir -p iso/",
      "mkdir -p ${local.output_dir}"
    ]
  }

  # checksum
  post-processors {
    post-processor "checksum" {
      checksum_types = ["sha256"]
      keep_input_artifact = true
    }

    post-processor "shell-local" { 
      inline = [
        "mv packer_vyos_qemu_sha256.checksum iso/${var.vm_name}-build1.qcow2.checksum.tmp",
        "awk '{print $1, \" ${var.vm_name}-build1.qcow2\"}' iso/${var.vm_name}-build1.qcow2.checksum.tmp > iso/${var.vm_name}-build1.qcow2.checksum",
        "rm -f iso/${var.vm_name}-build1.qcow2.checksum.tmp",
        "cat iso/*.checksum > iso/SHA256SUM",
        "echo '${var.vm_name}' > .vm_name"
      ]
    }
  }

  # copy from output to iso/ for vyos-image2.pkr.hcl customize
  post-processors {
    post-processor "shell-local" { 
      inline = [
        "cp '${local.output_dir}/${var.vm_name}-${source.name}.qcow2' iso/${var.vm_name}-build1.qcow2",
        "rm -rf '${local.output_dir}'"
      ]
    }  
  }
}
