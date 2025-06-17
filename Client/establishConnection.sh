#!/bin/bash
REMOTE_ADDRESS=192.168.144.21
REMOTE_WGADDRESS=10.168.103.7
if [ "$1" ]; then REMOTE_ADDRESS=$1; fi

CWD=$( dirname "$0")  # path to this script
echo "11111111" | sudo -S -v  # if password to local is requered
echo -e "\nEstablishing of Wiareguard Connection"

echo -e "\nCheck wireguard existance."
wg --version
if [ $? -ne 0 ];
    then echo -e "==There is no WireGuard.\nExit"; exit 1;
    else echo "==WireGuard available"
fi
if [ -d "/etc/wireguard/" ]; 
  then echo -e "==Folder /etc/wireguard/ exists."
  else echo -e "==Folder /etc/wireguard/ does NOT exist. Exit"; exit 1
fi

echo -e "\nWireGuard Key generation."
cd /etc/wireguard/
wg genkey | tee privatekey | wg pubkey > publickey
PUBLIC_WG_KEY=$(head -n 1 /etc/wireguard/publickey)
PRIVATE_WG_KEY=$(head -n 1 /etc/wireguard/privatekey)
echo "private WG key: $PRIVATE_WG_KEY"
echo "public  WG key: $PUBLIC_WG_KEY"

echo -e "\nWireGuard Config-files generation."
echo -e "[Interface]
PrivateKey = $PRIVATE_WG_KEY
Address = $REMOTE_WGADDRESS/24
DNS = 8.8.8.8, 8.8.4.4

[Peer]
PublicKey = GJ48LQPF+/s0VQM2PUySoLHFITcjtM+FQuKxjSQl7Ho=
PresharedKey = xLqx1ng4N+iRXl7GFkuFe18oZ368LnZthbcKbtN3vOA=
Endpoint = 77.222.152.213:51520
AllowedIPs = 10.168.103.0/24
PersistentKeepalive = 25
" > wg0.conf

PUBLIC_WG_KEY=$(head -n 1 /etc/wireguard/publickey)

echo -e "### begin steamdeck ###
[Peer]
PublicKey = $PUBLIC_WG_KEY
PresharedKey = xLqx1ng4N+iRXl7GFkuFe18oZ368LnZthbcKbtN3vOA=
AllowedIPs = $REMOTE_WGADDRESS/32
### end steamdeck ###
" > includeToServer_wg0_conf.txt

echo ====/etc/wireguard/wg0.conf====
cat wg0.conf
echo ====/etc/wireguard/includeToServer_wg0_conf.txt====
cat includeToServer_wg0_conf.txt

sudo wg-quick up wg0
sudo wg-quick down wg0
sudo systemctl enable wg-quick@wg0.service

echo End

exit 0