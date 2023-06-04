#!/bin/bash

toilet "Apache remover" -w 140

echo "Stopping the Apache2 service..."
sudo service apache2 stop

sleep 2

echo "Removing all Apache2 packages..."
sudo apt-get remove apache2

sleep 2

echo "Remove all configuration files of Apache2..."
sudo apt-get purge apache2

sleep 2

echo "Using the autoremove option to get rid of other dependencies..."
sudo apt-get autoremove

sleep 2

echo "Checking whether there are any configuration files that have not been removed..."
whereis apache2

sleep 2

echo "Removing the directory and existing configuration files..."
sudo rm -rf /etc/apache2
