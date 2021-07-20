#!/bin/bash

user=$1
token=$2

[ -z $user ] && { echo "Error: no mongo db username found"; exit 3; }
[ -z $token ] && { echo "Error: no mongo db token found"; exit 3; }

cd /tmp
sudo apt update
sudo apt install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io -y
sudo usermod -aG docker $USER
sudo docker build . -t mongo-api
sudo docker run --rm -d --network host --name mongo_api -e USER=$user -e TOKEN=$token mongo-api
