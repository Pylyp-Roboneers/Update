#!/bin/bash
CWD=$( dirname "$0")  # path to this scriptecho iteration
date > logsItr.txt

# Break the client list file on separate lines and form list of lines for each IP
Iter=1
unset IPlist
declare -A IPlist
while read -r line; do
  IPlist[$Iter]=$line 
  Iter=$(($Iter+1))
done < $CWD/ClientList.txt

# Treat each IP line
for lineN in ${!IPlist[@]}; do

  # get client connection parrameters from line
  read Adress ArchiveFile SHAarchive User Path SSHkeyToClient <<< ${IPlist[$lineN]}
  echo "Adress=$Adress; File=$ArchiveFile; Sha=$SHAarchive; User=$User; path=$Path key=$SSHkeyToClient"

  # current archive file SHA on Server
  shaArchive=$(sha1sum $CWD/$ArchiveFile  | cut -d " " -f 1)
  # if current SHA differs from SHA from list then run update 
  if [[ $shaArchive != $SHAarchive ]]; then 

    # Replace archive file on Client
    $CWD/UpdateClient.sh $Adress $User $ArchiveFile $Path $SSHkeyToClient >> logsItr.txt
    if [ $? -ne 0 ]; then continue; fi

    # Reading of SHA of copied archive file on Client to proove file copy
    if [ $SSHkeyToClient ]; then sshKey=" -i $SSHkeyToClient"; else sshKey=""; fi  # add option -i to ssh key, if no key then no option
    ClientArchiveSHA=$(ssh $sshKey $User@$Adress "sha1sum $Path$ArchiveFile  | cut -d ' ' -f 1")
    if [[ ! $ClientArchiveSHA ]]; then ClientArchiveSHA="NONE_SHA__$ClientArchiveSHA"; fi  # if recieved empty SHA

    # Exchange list line by new SHA for current IP
    sed -i "s/$Adress $ArchiveFile $SHAarchive/$Adress $ArchiveFile $ClientArchiveSHA/" $CWD/ClientList.txt 
  fi  # if [[ $shaArchive != $SHAarchive ]]
done # for lineN in ${!IPlist[@]}
exit 0
