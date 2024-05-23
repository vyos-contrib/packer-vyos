#!/bin/bash

set -e
set -x

if [[ "${CLOUD_INIT}" == "debian" ||  "${CLOUD_INIT}" == "vyos" ]]; then
    if [[ "${CLOUD_INIT_DATASOURCE}" == "nocloud_configdrive" ]]; then
        cat <<EOF > /etc/cloud/cloud.cfg.d/99-datasource.cfg
datasource_list: [ NoCloud, ConfigDrive ]
EOF
    else
        echo "$0 - info: cloud_init_datasource will not run, not supported cloud_init_datasource"
        exit 0
    fi
else
    echo "$0 - info: cloud_init_datasource will not run, not supported cloud_init"
fi
