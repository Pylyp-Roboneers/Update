#!/bin/bash
echo -e "Deploy softUpdate Vfrom102III"
# sudo ./deployFromServer.sh 10.168.103.76 deck 11111111 "-P 2222 pi@77.222.152.213" 11111111
# if server port is specified then the argument MUST be with capital " -P "

if [  -z "$1" ]; then echo -e "no wireguard adress is specified as first argument.\nExit" ; exit 1; fi
CLIENT_WGADDRESS=$1
if [  -z "$2" ]; then echo -e "no client user is specified as second argument.\nExit" ; exit 1; fi
CLIENT_USER=$2
if [  -z "$3" ]; then echo -e "no client password is specified as third argument.\nExit" ; exit 1; fi
CLIENT_PASSWORD=$3
if [  -z "$4" ]; then echo -e "no server user@adress is specified as forth argument.\nExit" ; exit 1; fi
UserAddresSERVER=$4
if [  -z "$5" ]; then echo -e "no server password is specified as fifth argument.\nExit" ; exit 1; fi
PASSWORDtoSERVER=$5

# parsing of UserAddresSERVER (forth) argument to separate IP adress, user name, and port
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

echo -e "\nSet sudo without password" 
sudo echo -e "%wheel ALL=(ALL:ALL) ALL\n%wheel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/wheel
sudo echo -e "%sudo ALL=(ALL) ALL\nroot ALL=(ALL:ALL) ALL\n%admin ALL=(ALL) NOPASSWD:ALL\n%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo

echo -e "\nCheck necessary software" 
ifconfig > /dev/null 2>&1
if [ $? -ne 0 ]; then 
        echo -e "\n\n  THERE IS NO net-tools.\n  Installing  net-tools";
        sudo pacman -S  net-tools
        if [ $? -ne 0 ]; 
            then echo -e "\n  Install of net-tools is fault.";
            else echo -e "\n  net-tools is INSTALLED.";
        fi
    else echo "    There is net-tools"
fi
sshpass -V >  /dev/null 2>&1
if [ $? -ne 0 ]; then 
        echo -e "\n\n  THERE IS NO sshpass.\n  Installing  net-tools";
        sudo pacman -S  sshpass
        if [ $? -ne 0 ]; 
            then echo -e "\n  Install of sshpass is fault.";
            else echo -e "\n  sshpass is INSTALLED.";
        fi
    else echo "    There is sshpass"
fi
wg --version > /dev/null 2>&1
if [ $? -ne 0 ]; then 
        echo -e "\n\n  THERE IS NO WireGuard.\n  Installing  WireGuard";
        sudo pacman -S  wg
        if [ $? -ne 0 ]; 
            then echo -e "\n  Install of WireGuard is fault.";
            else echo -e "\n  WireGuard is INSTALLED.";
        fi
    else echo "    There is WireGuard"
fi
resolvconf --version > /dev/null 2>&1
if [ $? -ne 0 ]; then 
        echo -e "\n\n  THERE IS NO resolvconf.\n  Installing resolvconf";
        sudo pacman -S resolvconf
        resolvconf --version
        if [ $? -ne 0 ]; 
            then echo -e "\n  Install of resolvconf is fault.";
            else echo -e "\n  resolvconf is INSTALLED.";
        fi
        sudo reboot
    else echo "    There is resolvconf"
fi

# Check server password validity
echo -e "Check passwort to server $UserAddresSERVERport"
res=$(echo $PASSWORDtoSERVER | sshpass ssh $UserAddresSERVERport "echo 1")
if [ $res='1' ]; then echo "    password valid"; else echo -e "SERVER PASSWORD is NOT VALID.\nEXIT"; exit 0; fi

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
