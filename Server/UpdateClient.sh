#!/bin/bash
CLIENT_USER=deck
CLIENT_ADRESS=10.168.103.5
CLIENT_PORT=
SSHkeyToClient=/home/pi/.ssh/keyToClnt05
CLIENT_FOLER=/home/deck/Downloads/UpDt/
SERVER_ArchiveFile=update.7z
SSH="ssh -o StrictHostKeyChecking=no"
CWD=$( dirname "$0")  # path to this script
if [ "$1" ]; then CLIENT_ADRESS=$1; fi
if [ "$2" ]; then CLIENT_USER=$2; fi
if [ "$3" ]; then SERVER_ArchiveFile=$3; fi
if [ "$4" ]; then CLIENT_FOLER=$4; fi
if [ "$5" ]; then SSHkeyToClient=$5; fi

# add option -i in front of key pass if key pass is not empty 
if [ $SSHkeyToClient ]; then SSHkeyToClient="-i $SSHkeyToClient"; fi
# add option -p and -P in front of port if port is not empty
if [ $CLIENT_PORT ];
  then CLIENT_port=" -p $CLIENT_PORT"; CLIENT_Port=" -P $CLIENT_PORT";
  else CLIENT_port= ; CLIENT_Port= ;
fi

echo -e "\n\nUPDATING CLIENT============================================$CLIENT_USER@$CLIENT_ADRESS"

echo  -e "___CHECK archive file existence on Server."
if [ -f $CWD/$SERVER_ArchiveFile ]; 
  then echo -e "==Achive file $CWD/$SERVER_ArchiveFile exists."
  else echo -e "==Achive file $CWD/$SERVER_ArchiveFile does NOT exist.\nExit"; exit 1
fi

echo  -e "___CHECK connection to Client by ping"
ping $CLIENT_ADRESS -c2
if [ $? -eq 0 ];
  then echo -e "==Client $CLIENT_ADRESS is connected"
  else echo -e "==No ping of Client $CLIENT_ADRESS.\nExit"; exit 1
fi

echo -e "___COMPARE archives on Sever and Client by SHA"
shaFile1=$($SSH $SSHkeyToClient $CLIENT_port $CLIENT_USER@$CLIENT_ADRESS "sha1sum $CLIENT_FOLER$SERVER_ArchiveFile | cut -d ' ' -f 1")
shaFile2=$(sha1sum $CWD/$SERVER_ArchiveFile | cut -d " " -f 1)
echo Client arhive sha:$shaFile1
echo Server arhive sha:$shaFile2

echo -e "___COPY of update file from Server"
if [[ $shaFile1 != $shaFile2 ]]; then  
  echo  -e "  >>>>>> WAIT few minutes for copy archive to Client"
  scp -o StrictHostKeyChecking=no $SSHkeyToClient $CLIENT_Port $CWD/$SERVER_ArchiveFile $CLIENT_USER@$CLIENT_ADRESS:$CLIENT_FOLER
  if [ $? -eq 0 ]; then 
    echo -e "==Copy of archive file from Server to Client is complited"
    echo -e "==New archive on Client in $CLIENT_FOLER$SERVER_ArchiveFile: $(date)"
  else 
    echo -e "Fault of copy from Server in $CLIENT_FOLER$SERVER_ArchiveFile to Client . \nExit"; exit 1
  fi
else 
  echo -e "==No copy process: Archive file on Server is same to archive file on Client.\nExit"; exit 1
fi
# print logs of copy result to file Log.txt
CLIENT_CPU=$($SSH $SSHkeyToClient $CLIENT_port $CLIENT_USER@$CLIENT_ADRESS "sudo dmidecode -t system | grep Serial")
echo -n -e "\n$(date +%y.%m.%d-%H:%M:%S) $CLIENT_USER@$CLIENT_ADRESS $shaFile1 $SSHkeyToClient $CLIENT_Port $CLIENT_FOLER$SERVER_ArchiveFile $CLIENT_CPU Copied" >> Log.txt

echo -e "___EXTRACT archive file on Client"
$SSH $SSHkeyToClient $CLIENT_port $CLIENT_USER@$CLIENT_ADRESS "sudo 7z x -y $CLIENT_FOLER$SERVER_ArchiveFile -o\"$CLIENT_FOLER\"; sudo chmod -R 777 $CLIENT_FOLER/UpDate;"
# print logs of extruction result to file Log.txt
if [ $? -eq 0 ]; 
  then echo -e "==Extracting to $CLIENT_FOLER on Client is complited"; echo -n -e ", Expracted" >> Log.txt
  else echo -e "==Extracting fault. \nExit"; echo -n -e ", NOT Expracted" >> Log.txt;  exit 1
fi
# check of extracted folder existance
if $SSH $SSHkeyToClient $CLIENT_port $CLIENT_USER@$CLIENT_ADRESS "[ -d \"$CLIENT_FOLER/UpDate\" ]";
  then echo -e " $CLIENT_FOLER/UpDate exists"; echo -n -e ", Folder exists" >> Log.txt
  else echo -e " $CLIENT_FOLER/UpDate does NOT exist"; echo -n -e ", Folder NOT exist" >> Log.txt
fi
echo "Software copy and extraction on $CLIENT_USER@$CLIENT_ADRESS succeeded"
exit 0
