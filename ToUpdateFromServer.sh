#!/bin/bash
SERVER_USER=pi
SERVER_ADRESS=77.222.152.213
SERVER_PORT=2222
SERVER_FOLER=/home/pi/theWD
LOCAL_SSHkeyToServer=/home/deck/.ssh/keyToServer
CWD=$( dirname "$0")  # path to this script
# CWD="$(pwd)"  # path where the script was launched

# List of update files with correspondent path
declare -A filePathList  # key - update file name; value = correspondent file path to update
filePathList["autopilot_control"]="/usr/bin/"
filePathList["gamepad_udp_run"]="/usr/bin/"
filePathList["GUI_1_0"]="/usr/bin/"

echo -e "\n   SOFT UPDATE FROM SEVER through $CWD."
echo -e "CPU $(sudo dmidecode -t system | grep Serial)"

# SERVER PING AND ARCHIVE COPY
if [[ "$#" -eq 0 ]] || [ "$1" == "--ping" ]; then # if there is no argument or --ping

  echo  -e "\n\n  CHECK connection to Server by ping"
  ping $SERVER_ADRESS -c2
  if [ $? -eq 0 ]; then 
    echo -e "==Server is connected"
  else 
    echo -e "==No ping of Server."
      if [ -d "$CWD/UpDate" ] 
        then echo -e "==Folder $CWD/UpDate exists.\nExit";  exit 0
        else echo -e "==Folder $CWD/UpDate does not exist. No need to update. \nExit."; exit 1
      fi
  fi

  echo -e "\n\n  COPY of update file from Server"
  shaFile1=$(ssh -i $LOCAL_SSHkeyToServer -p $SERVER_PORT $SERVER_USER@$SERVER_ADRESS sha1sum $SERVER_FOLER/update.7z  | cut -d " " -f 1)
  shaFile2=$(sha1sum $CWD/update.7z  | cut -d " " -f 1)
  echo Sever arhive sha:$shaFile1
  echo Local arhive sha:$shaFile2
  if [[ $shaFile1 != $shaFile2 ]]; then  # compare archives by SHA
    echo "    Archives from Server and local are different"
    echo  -e "  >>>>>> WAIT few minutes"
    scp -i $LOCAL_SSHkeyToServer -P $SERVER_PORT $SERVER_USER@$SERVER_ADRESS:$SERVER_FOLER/update.7z $CWD
    if [ $? -eq 0 ]; then 
      echo -e "==Copy is complited"
      echo -e "==New archive in $CWD: $(date)"
    else 
      echo -e "Fault of copy from Server. \nExit"
      exit 1 
    fi
  else 
    echo -e "==No copy process: Archive file on Server is same to archive file on local"
    if [ "$1" == "--ping" ]; then 
      if [ -d "$CWD/UpDate" ] 
        then echo -e "==Folder $CWD/UpDate exists.\nExit";  exit 0
        else echo -e "==Folder $CWD/UpDate does not exist. No need to update. \nExit."; exit 1
      fi
    fi
  fi

  echo -e "\n\n  EXPRACTING from $CWD/update.7z"
  if [ -f "$CWD/update.7z" ]; then 
    echo -e "==Archive file $CWD/update.7z exists"
  else
    echo -e "==Archive file $CWD/update.7z does not exist. \nExit"
    exit 1
  fi
  echo -e "    Remove perevios $CWD/UpDate folder"
  rm -r $CWD/UpDate
  # 7z -a a.7z BackUp/*
  7z x -y $CWD/update.7z -o"$CWD"  # extraction
  if [ $? -eq 0 ]; then
    echo -e "==Extracting to $CWD is complited"
  else 
    echo -e "==Extracting fault. \nExit"
    exit 1 
  fi
  sudo -n chmod 777 -R $CWD/UpDate
  if [ "$1" == "--ping" ]; then exit 0; fi;
fi # END of SERVER PING AND ARCHIVE COPY ## if [[ "$#" -eq 0 ]] || [ "$1" == "--ping" ]

