#!/bin/bash
if [  -z "$1" ]; then echo -e "no wireguard adress specified as first argumet.\nExit" ; exit 1; fi
CLIENT_WGADDRESS=$1
if [  -z "$2" ]; then echo -e "no client user specified as second argumet.\nExit" ; exit 1; fi
CLIENT_USER=$2
if [  -z "$3" ]; then echo -e "no client user specified as third argumet.\nExit" ; exit 1; fi
CLIENT_PASSWORD=$3
if [  -z "$4" ]; then echo -e "no server adress specified as forth argumet.\nExit" ; exit 1; fi
UserAddresSERVER=$4
if [  -z "$5" ]; then echo -e "no server password specified as fifth argumet.\nExit" ; exit 1; fi
PASSWORDtoSERVER=$5
UserAddresSERVERport=${UserAddresSERVER//"-P "/"-p "} # if there is port argument the with small -p 

echo UPDATE SOFTWARE DEPLOYMENT  Vfrom20_
# echo "pasword" | sudo -S -v  # if password to local is requered
read inet CLIENT_ADRESS rest <<< $(ifconfig | grep "inet " | grep 192)
echo ClientAddress=$CLIENT_ADRESS ClientWireguard=$CLIENT_WGADDRESS

# SERVER_ADRESS=77.222.152.213
# SERVER_USER=pi
# SERVER_PORT=2222
BeforeSERVERADRESS=" "${UserAddresSERVER%@*}
SERVER_PORTwithP=${BeforeSERVERADRESS%" "*}
SERVER_ADRESS=${UserAddresSERVER##*@} 
SERVER_PORT=${SERVER_PORTwithP##*'-P '}
SERVER_USER=${BeforeSERVERADRESS##*" "}
if [ $SERVER_PORT ];
  then SERVER_PORT_arg=" -p $SERVER_PORT"; SERVER_PORT_Arg=" -P $SERVER_PORT";
  else SERVER_PORT_arg= ; SERVER_PORT_Arg= ;
fi
echo -e "\nSoft update deplay $UserAddresSERVER"
echo -e "Detected $SERVER_USER@$SERVER_ADRESS port $SERVER_PORT;$SERVER_PORT_arg;$SERVER_PORT_Arg"

ping 8.8.8.8 -c2 > /dev/null 2>&1
if [ $? -eq 0 ]; 
    then echo -e "    There is Internet"
    else echo -e "    There is NO Internet"; exit 1
fi
ping $SERVER_ADRESS -c2 > /dev/null 2>&1
if [ $? -eq 0 ]; 
    then echo -e "    Server is connected"
    else echo -e "    Server is NOT connected"; exit 1
fi

sudo chmod -R 777 $( dirname "$0")
echo -e "\nCreating shortcut of software update appication"
if [ ! -f "/home/deck/Desktop/SoftUpdate.desktop" ]; 
    then sudo cp $( dirname "$0")/SoftUpdate.desktop /home/deck/Desktop
    else echo -e "    /home/deck/DesktopSoftUpdate.desktop already exists"
fi
sudo chmod 777 /home/deck/Desktop/SoftUpdate.desktop

echo -e "\nCreating autostart of software update appication"
autoRunSoft_Dir="/home/deck/.config/autostart"
autoRunSoft_File="autorunSoftUpdate.sh.desktop"
if [ -f "/home/deck/.config/autostart" ]; # delete file autostart if exists. The folder must by same name
    then sudo mv /home/deck/.config/autostart /home/deck/.config/autostart_; echo rename autostart file; 
fi
if [ ! -d "/home/deck/.config/autostart" ]; # create folder autostart 
    then mkdir /home/deck/.config/autostart/; sudo chmod -R 777  /home/deck/.config/autostart/;  echo create autostart folder; 
fi
if [ ! -f $autoRunSoft_Dir/$autoRunSoft_File ]; 
    then sudo cp $( dirname "$0")/$autoRunSoft_File $autoRunSoft_Dir
    else echo -e "    $autoRunSoft_Dir/$autoRunSoft_File already exists"
fi
sudo chmod 777 $autoRunSoft_Dir/$autoRunSoft_File

echo -e "\nSet sudo without password" 
sudo echo -e "%wheel ALL=(ALL:ALL) ALL\n%wheel ALL=(ALL:ALL) NOPASSWD:ALL" > /etc/sudoers.d/wheel
sudo echo -e "%sudo ALL=(ALL) ALL\nroot ALL=(ALL:ALL) ALL\n%admin ALL=(ALL) NOPASSWD:ALL\n%sudo ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/sudo

# echo -e =====cat /etc/sudoers.d/sudo
# sudo cat /etc/sudoers.d/sudo
# echo -e =====cat /etc/sudoers.d/wheel
# sudo cat /etc/sudoers.d/wheel

echo -e "\nCheck necessary software" 
resolvconf --version > /dev/null 2>&1
if [ $? -ne 0 ]; then 
        echo -e "\n\n  THERE IS NO resolvconf.\n  Installing resolvconf";
        sudo pacman -S resolvconf
        if [ $? -ne 0 ]; 
            then echo -e "\n  Install of resolvconf is fault.";
            else echo -e "\n  resolvconf is INSTALLED.";
        fi
    else echo "    There is resolvconf"
fi

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
        sudo pacman -S  net-tools
        if [ $? -ne 0 ]; 
            then echo -e "\n  Install of WireGuard is fault.";
            else echo -e "\n  WireGuard is INSTALLED.";
        fi
    else echo "    There is WireGuard"
fi

# echo -e "Check whether wireguard addresses $CLIENT_WGADDRESS is used (find in wg0.conf)"
# echo $PASSWORDtoSERVER | sshpass ssh $SERVER_PORT_arg $SERVER_USER@$SERVER_ADRESS \
#     "sudo grep -rn '/etc/wireguard/wg0.conf' -e $CLIENT_WGADDRESS"
# if [ $? -eq 0 ]; 
#   # then echo -e "\nTHE wireguard adressed $CLIENT_WGADDRESS IS ALREADY USED. \nExit."; exit 0;
#   then echo -e "\nTHE WIREGUARD ADRESS $CLIENT_WGADDRESS IS ALREADY USED in server wg0.conf.\nEXIT"; exit 0;
#   else echo -e "    Wireguard adressed $CLIENT_WGADDRESS is new"
# fi

echo -e "\nESTABLISHING of Wiareguard Connection"
sudo wg-quick down wg0
sudo systemctl stop wg-quick@wg0

echo -e "\nWireGuard Key generation."
if [ -d "/etc/wireguard/" ]; 
  then echo -e "==Folder /etc/wireguard/ exists."
  else echo -e "==Folder /etc/wireguard/ does NOT exist. Exit"; exit 1
fi
cd /etc/wireguard/
wg genkey | tee privatekey | wg pubkey > publickey
PUBLIC_WG_KEY=$(head -n 1 /etc/wireguard/publickey)
PRIVATE_WG_KEY=$(head -n 1 /etc/wireguard/privatekey)
echo "private WG key: $PRIVATE_WG_KEY"
echo "public  WG key: $PUBLIC_WG_KEY"

echo -e "\nWireGuard Config-files generation."
echo -e "[Interface]
PrivateKey = $PRIVATE_WG_KEY
Address = $CLIENT_WGADDRESS/24
DNS = 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = GJ48LQPF+/s0VQM2PUySoLHFITcjtM+FQuKxjSQl7Ho=
PresharedKey = xLqx1ng4N+iRXl7GFkuFe18oZ368LnZthbcKbtN3vOA=
Endpoint = 77.222.152.213:51520
AllowedIPs = 10.168.103.0/24
PersistentKeepalive = 25
" > wg0.conf

echo -e "### begin steamdeck via auto deploy $(date) ###
[Peer]
PublicKey = $PUBLIC_WG_KEY
PresharedKey = xLqx1ng4N+iRXl7GFkuFe18oZ368LnZthbcKbtN3vOA=
AllowedIPs = $CLIENT_WGADDRESS/32
### end steamdeck ###
" > includeToServer_wg0_conf.txt

echo ====/etc/wireguard/wg0.conf====
cat wg0.conf
echo ====/etc/wireguard/includeToServer_wg0_conf.txt====
cat includeToServer_wg0_conf.txt

sudo wg-quick up wg0
sudo wg-quick down wg0
sudo systemctl enable wg-quick@wg0.service

sudo systemctl start wg-quick@wg0
sudo systemctl reload wg-quick@wg0

echo -e "\n Copy includeToServer_wg0_conf to Server"
echo $PASSWORDtoSERVER | sshpass scp $SERVER_PORT_Arg /etc/wireguard/includeToServer_wg0_conf.txt $SERVER_USER@$SERVER_ADRESS:/home/pi/Downloads/
if [ $? -ne 0 ]; then # if wrong password to server PASSWORDtoSERVER
    echo -e "    Wrong password to server"
    scp $SERVER_PORT_Arg /etc/wireguard/includeToServer_wg0_conf.txt $SERVER_USER@$SERVER_ADRESS:/home/pi/Downloads/
fi
# scp $SERVER_PORT_Arg /etc/wireguard/includeToServer_wg0_conf.txt $SERVER_USER@$SERVER_ADRESS:/home/pi/Downloads/

echo -e "\n Deploy wireguard and ssh $CLIENT_USER@$CLIENT_WGADDRESS connections from Server to stimdeck"
echo $PASSWORDtoSERVER | sshpass ssh $SERVER_PORT_arg $SERVER_USER@$SERVER_ADRESS "sudo /home/pi/deploy $CLIENT_WGADDRESS $CLIENT_USER $CLIENT_PASSWORD"
if [ $? -ne 0 ]; then # if wrong password to server PASSWORDtoSERVER
    echo -e "    Wrong password to server"
    ssh $SERVER_PORT_arg $SERVER_USER@$SERVER_ADRESS "sudo /home/pi/deploy $CLIENT_WGADDRESS $CLIENT_USER $CLIENT_PASSWORD"
fi

echo End
exit 0
