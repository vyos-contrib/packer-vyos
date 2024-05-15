#!/bin/bash

set -e
set -x

# answers_url=http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}/answers.expect
# install_url=http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}/install-image.vsh
install_url=http://${PACKER_HTTP_IP}:${PACKER_HTTP_PORT}/install-image.py

# touch /root/answers.expect
# chmod 0600 /root/answers.expect
# wget $answers_url -O /root/answers.expect

touch /root/install-image.py
chmod 0700 /root/install-image.py
wget $install_url -O /root/install-image.py

python3 /root/install-image.py

