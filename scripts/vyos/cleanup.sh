#!/bin/bash

set -e
set -x

export DEBIAN_FRONTEND=noninteractive

# delete interfaces ethernet eth0 address
# delete interfaces ethernet eth0 hw-id
# delete system name-server

cat <<EOF > /home/vyos/cleanup-vyos.sh
#!/bin/vbash
source /opt/vyatta/etc/functions/script-template
configure
set system host-name 'test'
commit
save
exit
EOF
chmod 0700 /home/vyos/cleanup-vyos.sh
chown vyos:users /home/vyos/cleanup-vyos.sh
su - vyos -c "/home/vyos/cleanup-vyos.sh"

# reconfiguring ssh
rm -f /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

# those packages can't be removed since they are needed for next script vyos-install.sh
# apt remove -y \
#    python3-pexpect \
#    expect

# cleanup apt
rm -f /etc/apt/sources.list.d/debian.list
apt -y autoremove --purge
apt-get clean

# cleanup machine-id
truncate -s 0 /etc/machine-id

# removing /tmp files
rm -rf /tmp/*

# removing log files
rm -rf /var/log/*

rm -rf /home/vyos/cleanup-vyos.sh

# removing history
export HISTFILE=0
rm -f /home/vyos/.bash_history
rm -f /root/.bash_history

# removing disk data
dd if=/dev/zero of=/EMPTY bs=1M || :
rm -f /EMPTY
sync
