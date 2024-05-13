#!/bin/bash

set -e
set -x

if [[ "${CLOUD_INIT}" != "vyos" ]]; then
    echo "$0 - info: cloud_init not vyos, skipping"
    exit 0
fi

export DEBIAN_FRONTEND=noninteractive

apt purge -y \
    cloud-init \
    cloud-utils \
    ifupdown

apt install -t "$VYOS_RELEASE" --force-yes -y \
    cloud-init \
    cloud-utils \
    ifupdown
    
systemctl enable cloud-init
