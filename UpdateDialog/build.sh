#!/bin/bash
cd /home/deck/Downloads/1/UpdateDialog
rm -r build 
mkdir build && cd build
cmake ..
make
cd 
cp /home/deck/Downloads/1/UpdateDialog/build/SoftUpdate /home/deck/Downloads/UpDt/
sudo chmod -R 777 /home/deck/Downloads/