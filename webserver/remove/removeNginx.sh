#!/bin/bash

# Stop Nginx service
sudo systemctl stop nginx

# Remove Nginx package
sudo apt-get remove --purge nginx

# Remove Nginx configuration files
sudo rm -rf /etc/nginx

# Remove Nginx log files
sudo rm -rf /var/log/nginx

# Remove Nginx cache directory
sudo rm -rf /var/cache/nginx

# Remove Nginx web root directory
sudo rm -rf /var/www/html

# Remove Nginx user and group
sudo deluser --remove-home nginx
sudo delgroup nginx

# Remove Nginx systemd service
sudo rm /etc/systemd/system/nginx.service

# Reload systemd daemon
sudo systemctl daemon-reload

# Clean up any residual files or directories
sudo apt-get autoremove --purge

echo "Nginx has been completely removed from the system."