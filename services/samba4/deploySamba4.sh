#!/bin/bash

toilet -f smblock "Samba 4 Deployer" | boxes -d cat -a hc -p h0 | lolcat

echo "Updating system..."
sudo apt update
sudo apt upgrade -y

echo "Installing Samba 4 dependencies..."
sleep 1
sudo apt install -y samba krb5-user

echo "Configuring Kerberos. Backing up configuration"
sudo cp /etc/krb5.conf /etc/krb5.conf.

read -p "What's your realm? " domain

sleep 1
sudo bash -c "cat << EOF > /etc/krb5.conf
[libdefaults]
    default_realm = $domain
    dns_lookup_realm = false
    dns_lookup_kdc = false
EOF"
read -p "What's your workgroup? " workgroup
read -p "What DNS forwarder do you want to use? " forwarder
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.bak
sudo bash -c "cat << EOF > /etc/samba/smb.conf
[global]
    workgroup = $workgroup
    realm = $domain
    server role = active directory domain controller
    dns forwarder = $forwarder
    idmap_ldb:use rfc2307 = yes

[netlogon]
    path = /var/lib/samba/sysvol/$domain/scripts
    read only = No

[sysvol]
    path = /var/lib/samba/sysvol
    read only = No
EOF"


sleep 1 
echo "Creating Samba database"
sudo samba-tool domain provision --use-rfc2307 --interactive

echo "Restarting Samba 4 services"
sudo systemctl restart samba-ad-dc
sudo systemctl enable samba-ad-dc
sleep 0.5
echo "Samba 4 deployment completed."
