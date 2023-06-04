#!/bin/bash

toilet -f smblock "Nginx Deployer" | boxes -d cat -a hc -p h0 | lolcat
echo "ATTENTION! ONLY FOR UBUNTU BASED OS" 

sleep 4

printf "Updating the package list..."
sudo apt-get update

printf "Upgrading the package list..."
sudo apt-get upgrade

printf "Instaling Nginx..."
sudo apt instal nginx -y

echo "Verifying Nginx install..."
nginx -v

echo "Adjusting firewall permissions..."
sudo ufw allow 'Nginx HTTP'

echo "Starting nginx service..."
sudo systemctl start nginx

echo "Checking current Nginx status..."
sudo systemctl status nginx

read -p "Do you wish to enable the nginx service at startup? y/n " choice

if [ $choice -eq "n" ] 
do
continue
done
elif [ $choice -eq "y"]
do
  echo "Enabling Nginx at startup"
  sudo systemctl enable nginx
done
fi