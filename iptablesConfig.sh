#!/bin/bash

# Check for required packages
packages=("toilet" "boxes" "lolcat")
missing_packages=()

for package in "${packages[@]}"
do
    if ! dpkg -s "$package" > /dev/null 2>&1; then
        missing_packages+=("$package")
    fi
done

# Prompt user to install missing packages
if [ ${#missing_packages[@]} -gt 0 ]; then
    echo -e "\033[0;31mThe following packages are required but not installed: ${missing_packages[@]}\033[0m"
    read -p "Do you want to install them now? (y/n) " choice
    case "$choice" in
        y|Y ) sudo apt-get update && sudo apt-get install -y "${missing_packages[@]}";;
        n|N ) echo "Exiting..."; exit 1;;
        * ) echo "Invalid choice. Exiting..."; exit 1;;
    esac
fi

toilet -f smblock "IPTABLES CONFIGURATION" | boxes -d cat -a hc -p h0 | lolcat

echo "What do you wish to do:"

echo "Flush all existing rules (1)"
echo "Set default rules (2)"
echo "Allow certain traffic (3)"
echo "Allow traffic based on protocol (4)"
echo "Log dropped packets (5)"
echo "Save rules (6)"
echo "Exit (7)"

read -p "What's your pick? " choice

if [ $choice == "1" ]; then
  iptables -f
elif [ $choice == "2" ]; then
  iptables -P INPUT DROP
  iptables -P FORWARD DROP
  iptables -P OUTPUT ACCEPT
elif [ $choice == "3" ]; then
  echo "Allow loopback traffic (1)"
  echo "Allow established & related traffic (2)"
  read -p "What do you pick? " pick
  if [ $pick == "1" ]; then
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A OUTPUT -o lo -j ACCEPT
  elif [ $pick == "2" ]; then
    iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
  fi
elif [ $choice == "4" ]; then
  echo "Allow SSH traffic (1)"
  echo "Allow HTTP and HTTPS traffic (2)"
  echo "Allow DNS traffic (3)"
  echo "Allow NTP traffic (4)"
  read -p "What do you pick? " choice1
  if [ $choice1 == "1" ]; then
    iptables -A INPUT -p tcp --dport ssh -j ACCEPT
  elif [ $choice1 == "2" ]; then
    iptables -A INPUT -p tcp --dport http -j ACCEPT
    iptables -A INPUT -p tcp --dport https -j ACCEPT
  elif [ $choice1 == "3" ]; then
    iptables -A INPUT -p udp --dport 53 -j ACCEPT
    iptables -A INPUT -p tcp --dport 53 -j ACCEPT
  elif [ $choice1 == "4" ]; then
    iptables -A INPUT -p udp --dport 123 -j ACCEPT
  fi
elif [ $choice == "5" ]; then
  iptables -A INPUT -m limit --limit 5/min -j LOG --log-prefix "iptables denied: " --log-level 7
elif [ $choice == "6" ]; then
  mkdir /etc/iptables
  iptables-save > /etc/iptables/rules.v4
elif [ $choice == "7" ]; then
  break
fi