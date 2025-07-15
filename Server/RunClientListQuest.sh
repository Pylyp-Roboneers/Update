#!/bin/bash
echo Run client quest iteration
count=0
while [ $count -lt 100 ]
  do
    sleep 10
    (( count++ )); echo -e -n "\n$count"
    sudo /home/pi/theWD/UpdateClientList.sh
  done
