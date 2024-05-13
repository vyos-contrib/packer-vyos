#!/bin/bash

#export DISPLAY=:99

VNC_HOST=127.0.0.1
VNC_PORT=5900

while ! nc -z $VNC_HOST $VNC_PORT; do   
  sleep 1
  echo "waiting for vnc in $VNC_HOST:$VNC_PORT ..."
done
echo "vnc on."

vncviewer -shared $VNC_HOST:$VNC_PORT
