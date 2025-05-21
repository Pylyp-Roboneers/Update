#!/bin/bash
# echo "11111111" | sudo -S -v  # if password to local is requered
CWD=$( dirname "$0")  # path to this script
# CWD="$(pwd)"  # path where the script was launched

# List of update files with correspondent path
declare -A filePathList  # key - update file name; valie = correspondent file path to update
filePathList["autopilot_control"]="/usr/bin/"
filePathList["gamepad_udp_run"]="/usr/bin/"
filePathList["GUI_1_0"]="/usr/bin/"

echo -e "\n   SOFT UPDATE FROM SEVER through $CWD."
echo "     " CPU $(sudo dmidecode -t system | grep Serial)

# SERVER PING AND ARCHIVE COPY
if [[ "$#" -eq 0 ]] || [ "$1" == "--ping" ]; then # if there is no argument or --ping
  echo  -e "\n\n  CHECK connection to Server by ping"
  ping 77.222.152.213 -c2
  if [ $? -eq 0 ]; then 
    echo -e "==Server is connected"
  else 
    echo -e "==No ping of Server. \nExit"
    exit 1
  fi

  echo -e "\n\n  COPY of update file from Server"
  shaFile1=$(ssh -i /home/deck/.ssh/keyToServer -p 2222 pi@77.222.152.213 sha1sum /home/pi/theWD/update.7z  | cut -d " " -f 1)
  shaFile2=$(sha1sum $CWD/update.7z  | cut -d " " -f 1)
  echo Sever arhive sha:$shaFile1
  echo Local arhive sha:$shaFile2
  if [[ $shaFile1 != $shaFile2 ]]; then  # compare archives by SHA
    echo "    Archives from Server and local are different"
    echo  -e "  >>>>>> WAIT few minutes"
    scp -i /home/deck/.ssh/keyToServer -P 2222 pi@77.222.152.213:theWD/update.7z $CWD
    if [ $? -eq 0 ]; then 
      echo -e "==Copy is complited"
      echo -e "==New archive in $CWD: $(date)"
    else 
      echo -e "Fault of copy from Server. \nExit"
      exit 1 
    fi
  else echo -e "==No copy process: Archive file on Server is same to archive file on local"
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
  if [ "$1" == "--ping" ]; then exit 0; fi;
fi # END of SERVER PING AND ARCHIVE COPY ## if [[ "$#" -eq 0 ]] || [ "$1" == "--ping" ]

if [[ "$#" -eq 0 ]] || [ "$1" == "--replace" ]; then
  if [ -d "$CWD/UpDate" ]; then 
    echo -e "\e[1;32m   $CWD/UpDate/ exists\e[0m"
  else
    echo -e "\e[1;31m   $CWD/UpDate/ dose not exist. \nExit\e[0m"
    exit 1
  fi
  sudo -n chmod 777 -R $CWD/UpDate

  echo -e "\e[1;33m  5 Delete content of previous $CWD/BackUp\e[0m"
  rm -r -f $CWD/BackUp
  mkdir $CWD/BackUp
  sudo -n chmod 777 -R $CWD/BackUp

  echo -e "\e[1;33m  6 Stat of previous soft files for BackUp  \e[0m"
  echo -e "\e[1;33m---Date of previous files\e[0m"
  echo modified : created : name : size
  for aFile in ${!filePathList[@]}; do
      stat -c '<<< %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
  done

  echo -e "\e[1;33m---Copy BackUp files\e[0m"
  for aFile in ${!filePathList[@]}; do
    sudo -n cp ${filePathList[$aFile]}$aFile  $CWD/BackUp/
  done

  ## Check backup files existence
  for aFile in ${!filePathList[@]}; do
    if [ ! -f "$CWD/BackUp/$aFile" ]; then 
      echo -e "\e[1;31m  Backup of $aFile dose not exist. \nExit\e[0m"; exit 1
    fi
  done
  echo -e "\e[1;32m==BackUp complited\e[0m"

  echo -e "\e[1;33m  7 Stoping correspondent processes\e[0m"
  for aFile in ${!filePathList[@]}; do
    pkill -f "$aFile"
  done
  # pkill -f "GUI_1_0"
  # pkill -f "autopilot_control"

  echo -e "\e[1;33m  8 Replace UpDate files\e[0m"
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/UpDate/$aFile ${filePathList[$aFile]}$aFile
    if [ $? -ne 0 ]; 
      then echo -e "\e[1;31m replace of ${filePathList[$aFile]}$aFile is fault.\e[0m"; 
      else echo ====${filePathList[$aFile]}$aFile is copied
    fi
  done

  echo -e "\e[1;33m---Date of current files\e[0m"
  echo modified : created : name : size
  for aFile in ${!filePathList[@]}; do
      stat -c '<<< %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
  done

  unset filePathList
  echo -e "\n\e[1;33m END of Update  \n\e[0m"
  sleep 10
  exit 0
fi # END of MAIN PROCEDURE of UPDATE # if [[ "$#" -eq 0 ]];

if [ "$1" == "--backup" ]; then  ## BACKUP PROCEDURE
  echo -e "\e[1;33m PROCEDURE of COPY BACK previously saved backup files from $CWD/UpDate \e[0m"
  echo CPU $(sudo dmidecode -t system | grep Serial)
  # Check existance of BackUp folder
  if [ -d "$CWD/UpDate" ]; then 
    echo -e "\e[1;32m   $CWD/UpDate/ exists\e[0m"
  else
    echo -e "\e[1;31m   $CWD/UpDate/ dose not exist.\nFault BackUp \nExit\e[0m"
    exit 1
  fi

  echo -e "\e[1;33m Stoping correspondent processes\e[0m"
  for aFile in ${!filePathList[@]}; do
    pkill -f "$aFile"
  done
  sleep 3

  echo -e "\e[1;33m---Date of previous files\e[0m"
  echo modified : created : name : size
  for aFile in ${!filePathList[@]}; do
      stat -c '<<< %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
  done

  echo -e "\e[1;33m---Copy BackUp files from $CWD/BackUp/ to program folders\e[0m"
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/BackUp/$aFile ${filePathList[$aFile]}
    if [ $? -ne 0 ]; 
      then echo -e "\e[1;31m Copy to ${filePathList[$aFile]}$aFile is fault.\e[0m"; 
      else echo "   ${filePathList[$aFile]}$aFile is copied"
    fi
  done

  echo -e "\e[1;33m---Date of current files\e[0m"
  echo modified : created : name : size
  for aFile in ${!filePathList[@]}; do
      stat -c '<<< %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
  done
  echo Backup procedure finished
  sleep 10
  exit 0
fi  ## END OF BACKUP PROCEDURE

if [ "$1" == "-h" ]; then # print help
  echo -e "no argument  \t\t update from remote Server"
  echo -e "--backup     \t\t copy previously saved backup files to program folders"
  echo -e "--ping    \t\t Server ping and copy archive from Server if local archive is different"
  echo -e "--replace    \t\t replace update files in correspondent software folders"
  exit 0
fi
