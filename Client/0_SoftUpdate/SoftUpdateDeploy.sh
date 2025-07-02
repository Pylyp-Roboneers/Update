#!/bin/bash
if [  -z "$1" ]; then echo -e "no wireguard adress specified as first argumet.\nExit" ; exit 1; fi
CLIENT_WGADDRESS=$1
if [  -z "$2" ]; then echo -e "no client user specified as first argumet.\nExit" ; exit 1; fi
CLIENT_USER=$2
if [  -z "$3" ]; then echo -e "no client password specified as third argumet.\nExit" ; exit 1; fi
CLIENT_PASSWORD=$3

echo UPDATE SOFTWARE DEPLOYMENT
# echo "11111111" | sudo -S -v  # if password to local is requered
read inet CLIENT_ADRESS rest <<< $(ifconfig | grep "inet " | grep 192)
echo ClientAddress=$CLIENT_ADRESS ClientWireguard=$CLIENT_WGADDRESS

SERVER_ADRESS=77.222.152.213
SERVER_USER=pi
SERVER_PORT=2222
if [ $SERVER_PORT ];
  then SERVER_PORT_arg=" -p $SERVER_PORT"; SERVER_PORT_Arg=" -P $SERVER_PORT";
  else SERVER_PORT_arg= ; SERVER_PORT_Arg= ;
fi

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

echo -e "Reload wireguard on steamdeck"
sudo wg-quick up wg0
sudo wg-quick down wg0
sudo systemctl enable wg-quick@wg0.service

sudo systemctl start wg-quick@wg0
sudo systemctl reload wg-quick@wg0

echo -e "\n Copy includeToServer_wg0_conf to Server"
scp $SERVER_PORT_Arg /etc/wireguard/includeToServer_wg0_conf.txt $SERVER_USER@$SERVER_ADRESS:/home/pi/Downloads/
echo -e "\n Deploy wireguard and ssh $CLIENT_USER@$CLIENT_WGADDRESS connections from Server to stimdeck"
ssh $SERVER_PORT_arg $SERVER_USER@$SERVER_ADRESS "sudo /home/pi/deploy $CLIENT_WGADDRESS $CLIENT_USER $CLIENT_PASSWORD"

echo End
exit 0
