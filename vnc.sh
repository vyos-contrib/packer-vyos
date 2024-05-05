#!/bin/bash

#export DISPLAY=:99

while ! nc -z 127.0.0.1 5904; do   
  sleep 1
  echo "waiting for vnc..."
done
echo "vnc on."

vncviewer -shared 127.0.0.1:5904
