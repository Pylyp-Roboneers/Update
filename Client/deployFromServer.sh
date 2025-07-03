#!/bin/bash
echo -e "Deploy softUpdate Vfrom20"
PASSWORDtoSERVER=11111111

if [  -z "$1" ]; then echo -e "no wireguard adress is specified as first argumet.\nExit" ; exit 1; fi
CLIENT_WGADDRESS=$1
if [  -z "$2" ]; then echo -e "no client user is specified as second argumet.\nExit" ; exit 1; fi
CLIENT_USER=$2
if [  -z "$3" ]; then echo -e "no client password is specified as third argumet.\nExit" ; exit 1; fi
CLIENT_PASSWORD=$3

sshpass -V >  /dev/null 2>&1
if [ $? -ne 0 ]; then 
        echo -e "\n\n  THERE IS NO sshpass.\n  Installing  net-tools";
        sudo pacman -S sshpass
        if [ $? -ne 0 ]; 
            then echo -e "\n  Install of sshpass is fault.";
            else echo -e "\n  sshpass is INSTALLED.";
        fi
    else echo "    There is sshpass"
fi

CWD=$( dirname "$0")  # path to this script
echo -e "COPY archive file with update software from Server"
echo $PASSWORDtoSERVER | sshpass scp -P 2222 pi@77.222.152.213:/home/pi/theWD/SoftUpDt.7z $CWD/
if [ $? -ne 0 ]; then # if wrong password to server PASSWORDtoSERVER
    echo -e "    Wrong password to server"
    scp -P 2222 pi@77.222.152.213:/home/pi/theWD/SoftUpDt.7z $CWD/
fi

echo -e "EXTRACT update software"
cd $CWD/
sudo 7z x -y $CWD/SoftUpDt.7z -o"$CWD"
if [ $? -eq 0 ]; 
    then echo -e "==Extracting of SoftUpDt.7z is complited"
    else echo -e "==Extracting of SoftUpDt.7z fault. \nExit"; exit 1 
fi
sudo -n chmod 777 -R $CWD/UpDt/
if [ -d "$CWD/UpDt/" ]; 
    then echo -e "==$CWD/UpDt/ exists." 
    else echo -e "==$CWD/UpDt/ dose not exist. \nExit"; exit 1
fi
sudo $CWD/UpDt/0_SoftUpdate/SoftUpdateDeploy.sh $CLIENT_WGADDRESS $CLIENT_USER $CLIENT_PASSWORD
