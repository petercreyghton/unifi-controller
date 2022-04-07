#!/bin/bash

# install Docker in a Centos7 machine
# add Cockpit and Portainer for webconsoles
# and docker-compose for YML installation

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

