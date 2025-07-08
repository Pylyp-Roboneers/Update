#!/bin/bash
# echo "password" | sudo -S -v  # if password to local is requered
SERVER_USER=pi
SERVER_ADRESS=10.168.103.1
SERVER_PORT=
SERVER_FOLER=/home/pi/theWD
LOCAL_SSHkeyToServer=/home/deck/.ssh/keyToServer1
AUTORUN_POSTPONE_TIME_SEC=259200
CWD=$( dirname "$0")  # path to this script
# CWD="$(pwd)"  # path where the script was launched

# add option -i in front of key pass if key pass is not empty 
if [ $LOCAL_SSHkeyToServer ]; then LOCAL_SSHkeyToServer="-i $LOCAL_SSHkeyToServer"; fi
# add option -p and -P in front of port if port is not empty
if [ $SERVER_PORT ];
  then SERVER_PORT_arg=" -p $SERVER_PORT"; SERVER_PORT_Arg=" -P $SERVER_PORT";
  else SERVER_PORT_arg= ; SERVER_PORT_Arg= ;
fi

# List of update files with correspondent path
declare -A filePathList  # key - update file name; value = correspondent file path to update
filePathList["autopilot_control"]="/usr/bin/"
filePathList["gamepad_udp_run"]="/usr/bin/"
filePathList["GUI_1_0"]="/usr/bin/"

printFileDetails()
{
  echo modified : created : name : size  / SHA1
  for aFile in ${!filePathList[@]}; do
      echo -n $1
      stat -c ' %y : %w : %n : %s' ${filePathList[$aFile]}$aFile
      echo "        $(sha1sum ${filePathList[$aFile]}$aFile  | cut -d " " -f 1)"
  done
}
stopProcesses()
{
  for aFile in ${!filePathList[@]}; do
    pkill -f "$aFile"
  done
  sleep 3  # wait to processes are completely stop
}
checkDiskSpace()
{
  SIZEkB_Disk=$((df --output=avail --out=target | grep /home) | cut -d " " -f 1 )
  SIZEkB_Packed=$(( $(stat -c '%s' update.7z) /1000))
  SIZEkB_UnPacked=$(( $((7z l update.7z | tail -n 1) | awk '{print $3}') /1000))
  SIZEkB_Required=$(($SIZEkB_Packed + (2 * $SIZEkB_UnPacked)))
  echo "Disck Avalable=$SIZEkB_Disk kB; Packed File=$SIZEkB_Packed kB; Unpacked=$SIZEkB_UnPacked kB"
  echo "Required Space=$SIZEkB_Required kB = 2 * Unpacked + Packed File"
  if [[ $SIZEkB_Disk > $SIZEkB_Required ]]; 
      then echo "There is enoght space"; return 0
      else echo "There is NO space";  return 1
  fi
}

echo -e "\n   SOFT UPDATE FROM SERVER through $CWD. Procedure $1"
echo -e "CPU $(sudo dmidecode -t system | grep Serial)"

if [ "$1" == "--ping" ]; then
  echo -e "\n  CHECK folder $CWD/UpDate with extracted update files"
  if [ -d "$CWD/UpDate" ]; then 
    # if exists then update files was not copied to correspondent folders
    echo -e "==$CWD/UpDate/ exists.\nExit"; exit 0
  else
    # if does not exist then update was completed
    echo -e "==$CWD/UpDate/ dose not exist.\nExit"; exit 1
  fi
fi 

