#!/bin/bash
# echo "11111111" | sudo -S -v  # if password to local is requered
CWD=$( dirname "$0")  # path to this script
# CWD="$(pwd)"  # path where the script was launched

# List of update files with correspondent path
declare -A filePathList  # key - update file name; valie = correspondent file path to update
filePathList["autopilot_control"]="/usr/bin/"
filePathList["gamepad_udp_run"]="/usr/bin/"
filePathList["GUI_1_0"]="/usr/bin/"

if [[ "$#" -eq 0 ]] || [ "$1" == "--ping" ]; then # there is no argument
# MAIN PROCEDURE of UPDATE
  echo -e "\n\e[1;33m SOFT UPDATE FROM SEVER through $CWD.\n\e[0m"
  echo CPU $(sudo dmidecode -t system | grep Serial)
  echo  -e "\n\e[1;33m  1 Check connection to Server by ping  \e[0m"
  ping 77.222.152.213 -c2
  if [ $? -eq 0 ]; then 
    if [ "$1" == "--ping" ]; then exit 0; fi
    echo -e "\e[1;32m==Server is connected\e[0m"
  else 
    echo -e "\e[1;31m==No ping of Server. \nExit\e[0m"
    exit 10
  fi
  echo  -e "Compare arhives in Server and Local"
  shaFile1=$(ssh -i /home/deck/.ssh/keyToServer -p 2222 pi@77.222.152.213 sha1sum /home/pi/theWD/update.7z  | cut -d " " -f 1)
  shaFile2=$(sha1sum $CWD/update.7z  | cut -d " " -f 1)
  echo Sever arhive sha:$shaFile1
  echo Local arhive sha:$shaFile2
  if [ $shaFile1 == $shaFile2 ]; then
    echo "Archives are same"
  else
    echo "Archives are different"
  fi

  echo  -e "\e[1;33m  2 Copy of update file from Server  \e[0m"
  echo  -e "\e[1;32m  >>>>>> WAIT few minutes \e[0m"
  scp -i /home/deck/.ssh/keyToServer -P 2222 pi@77.222.152.213:theWD/update.7z $CWD
  if [ $? -eq 0 ]; then 
    echo -e "\e[1;32m==Copy is complited\e[0m"
  else 
    echo -e "\e[1;31m==Fault of copy from Server. \nExit\e[0m"
    exit 1 
  fi
  if [ -f "$CWD/update.7z" ]; then 
    echo -e "\e[1;32m==Archive file $CWD/update.7z exists\e[0m"
  else
    echo -e "\e[1;31m==Archive file $CWD/update.7z does not exist. \nExit\e[0m"
    exit 1
  fi

  echo -e "\e[1;33m  3 Remove perevios $CWD/UpDate folder  \e[0m"
  rm -r $CWD/UpDate

  echo -e "\e[1;33m  4 Extracting from $CWD/update.7z  \e[0m"
  # 7z -a a.7z BackUp/*
  7z x -y $CWD/update.7z -o"$CWD"
  if [ $? -eq 0 ]; then
    echo -e "\e[1;32m==Extracting is complited\e[0m"
  else 
    echo -e "\e[1;31m==Extracting fault. \nExit\e[0m"
    exit 1 
  fi
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
  echo -e "--ping    \t\t Server ping"
  echo -e "exit=10: no ping of Server"
  exit 0
fi
