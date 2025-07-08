#!/bin/bash
CWD=$( dirname "$0")  # path to this script
sudo mv $CWD/update_.7z  $CWD/update__.7z
sudo mv $CWD/update.7z   $CWD/update_.7z
sudo mv $CWD/update__.7z $CWD/update.7z
