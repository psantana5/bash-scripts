#!/bin/bash

toilet -f smblock "Samba 4 remover" | boxes -d cat -a hc -p h0 | lolcat

echo "Stopping Samba services..."
sudo systemctl stop samba-ad-dc
sudo systemctl disable samba-ad-dc

echo "Removing Samba packages..."
sudo apt purge -y samba samba-common ldb-tools winbind smbclient

echo "Removing Samba configuration files..."
sudo shred -u /etc/samba

echo "Removing Samba database and logs..."
sudo shred -u -z /var/lib/samba/*
sudo shred -u -z /var/log/samba/*


echo "Removing Kerberos configuration files..."
sudo shred -u /etc/krb5.conf
sudo shred -u /etc/krb5.conf.bak

echo "Samba 4 has been completely removed."

