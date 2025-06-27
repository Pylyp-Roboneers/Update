#!/bin/bash
echo "SSH connection"
REMOTE_ADDRESS=deck@10.168.103.8
keyFile=keyToClnt08

# Generate ssh key pair
cd /home/pi/.ssh/
ssh-keygen -f $keyFile -N ""
if [ $? -ne 0 ]; 
  then echo ssh key pair genaration is fault. Exit; exit 1  
  else echo ssh key pair is genarated
fi
sudo chmod 600 $keyFile 
sudo chmod 600 $keyFile.pub 
ls -l

# install ssh key on remote
ssh-copy-id -o StrictHostKeyChecking=no -i $keyFile.pub $REMOTE_ADDRESS
