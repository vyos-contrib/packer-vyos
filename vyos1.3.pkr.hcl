
packer {
  required_plugins {
    ansible = {
      version = "~> 1"
      source = "github.com/hashicorp/ansible"
    }
  }
}


variable "vm_name" {
  default = "vyos-1.3.6.img"
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


variable "iso_url" {
  default = "vyos-1.3.6-amd64.iso"
}

variable "iso_filename" {
  default = "vyos-1.3.6-amd64.iso"
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

locals {
  iso_path        = "iso/${var.iso_filename}"
  timestamp_dir  = "output-vyos-${regex_replace(timestamp(), "[: ]", "-")}"
}

source "qemu" "vyos" {

  boot_command = [
    "<enter>",
    "<wait60s>",
    "${var.ssh_username}<enter><wait>",
    "${var.ssh_password}<enter><wait>",
    "configure<enter><wait>",
    #"set interfaces ethernet eth0 address '10.210.240.9/24'<enter><wait>",
    #"set protocols static route 0.0.0.0/0 next-hop '10.10.10.1'<enter><wait>",
    "set interfaces ethernet eth0 address 'dhcp'<enter><wait>",
    "set system name-server '8.8.8.8'<enter><wait>",
    "set service ssh port '22'<enter><wait>",
    "commit<enter><wait>",
    "save<enter><wait>",
    "exit<enter><wait>",
    "install image<enter><wait3s>",
    "Yes<enter><wait>",
    "Auto<enter><wait>",
    "<enter><wait>", # vda
    "Yes<enter><wait5s>",
    "<enter><wait15s>", #disk size
    "${var.vm_name}<enter><wait10s>",
    "<enter><wait2s>",
    "${var.ssh_password}<enter><wait>",
    "${var.ssh_password}<enter><wait>",
    "<enter><wait10s>", #vda
    #"shutdown -h now<enter>"
  ]
  #boot_wait         = "3s"

  vm_name           = var.vm_name
  format            = "qcow2"

  accelerator       = "kvm"

  iso_checksum      = var.iso_checksum
  iso_url           = fileexists(local.iso_path) ? local.iso_path : var.iso_url

  boot_wait         = var.boot_wait

  http_directory    = "http"
  
  shutdown_command  = "shutdown -P now"

  communicator      = "ssh"

  #ssh_host          = "10.18.0.37"
  #ssh_port          = 3333
  #ssh_host_port_min = 2222
  #ssh_host_port_max = 2222
  #ssh_skip_nat_mapping = true

  ssh_username      = var.ssh_username
  ssh_password      = var.ssh_password

  ssh_timeout       = "30m"
  #use_sudo          = false
  #pause_before      = "30s"
 
  memory            = var.memsize
  cpus              = var.numvcpus

  vnc_port_min      = 5904
  vnc_port_max      = 5904  
  headless          = false

  #guest_os_type     = "Debian_64"

  output_directory = "output-vyos-${local.timestamp_dir}"

  net_device        = "virtio-net"
  disk_interface    = "virtio"
  disk_size         = var.disk_size

  qemuargs = [
    ["-m", "2048"],
    ["-smp", "4"],
    ["-cpu", "host"],
    #["-netdev", "user,id=user.0,hostfwd=tcp:10.18.0.37:2222-10.10.10.2:22"],
    #["-netdev", "user,id=user.0,hostfwd=tcp::2222-:22"], 
    #["-netdev", "bridge,id=br0,br=br0"],
    #["-netdev", "user,id=user.0"], 
    #["-device", "virtio-net,netdev=user.0"],    

    ["-netdev", "user,id=user.0,",
        "hostfwd=tcp::{{ .SSHHostPort }}-:22,",
        "net=10.210.240.0/24,",
        "dhcpstart=10.210.240.9",
        ""
      ],
    ["-device", "virtio-net,netdev=user.0"]    

  ]  
}


build {
  sources = [
    "source.qemu.vyos"
  ]

  provisioner "shell-local" {
      inline     = [
        "mkdir -p ${local.timestamp_dir}"
      ]
      #only        = ["qemu.vyos"]
  }
    
#   provisioner "shell" {
#     execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"


#     # connection {
#     #   type     = "ssh"
#     #   user     = "vyos"
#     #   password = "vyos"
#     #   host     = "127.0.0.1"
#     #   port     = 2222
#     # }

#     inline = [
#       "sleep 1000"
#       #"sudo apt update",
#       #"apt install -y nginx"
#     ]
#   }

#   provisioner "shell" {
#     execute_command = "sh -c '{{ .Vars }} {{ .Path }}'"

#     inline = [
#       #"apt -y update && apt -y upgrade",
#       #"sudo apt -y install python3-pip",
#       "sleep 10000"
#       #"pip3 --no-cache-dir install ansible"
#     ]
#   }
}

#   provisioner "ansible-local" {
#     playbook_file = "scripts/setup.yml"
#   }

#   provisioner "shell" {
#     execute_command = "echo '${var.ssh_password}'|{{.Vars}} sudo -S -E bash '{{.Path}}'"
#     scripts = ["scripts/cleanup.sh"]
#   }
