#!/bin/bash

set -e
set -x

# configure machine-id
dbus-uuidgen > /etc/machine-id
ln -fs /etc/machine-id /var/lib/dbus/machine-id

# disable logs
systemctl stop rsyslog

