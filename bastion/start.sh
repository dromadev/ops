#!/bin/bash

echo " supression des conteneurs existants "
docker rm -f   centos1 centos2 centos3
echo " supression des ficihers cles ssh existantes "
rm ./id_rsa
echo "Create new container : Debian" "green" "blue"
docker run --name centos1 --hostname centos1 -d -v /etc/localtime:/etc/localtime:ro dromadev/centos-host
docker run --name centos2 --hostname centos2 -d -v /etc/localtime:/etc/localtime:ro dromadev/centos-host
docker run --name centos3 --hostname centos3 -d -v /etc/localtime:/etc/localtime:ro dromadev/centos-host

echo "Creation nouvelle cle RSA ssh " 
ssh-keygen -t rsa -b 4096 -C "$(whoami)@$(hostname)-$(date)" -f ./id_rsa -q -N ""
echo "Copie de la cle  ssh key sur chaque conteneur -- password est  dromadev " 
docker ps --format "{{.Names}}" | grep "centos" | xargs -i docker inspect -f "{{ .NetworkSettings.IPAddress }}" {} | xargs -i ssh-copy-id -i ./id_rsa root@{}
echo "Creation du fichier inventaire Ansible " 
echo [cobayes] > hosts
docker ps --format "{{.Names}}" | grep "cobaye" | xargs -i docker inspect -f "{{ .NetworkSettings.IPAddress }}" {} | xargs -i echo {} ansible_user=root >> hosts
docker run -it --rm -v `pwd`/hosts:/etc/ansible/hosts -v `pwd`/id_rsa:/root/.ssh/id_rsa chaibim/centos-bastion all -m ping
