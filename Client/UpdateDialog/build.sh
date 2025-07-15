#!/bin/bash
# WrckDir=$( dirname "$0")
WrckDir=$( cd $(dirname "$0") && pwd -P)
echo -e " Build in $WrckDir"
steamIP="deck@192.168.144.205"
cd $WrckDir

# cd /home/deck/Downloads/1/UpdateDialog
rm -r build 
mkdir build && cd build
cmake ..
make
# sudo pkill -f "SoftUpdate"
echo copy to /home/pylypvolodin/WorkDir/SoftUpdate/UpDt
sudo cp $WrckDir/build/SoftUpdate /home/pylypvolodin/WorkDir/SoftUpdate/UpDt
echo copy to $steamIP
echo "11111111" | scp $WrckDir/build/SoftUpdate $steamIP:/home/deck/Downloads/UpDt/
# sudo scp $WrckDir/build/SoftUpdate $steamIP:/home/deck/Downloads/UpDt/
# cd $WrckDir
# cd ..
sudo chmod -R 777 /home/pylypvolodin/WorkDir/

