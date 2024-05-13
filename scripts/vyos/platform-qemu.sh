#!/bin/bash

set -e
set -x

if [[ "${PLATFORM}" != "qemu" ]]; then
    echo "$0 - info: platform not qemu, skipping"
    exit 0
fi

export DEBIAN_FRONTEND=noninteractive
apt install -y \
    qemu-guest-agent
