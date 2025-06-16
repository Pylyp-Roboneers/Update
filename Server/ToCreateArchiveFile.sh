#!/bin/bash
echo Create archive file
sudo chmod -R 777 /home/pi/theWD
cd /home/pi/theWD
rm -f update.7z
7z a update.7z UpDate/
sudo chmod 777 update.7z
