#!/bin/bash

set -e
set -x

export DEBIAN_FRONTEND=noninteractive

# install missing vyos features, you can comment it if not needed
apt install -y \
    vim \
    net-tools

