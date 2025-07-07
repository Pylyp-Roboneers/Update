#!/bin/bash
echo -e "Deploy softUpdate Vfrom20"
# sudo ./deployFromServer.sh 10.168.103.76 deck 11111111 "-P 2222 pi@77.222.152.213" 11111111

if [  -z "$1" ]; then echo -e "no wireguard adress is specified as first argumet.\nExit" ; exit 1; fi
CLIENT_WGADDRESS=$1
if [  -z "$2" ]; then echo -e "no client user is specified as second argumet.\nExit" ; exit 1; fi
CLIENT_USER=$2
if [  -z "$3" ]; then echo -e "no client password is specified as third argumet.\nExit" ; exit 1; fi
CLIENT_PASSWORD=$3
if [  -z "$4" ]; then echo -e "no server user@adress is specified as forth argumet.\nExit" ; exit 1; fi
UserAddresSERVER=$4
if [  -z "$5" ]; then echo -e "no server password is specified as fifth argumet.\nExit" ; exit 1; fi
PASSWORDtoSERVER=$5
UserAddresSERVERport=${UserAddresSERVER//"-P "/"-p "} # if there is port argument then argument for ssh with small -p 
SERVER_ADRESS=${UserAddresSERVER##*@}  # extract server IP address from forth argument
echo Server :$SERVER_ADRESS, $UserAddresSERVERport, $UserAddresSERVER.

# Check Internet connection
ping 8.8.8.8 -c2 > /dev/null 2>&1
if [ $? -eq 0 ]; 
    then echo -e "    There is Internet"
    else echo -e "    There is NO Internet"; exit 1
fi
# Check connection to Server
ping $SERVER_ADRESS -c2 > /dev/null 2>&1
if [ $? -eq 0 ]; 
    then echo -e "    Server is connected"
    else echo -e "    Server is NOT connected"; exit 1
fi
# Check program sshpass for automatic password imployment
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
# Check server password validity
echo -e "Check passwort to server $UserAddresSERVERport"
res=$(echo $PASSWORDtoSERVER | sshpass ssh $UserAddresSERVERport "echo 1")
if [ $res -eq 1 ]; then echo "    password valid"; else echo -e "SERVER PASSWORD is NOT VALID.\nEXIT"; exit 0; fi

echo -e "Check whether wireguard addresses $CLIENT_WGADDRESS is used (find in $UserAddresSERVERport:wg0.conf)"
echo $PASSWORDtoSERVER | sshpass ssh $UserAddresSERVERport \
    "sudo grep -rn '/etc/wireguard/wg0.conf' -e $CLIENT_WGADDRESS"
if [ $? -eq 0 ]; 
  then echo -e "\nTHE WIREGUARD ADRESS $CLIENT_WGADDRESS IS ALREADY USED in server wg0.conf.\nEXIT"; exit 0;
  else echo -e "    Wireguard adressed $CLIENT_WGADDRESS is new"
fi

CWD=$( dirname "$0")  # path to this script
echo -e "COPY archive file with update software from Server"
echo $PASSWORDtoSERVER | sshpass scp -o StrictHostKeyChecking=no $UserAddresSERVER:/home/pi/theWD/SoftUpDt.7z $CWD/
if [ $? -ne 0 ]; then # if wrong password to server PASSWORDtoSERVER
    echo -e "    Wrong password to server"
    scp $UserAddresSERVER:/home/pi/theWD/SoftUpDt.7z $CWD/
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
sudo $CWD/UpDt/0_SoftUpdate/SoftUpdateDeploy.sh $CLIENT_WGADDRESS $CLIENT_USER $CLIENT_PASSWORD "$UserAddresSERVER" $PASSWORDtoSERVER
