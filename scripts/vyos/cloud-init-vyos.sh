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

cat <<EOF > /etc/cloud/cloud.cfg.d/99-disable_network_config.cfg
network: {config: disabled}
EOF

cat <<EOF > /etc/cloud/cloud.cfg.d/90-disable_config_stage.cfg
# Disable all config-stage modules
cloud_config_modules:
EOF

rm -rf /etc/network/interfaces.d/50-cloud-init || :
