root@ds1s1$   
    Xvfb :99 -screen 0 1024x768x16
    export DISPLAY=:99
    packer build

wsl2$
    ssh ubuntu@10.18.0.37 -i keys/privateos_rsa -X -v

ubuntu@ds1s1:~$
    export DISPLAY=:99
    vncviewer -shared 127.0.0.1:5990

