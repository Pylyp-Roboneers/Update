#!/bin/bash
CLIENT_PASSWORD_213=11111111
CLIENT_PASSWORD_201=11111111
cd /home/deck/Downloads/
sudo rm SoftUpDt.7z
echo -e "====Archive SoftUpdate"
sudo 7z a SoftUpDt.7z /home/deck/Downloads/UpDt/
echo -e "====Copy SoftUpDt.7z to Server"
echo $CLIENT_PASSWORD_213 | sshpass scp -o StrictHostKeyChecking=no -P 2222 SoftUpDt.7z pi@77.222.152.213:/home/pi/theWD/
# scp -P 2222 SoftUpDt.7z pi@77.222.152.213:/home/pi/theWD/
echo -e "====Copy deployFromServer.sh to Client"
echo $CLIENT_PASSWORD_201 | sshpass scp -o StrictHostKeyChecking=no /home/deck/Downloads/deployFromServer.sh deck@192.168.144.201:/home/deck/Downloads/
# scp /home/deck/Downloads/deployFromServer.sh deck@192.168.144.201:/home/deck/Downloads/
