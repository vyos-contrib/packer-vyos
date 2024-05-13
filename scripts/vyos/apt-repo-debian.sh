#!/bin/bash

set -e
set -x

if [[ "${CLOUD_INIT}" != "debian" ]]; then
    echo "$0 - info: cloud_init not debian, skipping"
    exit 0
fi

# set debian list according VYOS_VERSION_MAIN
if [[ "$VYOS_RELEASE" == "equuleus" ]]; then
    debian_list_url="http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}/debian_11.list"
elif [[ "$VYOS_RELEASE" == "current" || "$VYOS_RELEASE" == "sagitta" || "$VYOS_RELEASE" == "circinus" ]]; then
    debian_list_url="http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}/debian_12.list"
else
    echo "vyos version unsupported, get github repo, fork and send a pull request"
    exit 1
fi

tmp_file=$(mktemp)

wget -O "$tmp_file" "$debian_list_url" || { echo "cant download debian.list from packer http repo"; exit 1; }

mv "$tmp_file" /etc/apt/sources.list.d/debian.list

apt update


#sudo bash -c 'echo "deb http://deb.debian.org/debian buster main contrib non-free" > /etc/apt/sources.list.d/debian.list'
#sudo bash -c 'echo "deb-src http://deb.debian.org/debian buster main contrib non-free" >> /etc/apt/sources.list.d/debian.list'
#sudo bash -c 'echo "deb http://security.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list.d/debian.list'
#sudo bash -c 'echo "deb-src http://security.debian.org/debian-security/ buster/updates main contrib non-free" >> /etc/apt/sources.list.d/debian.list'
