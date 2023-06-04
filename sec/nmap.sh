#!/bin/bash

toilet -f bigmono9 -F gay -F border --gay "NMAP PAU"

echo "Basic network scan (Services, verbose mode, default scripts) press 1"

echo "Scan for vulnerabilities on my network. press 2"

 
read -p "What do you wish to do: " option

if [ $option -eq 1 ]
then
  read -p "What's the network/host IP you wish to scan: " ip 
  read -p "What's the file you want to save the output to: " file
  nmap -sC -v -sV -On $file $ip

elif [ $option -eq 2 ]
then
  read -p "What's the network/host IP you want to scan: " ip
  read -p "What's the file you want to save the output to: " file
  nmap --script vuln -oN $file $ip 
fi
