#!/bin/sh

echo "Note, you may need to update the link for this to really work!"

sudo apt-get -y remove nxserver
sudo rm -rf /usr/NX /etc/NX

# note the link changes every week or so:
# be sure to grab the Debian amd64 package!
# http://www.nomachine.com/preview/select-package-virtual-desktop-workstation.php?os=linux

wget http://64.34.161.181/download/4.0/Linux/VDW/nxserver_vdw_4.0.132-8_amd64.deb
sudo dpkg -i nxserver_*.deb

echo "You should see the NX server (nxhtd) running in the process list below!"
ps aux | grep nx