# REPLACE UPDATE SOFTWARE FILES AND BACKUP PREVIOUS FILE
if [[ "$#" -eq 0 ]] || [ "$1" == "--replace" ]; then

  echo -e "\n  CHECK folder with extracted update files"
  if [ -d "$CWD/UpDate" ]; then 
    # if exists then update files was not copied to correspondent folders
    echo -e "==$CWD/UpDate/ exists."
    sudo chmod -R 777 $CWD/UpDate/
  else
    # if does not exist then update was completed
    echo -e "==$CWD/UpDate/ dose not exist. \nExit"; exit 1
  fi

  # Reading of update file path for correspondent file
  if [ ! -f "$CWD/UpDate/UpdatePathList" ]; 
    then echo -e "==UpdatePathList dose not exist. \nExit"; exit 1
  fi
  sed -i -e 's/\r$//' $CWD/UpDate/UpdatePathList
  unset filePathList
  declare -A filePathList  # key - update file name; value = correspondent file path to update
  source $CWD/UpDate/UpdatePathList
  echo The File path list
  for aFile in ${!filePathList[@]}; do  # print out update file list with path
    echo ${filePathList[$aFile]}$aFile
  done
  
  echo -e "\n  STOP correspondent processes"
  stopProcesses

  echo -e "\n  DETAILS of previous software files"
  printFileDetails "<<<"

  # BackUp procedure

    echo -e "\n  DELETE content of previous back-up in $CWD/BackUp"
    rm -r -f $CWD/BackUp
    mkdir $CWD/BackUp
    sudo -n chmod 777 -R $CWD/BakUp

    echo -e "\n  COPY back-up files to $CWD/BackUp/"
    for aFile in ${!filePathList[@]}; do
      sudo -n cp ${filePathList[$aFile]}$aFile  $CWD/BackUp/
    done
    for aFile in ${!filePathList[@]}; do  # Check backup files existence
      if [ ! -f "$CWD/BackUp/$aFile" ]; then 
        # echo -e "    Backup of $aFile dose not exist. \nExit"; exit 1
        echo -e "    Backup of $aFile dose not exist."
      fi
    done
    echo -e "==BackUp complited"
    # BackUp of UpdatePathList
    sudo -n cp $CWD/UpDate/UpdatePathList  $CWD/BackUp/
    if [ ! -f "$CWD/BackUp/UpdatePathList" ]; 
      then echo -e "    Backup of UpdatePathList dose not exist. \nExit"; exit 1
    fi
  # fi # end back-up

  echo -e "\n  REPLACE software UpDate files"
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/UpDate/$aFile ${filePathList[$aFile]}$aFile
    if [ $? -ne 0 ]; 
      then echo -e "    replace of ${filePathList[$aFile]}$aFile is fault."; 
      else echo ====${filePathList[$aFile]}$aFile is copied
    fi
  done

  echo -e "\n\n  DETAILS of updated current software files"
  printFileDetails ">>>"

  # Delete UpDate folder as a sign that update is completed
  echo -e "\n\n  DELETE folder with extracted files $CWD/UpDate"
  rm -r -f $CWD/UpDate

  unset filePathList
  echo -e "UPDATE IS COMPLITED"
  exit 0
fi # END of REPLACE UPDATE FILES AND BACKUP FILE # if [[ "$#" -eq 0 ]] || [ "$1" == "--replace" ]

# BACKUP RESTORE PROCEDURE
if [ "$1" == "--restore" ]; then  
  echo -e "\n  PROCEDURE of COPY BACK previously saved backup files from $CWD/BackUp"
  # Check existance of BackUp folder
  if [ -d "$CWD/BackUp" ]; 
    then echo -e "==$CWD/BackUp/ exists."
    else echo -e "==$CWD/BackUp/ dose not exist.\nFault BackUp \nExit"; exit 1
  fi

  # Reading of update file path for correspondent file
  if [ ! -f "$CWD/BackUp/UpdatePathList" ]; 
    then echo -e "==$CWD/BackUp/UpdatePathList dose not exist. \nExit"; exit 1
  fi
  sed -i -e 's/\r$//' $CWD/BackUp/UpdatePathList
  unset filePathList
  declare -A filePathList  # key - update file name; value = correspondent file path to update
  source $CWD/BackUp/UpdatePathList
  echo The File path list
  for aFile in ${!filePathList[@]}; do
    echo ${filePathList[$aFile]}$aFile
  done

  echo -e "\n  STOP correspondent processes"
  stopProcesses

  echo -e "\n  DETAILS of previous software files for BackUp"
  printFileDetails "<<<"

  echo -e "\n  COPY BackUp files from $CWD/BackUp/ to program folders."
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/BackUp/$aFile ${filePathList[$aFile]}
    if [ $? -ne 0 ]; 
      then echo -e "\e[1;31m Copy to ${filePathList[$aFile]}$aFile is fault."; 
      else echo "==${filePathList[$aFile]}$aFile is copied"
    fi
  done

  echo -e "\n  DETAILS of current software files for BackUp"
  printFileDetails ">>>"
  echo -e "\n==Backup Restore procedure finished"
  unset filePathList
  exit 0
fi  ## END OF BACKUP RESTORE PROCEDURE

# EXTRACTION PROCEDURE
if [ "$1" == "--extract" ]; then
  echo -e "EXTRACTION PROCEDURE of existing archive file"

  if [ -f "$CWD/update.7z" ]; 
    then echo -e "==Archive file $CWD/update.7z exists"
    else echo -e "==Archive file $CWD/update.7z does not exist. \nExit"; exit 1
  fi

  echo -e "==Remove perevios $CWD/UpDate folder"
  rm -f -r $CWD/UpDate

  sudo 7z x -y $CWD/update.7z -o"$CWD"  # extraction
  if [ $? -eq 0 ]; 
    then echo -e "==Extracting to $CWD is complited"
    else echo -e "==Extracting fault. \nExit"; exit 1 
  fi
  sudo -n chmod 777 -R $CWD/UpDate

  # Reading of update file path for correspondent file
  if [ ! -f "$CWD/UpDate/UpdatePathList" ]; 
    then echo -e "==UpdatePathList dose not exist. \nExit"; exit 1
  fi
  sed -i -e 's/\r$//' $CWD/UpDate/UpdatePathList
  unset filePathList
  declare -A filePathList  # key - update file name; value = correspondent file path to update
  source $CWD/UpDate/UpdatePathList
  echo The File path list
  for aFile in ${!filePathList[@]}; do
    echo ${filePathList[$aFile]}$aFile
  done

  echo -e "==STOP correspondent processes"
  stopProcesses

  echo -e "\n  DETAILS of previous software files for BackUp"
  printFileDetails "<<<"

  echo -e "\n\n  REPLACE software update files"
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/UpDate/$aFile ${filePathList[$aFile]}$aFile
    if [ $? -ne 0 ]; 
      then echo -e "    replace of ${filePathList[$aFile]}$aFile is fault."; 
      else echo ====${filePathList[$aFile]}$aFile is copied
    fi
  done

  echo -e "\n  DETAILS of updated current software files"
  printFileDetails ">>>"

  echo -e "\n  DELETE folder with extracted files $CWD/UpDate"
  rm -r -f $CWD/UpDate
  unset filePathList
  exit 0
