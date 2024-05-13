#!/usr/bin/python

import pexpect
import time
import sys
import os

var_vm_name = os.getenv("VM_NAME", "vyos")
var_ssh_password = os.getenv("VM_PASSWORD", "vyos")

install_process = pexpect.spawn("/opt/vyatta/sbin/install-image", logfile=sys.stdout, encoding='utf-8')

install_process.expect("Would you like to continue")
time.sleep(0.2)
install_process.sendline("Yes")

install_process.expect("Partition")
time.sleep(0.2)
install_process.sendline("Auto")

install_process.expect("Install the image on")
time.sleep(0.2)
install_process.sendline("")

install_process.expect("Continue")
time.sleep(0.2)
install_process.sendline("Yes")

install_process.expect("How big of a root partition should I create")
time.sleep(0.2)
install_process.sendline("")

install_process.expect("What would you like to name this image")
time.sleep(0.2)
install_process.sendline(var_vm_name)

install_process.expect("Which one should I copy to")
time.sleep(0.2)
install_process.sendline("")

install_process.expect("Enter password for user")
time.sleep(0.2)
install_process.sendline(var_ssh_password)

install_process.expect("Retype password for user")
time.sleep(0.2)
install_process.sendline(var_ssh_password)

install_process.expect("Which drive should GRUB modify the boot partition on")
time.sleep(0.2)
install_process.sendline("")

# wait until process ends
install_process.wait()

