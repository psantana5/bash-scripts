#!/bin/bash

toilet -f smblock "DNS Server Removal" | boxes -d cat -a hc -p h0 | lolcat

echo "Stopping BIND9 service..."
sudo systemctl stop bind9
echo "BIND9 service stopped."

echo "Uninstalling BIND9..."
sudo apt purge -y bind9 bind9utils bind9-doc
echo "BIND9 uninstalled."

echo "Removing BIND9 configuration files..."
sudo rm -rf /etc/bind
echo "BIND9 configuration files removed."

echo "Removing BIND9 data directory..."
sudo rm -rf /var/cache/bind
echo "BIND9 data directory removed."

echo "Removing BIND9 log files..."
sudo rm -rf /var/log/named
echo "BIND9 log files removed."

echo "BIND9 removal completed."