# REPLACE UPDATE SOFTWARE FILES AND BACKUP PREVIOUS FILE
if [[ "$#" -eq 0 ]] || [ "$1" == "--replace" ]; then

  echo -e "\n\n  CHECK folder with update software files"
  if [ -d "$CWD/UpDate" ]; then 
    # if exists then update files was not copied to correspondent folders
    echo -e "==$CWD/UpDate/ exists." 
  else
    # if does not exist then update was completed
    echo -e "==$CWD/UpDate/ dose not exist. \nExit"
    exit 1
  fi

  echo -e "\n\n  DELETE content of previous $CWD/BackUp"
  rm -r -f $CWD/BackUp
  mkdir $CWD/BackUp
  sudo -n chmod 777 -R $CWD/BackUp

  echo -e "\n\n  DETAILS of previous software files for BackUp"
  echo modified : created : name : size  / SHA1
  for aFile in ${!filePathList[@]}; do
      stat -c '<<< %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
      echo -e "        $(sha1sum ${filePathList[$aFile]}$aFile  | cut -d " " -f 1)"
  done

  echo -e "\n\n  COPY BackUp files"
  for aFile in ${!filePathList[@]}; do
    sudo -n cp ${filePathList[$aFile]}$aFile  $CWD/BackUp/
  done
  for aFile in ${!filePathList[@]}; do  # Check backup files existence
    if [ ! -f "$CWD/BackUp/$aFile" ]; then 
      echo -e "    Backup of $aFile dose not exist. \nExit"; exit 1
    fi
  done
  echo -e "==BackUp complited"

  echo -e "  STOP correspondent processes"
  for aFile in ${!filePathList[@]}; do
    pkill -f "$aFile"
  done
  sleep 3  # wait to processes are completely stop

  echo -e "\n\n  REPLACE software UpDate files"
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/UpDate/$aFile ${filePathList[$aFile]}$aFile
    if [ $? -ne 0 ]; 
      then echo -e "    replace of ${filePathList[$aFile]}$aFile is fault."; 
      else echo ====${filePathList[$aFile]}$aFile is copied
    fi
  done

  echo -e "\n\n  DETAILS of updated current software files"
  echo modified : created : name : size  / SHA1
  for aFile in ${!filePathList[@]}; do
      stat -c '>>> %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
      echo -e "        $(sha1sum ${filePathList[$aFile]}$aFile  | cut -d " " -f 1)"
  done

  # Delete UpDate folder as a sign that update is completed
  echo -e "\n\n  DELETE folder with extracted files $CWD/UpDate"
  rm -r -f $CWD/UpDate

  unset filePathList
  echo -e "UPDATE IS COMPLITEd"
  exit 0
fi # END of REPLACE UPDATE FILES AND BACKUP FILE # if [[ "$#" -eq 0 ]] || [ "$1" == "--replace" ]

if [ "$1" == "--backup" ]; then  ## BACKUP PROCEDURE
  echo -e "  PROCEDURE of COPY BACK previously saved backup files from $CWD/BackUp"
  # Check existance of BackUp folder
  if [ -d "$CWD/BackUp" ]; then 
    echo -e "    $CWD/BackUp/ exists\e[0m"
  else
    echo -e "    $CWD/BackUp/ dose not exist.\nFault BackUp \nExit"
    exit 1
  fi

  echo -e "  STOP correspondent processes"
  for aFile in ${!filePathList[@]}; do
    pkill -f "$aFile"
  done
  sleep 3  # wait to processes are completely stop

  echo -e "\n\n  DETAILS of previous software files for BackUp"
  echo modified : created : name : size  / SHA1
  for aFile in ${!filePathList[@]}; do
      stat -c '<<< %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
      echo -e "        $(sha1sum ${filePathList[$aFile]}$aFile  | cut -d " " -f 1)"
  done

  echo -e "  COPY BackUp files from $CWD/BackUp/ to program folders\e[0m"
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/BackUp/$aFile ${filePathList[$aFile]}
    if [ $? -ne 0 ]; 
      then echo -e "\e[1;31m Copy to ${filePathList[$aFile]}$aFile is fault.\e[0m"; 
      else echo "==${filePathList[$aFile]}$aFile is copied"
    fi
  done

  echo -e "\n\n  DETAILS of current software files for BackUp"
  echo modified : created : name : size  / SHA1
  for aFile in ${!filePathList[@]}; do
      stat -c '>>> %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
      echo -e "        $(sha1sum ${filePathList[$aFile]}$aFile  | cut -d " " -f 1)"
  done
  echo "==Backup procedure finished"
  unset filePathList
  exit 0
fi  ## END OF BACKUP PROCEDURE

if [ "$1" == "-h" ]; then # print help
  echo -e "no argument  \t\t update from remote Server"
  echo -e "--backup     \t\t copy previously saved backup files to program folders"
  echo -e "--ping    \t\t Server ping and copy archive from Server if local archive is different"
  echo -e "--replace    \t\t replace update files in correspondent software folders"
  exit 0
fi