fi  # End OF EXTRACTION PROCEDURE

if [ "$1" == "--checkspace" ]; then
  checkDiskSpace
  exit $?
fi

if [ "$1" == "--force" ]; then

  echo  -e "CHECK connection to Server by ping"
  ping $SERVER_ADRESS -c2
  if [ $? -eq 0 ]; 
    then echo -e "==Server is connected";
    else echo -e "==Server is NOT connected"; exit 1
  fi

  echo  -e ">>>>>> WAIT few minutes for Copying from Server"
  scp $LOCAL_SSHkeyToServer $SERVER_PORT_Arg $SERVER_USER@$SERVER_ADRESS:$SERVER_FOLER/update.7z $CWD
  if [ $? -eq 0 ]; then 
    echo -e "==Copy of archive file from Server to local is complited"
    echo -e "==New archive in $CWD: $(date)"
  else 
    echo -e "Fault of copy from Server. \nExit";  exit 1 
  fi

  echo -e "\n\n  EXPRACTING from $CWD/update.7z"
  if [ -f "$CWD/update.7z" ]; 
    then echo -e "==Archive file $CWD/update.7z exists"
    else echo -e "==Archive file $CWD/update.7z does not exist. \nExit"; exit 1
  fi
  # extraction
  7z x -y $CWD/update.7z -o"$CWD"
  if [ $? -eq 0 ]; 
    then echo -e "==Extracting to $CWD is complited"
    else echo -e "==Extracting fault. \nExit";  exit 1 
  fi
  sudo -n chmod 777 -R $CWD/UpDate
    if [ -d "$CWD/UpDate" ]; 
    then echo -e "==$CWD/UpDate/ exists." 
    else echo -e "==$CWD/UpDate/ dose not exist. \nExit"; exit 1
  fi

  # Reading of update file path for correspondent file
  if [ ! -f "$CWD/UpDate/UpdatePathList" ]; 
    then echo -e "==UpdatePathList dose not exist. \nExit"; exit 1
  fi
  sed -i -e 's/\r$//' $CWD/UpDate/UpdatePathList
  unset filePathList
  declare -A filePathList  # key - update file name; value = correspondent file path to update
  source $CWD/UpDate/UpdatePathList
  echo The File path list
  for aFile in ${!filePathList[@]}; do
    echo ${filePathList[$aFile]}$aFile
  done
  
  echo -e "   STOP correspondent processes"
  stopProcesses

  echo -e "   DETAILS of previous software files"
  printFileDetails "<<<"

  echo -e "\n  REPLACE software UpDate files"
  for aFile in ${!filePathList[@]}; do
    sudo cp $CWD/UpDate/$aFile ${filePathList[$aFile]}$aFile
    if [ $? -ne 0 ]; 
      then echo -e "    replace of ${filePathList[$aFile]}$aFile is fault."; 
      else echo ====${filePathList[$aFile]}$aFile is copied
    fi
  done

  echo -e "\n\n  DETAILS of updated current software files"
  printFileDetails ">>>"

  echo -e "\n\n  DELETE folder with extracted files $CWD/UpDate"
  rm -r -f $CWD/UpDate

  unset filePathList
  echo -e "EXTRACTING IS COMPLITED"
  exit 0    
fi


if [ "$1" == "-h" ]; then # print help
  echo -e "no argument  \t\t update from remote Server"
  echo -e "--restore    \t\t copy previously saved backup files in /BackUp in program folders"
  echo -e "--ping    \t\t Server ping and copy archive from Server if local archive is different"
  echo -e "--replace    \t\t replace update files from /UpDate in correspondent software folders"
  echo -e "--extract    \t\t extract existed archive file and replace update files"
  echo -e "--force     \t\t update from remote Server without version control and without back-up" 
  echo -e "--checkspace\t\t check available disk space for update" 
  exit 0
fi
