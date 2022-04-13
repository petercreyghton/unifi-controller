#!/bin/bash

# install multiple Unifi Controllers in Docker on a Centos(7) machine
# add Cockpit and Portainer for webconsoles
# and docker-compose for testing with the YML installer

# stop the script on all errors
set -e

# stop NetworkManager and install iptables
systemctl disable --now NetworkManager
yum install -y iptables-services
systemctl enable --now iptables-services
# DEV regel om alle verkeer inbound toe te staan - nog aanpassen voor alle benodigde poorten
iptables -I INPUT -j ACCEPT

# install docker
# https://docs.docker.com/engine/install/centos/
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce docker-ce-cli containerd.io
systemctl enable --now docker
docker run hello-world

# disable SElinux
setenforce 0
sed -i 's/enforcing/permissive/' /etc/sysconfig/selinux

# install docker-compose
# https://docs.docker.com/compose/install/
curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install Cockpit
yum install -y cockpit
systemctl enable --now cockpit

# install Portainer
# https://docs.portainer.io/v/ce-2.9/start/install/server/docker/linux
docker run -d -p 8000:8000 -p 9443:9443 --name portainer \
    --restart=always \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/portainer/data:/data \
    portainer/portainer-ce:2.9.3

# --- and finally, run as many Unifi controllers in Docker as needed on this machine
# remember to increment the host portnumbers when adding an extra controller, and map the 
# correct ports in the Sophos Firewall

# start unifi controllers
# https://hub.docker.com/r/linuxserver/unifi-controller
docker run -d \
  --name=unifi-controller01 \
  -e PUID=1000 \
  -e PGID=1000 \
  -p 8080:8080 \
  -p 8443:8443 \
  -p 8880:8880 \
  -p 8843:8843 \
  -p 6789:6789 \
  -p 3478:3478/udp \
  -p 10001:10001/udp \
  -v /var/lib/unifi/controller01:/config \
  --restart unless-stopped \
  lscr.io/linuxserver/unifi-controller:latest

docker run -d \
  --name=unifi-controller02 \
  -e PUID=1001 \
  -e PGID=1001 \
  -p 8081:8080 \
  -p 8444:8443 \
  -p 8844:8843 \
  -p 8881:8880 \
  -p 6790:6789 \
  -p 3479:3478/udp \
  -p 10002:10001/udp \
  -v /var/lib/unifi/controller02:/config \
  --restart unless-stopped \
  lscr.io/linuxserver/unifi-controller

docker run -d \
  --name=unifi-controller03 \
  -e PUID=1002 \
  -e PGID=1002 \
  -p 8082:8080 \
  -p 8445:8443 \
  -p 8845:8843 \
  -p 8882:8880 \
  -p 6791:6789 \
  -p 3480:3478/udp \
  -p 10003:10001/udp \
  -v /var/lib/unifi/controller03:/config \
  --restart unless-stopped \
  lscr.io/linuxserver/unifi-controller
