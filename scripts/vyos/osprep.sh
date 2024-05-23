#!/bin/bash

set -e
set -x

# vimrc no mouse
cat <<EOF > /home/vyos/.vimrc
set mouse=
EOF

cat <<EOF > /root/.vimrc
set mouse=
EOF

