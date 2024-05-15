#!/bin/bash

set -e
set -x

#GRUB_SERIAL=1
if [[ "${GRUB_SERIAL}" -ne 1 ]]; then
    echo "$0 - info: grub will keep default=0 (kvm). to use serial add to .env: GRUB_SERIAL=1"
    exit 0
fi

GRUB_CFG="/boot/grub/grub.cfg"
GRUB_DEFAULT="/etc/default/grub"

sed -i 's/^set default=.*/set default=1/' $GRUB_CFG

if grep -q "^GRUB_DEFAULT=" $GRUB_DEFAULT; then
    sed -i 's/^GRUB_DEFAULT=.*/GRUB_DEFAULT=1/' $GRUB_DEFAULT
else
    echo "GRUB_DEFAULT=1" >> $GRUB_DEFAULT
fi

# update-grub


