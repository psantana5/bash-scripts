#!/bin/bash

echo -e "Hello, welcome to the Network Utilities menu I made, what do you want to do?"


read -p "Do you want to see your net interface (1) or do you want to do a internet speedtest (2)? " choice

if [ $choice -eq 2 ]  
then
  echo -e "Attention, you must have the package speedtest-cli installed!"
  sleep 2
  echo -e "If you do not have speedtest-cli installed, this script will install it now."
  if ! command -v speedtest-cli &> /dev/null 
  then
    sudo apt-get install speedtest-cli -y
    sudo apt-get update
  fi
  else:
	echo -e "speedtest-cli was found, beginning now"
  speedtest-cli
elif [ $choice -eq 1 ]
then
  read -p "Net interface name: " interface
  ifconfig $interface
else
  echo "Invalid choice"
fi
