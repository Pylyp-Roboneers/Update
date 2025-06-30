#!/bin/bash
echo "SSH connection"
#REMOTE_ADDRESS=deck@10.168.103.8
#keyFile=keyToClnt08
if [  -z "$1" ]; then echo -e "no remote user and wireguard address are specified as first argumet.\nExit" ; exit 1; fi
REMOTE_ADDRESS=$1
if [  -z "$2" ]; then echo -e "no ssh key name is specified as first argumet.\nExit" ; exit 1; fi
keyFile=$2

# Generate ssh key pair
cd /home/pi/.ssh/
ssh-keygen -f $keyFile -N ""
if [ $? -ne 0 ]; 
  then echo ssh key pair genaration is fault. Exit; exit 1  
  else echo ssh key pair is genarated
fi
sudo chmod 600 $keyFile 
sudo chmod 600 $keyFile.pub 
sudo chown pi:pi $keyFile
sudo chown pi:pi $keyFile.pub

ls -l

# install ssh key on remote
ssh-copy-id -o StrictHostKeyChecking=no -i $keyFile.pub $REMOTE_ADDRESS
