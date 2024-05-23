#!/bin/bash

set -e
set -x

if [[ "${CLOUD_INIT}" != "debian" ]]; then
    echo "$0 - info: cloud_init not debian, skipping"
    exit 0
fi

export DEBIAN_FRONTEND=noninteractive

apt purge -y \
    cloud-init \
    cloud-utils \
    ifupdown

apt install -y \
    cloud-init \
    cloud-utils \
    ifupdown

systemctl enable cloud-init

cat <<EOF > /etc/cloud/cloud.cfg.d/99-disable_network_config.cfg
network: {config: disabled}
EOF

rm -rf /etc/network/interfaces.d/50-cloud-init || :
