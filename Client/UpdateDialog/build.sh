#!/bin/bash
WrckDir=$( dirname "$0")
steamIP="deck@192.168.144.201"
cd $WrckDir
# cd /home/deck/Downloads/1/UpdateDialog
rm -r build 
mkdir build && cd build
cmake ..
make
# sudo pkill -f "SoftUpdate"
cd ..
echo copy to /home/pylypvolodin/WorkDir/SoftUpdate/UpDt
sudo cp $WrckDir/build/SoftUpdate /home/pylypvolodin/WorkDir/SoftUpdate/UpDt
echo copy to $steamIP
sudo scp $WrckDir/build/SoftUpdate $steamIP:/home/deck/Downloads/UpDt/
cd $WrckDir
cd ..
sudo chmod -R 777 /home/pylypvolodin/WorkDir/

