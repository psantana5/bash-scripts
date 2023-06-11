#!/bin/bash

toilet -f smblock "FTP Deployer - vsftpd " | boxes -d cat -a hc -p h0 | lolcat

install_vsftpd(){
    sudo apt-get update
    sleep 1
    echo "Installing vsftpd server..."
    sleep 1
    apt install vsftpd -y
    sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
    sudo bash -c 'cat << EOF > /etc/vsftpd.conf
anonymous_enable=NO
local_enable=YES
write_enable=YES
chroot_local_user=YES
pasv_min_port=40000
pasv_max_port=40100
EOF'
    sleep 2
    echo "USING MAX PASSIVE PORT 40000"
    sleep 2
    echo "USING MIN PASSIVE PORT 40100"
    sleep 2
    sudo systemctl restart vsftpd

}

function configure_firewall() {
    
    sudo ufw --force enable
    echo "Enabled Firewall"

    echo "Allowing incoming FTP control connections on port 21"
    sudo ufw allow 21/tcp

    echo "Allow incoming FTP data connections for passive mode"
    sudo ufw allow 40000:40100/tcp

    echo "Reloading UFW"
    sudo ufw reload

    echo "Displaying UFW status"
    sudo ufw status
}

install_vsftpd
configure_firewall