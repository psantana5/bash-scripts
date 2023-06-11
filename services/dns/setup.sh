#!/bin/bash

toilet -f smblock "DNS Server Installation" | boxes -d cat -a hc -p h0 | lolcat

downloads(){
    sudo apt-get update
    sudo apt-get upgrade -y

    sleep 2

    sudo apt install -y bind9
}

echo "Now beginning download..."
downloads

start_config(){
    echo "Starting basic setup..."
    sleep 1
    echo "Backing up files..."
    sleep 1
    sudo cp /etc/bind/named.conf.options /etc/bind/named.conf.options.bak
    echo "Setting up forwarders (Using 8.8.8.8, 8.8.4.4)"
    echo ""
    sudo sed -i 's/\/\/.*forwarders/forwarders/' /etc/bind/named.conf.options
    echo ""
    sudo sed -i 's/.*forwarders {/forwarders { 8.8.8.8; 8.8.4.4; };/' /etc/bind/named.conf.options
    echo "Restarting bind9..."
    sleep 1
    sudo systemctl restart bind9
    echo "BIND9 installation completed."
}
start_config