#!/bin/bash
echo "SSH connection"
#REMOTE_ADDRESS=deck@10.168.103.8
#keyFile=keyToClnt08
if [  -z "$1" ]; then echo -e "no remote user and wireguard address are specified as first argumet.\nExit" ; exit 1; fi
REMOTE_ADDRESS=$1
if [  -z "$2" ]; then echo -e "no ssh key name is specified as second argumet.\nExit" ; exit 1; fi
keyFile=$2

# Generate ssh key pair
cd /home/pi/.ssh/
sudo ssh-keygen -f $keyFile -N ""
if [ $? -ne 0 ]; 
  then echo ssh key pair genaration is fault. Exit; exit 1  
  else echo ssh key pair is genarated
fi
sudo chmod 600 $keyFile 
sudo chmod 600 $keyFile.pub 
sudo chown pi:pi $keyFile
sudo chown pi:pi $keyFile.pub

ls -l

echo -e "install ssh key on remote  $REMOTE_ADDRESS $keyFile"
echo "11111111" | sshpass ssh-copy-id -o StrictHostKeyChecking=no -i /home/pi/.ssh/$keyFile $REMOTE_ADDRESS
