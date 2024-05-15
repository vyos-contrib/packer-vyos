#!/bin/bash

set -e
set -x

if [[ "${GRUB_SERIAL}" -ne 1 ]]; then
    echo "$0 - info: grub will keep default=0 (kvm). to use serial add to .env: GRUB_SERIAL=1"
    exit 0
fi

GRUB_CFG="/boot/grub/grub.cfg"
GRUB_DEFAULT="/etc/default/grub"

sed -i 's/^set default=.*/set default=1/' $GRUB_CFG
sed -i 's/^set default=.*/set default=1/' $GRUB_DEFAULT
