#!/bin/bash

# Define the total number of steps in the script
total_steps=10

# Define the size of the progress bar
progress_bar_size=50

# Define the character used to fill the progress bar
progress_bar_char="#"

# Define the character used to fill the empty space in the progress bar
progress_bar_empty=" "

# Define the format string for the progress bar
progress_bar_format="[%-${progress_bar_size}s] %3d%%"

# Define the current step counter
current_step=0

# Define a function to increment the current step counter and update the progress bar
function increment_step {
    current_step=$((current_step + 1))
    progress=$((current_step * 100 / total_steps))
    filled=$((progress * progress_bar_size / 100))
    empty=$((progress_bar_size - filled))
    printf "\r$progress_bar_format" "${progress_bar_char:0:filled}${progress_bar_empty:0:empty}" "$progress"
}

# Stop Nginx service
echo "Stopping Nginx service..."
sudo systemctl stop nginx
increment_step

# Remove Nginx package
echo "Removing Nginx package..."
sudo apt-get remove --purge nginx
increment_step

# Remove Nginx configuration files
echo "Removing Nginx configuration files..."
sudo rm -rf /etc/nginx
increment_step

# Remove Nginx log files
echo "Removing Nginx log files..."
sudo rm -rf /var/log/nginx
increment_step

# Remove Nginx cache directory
echo "Removing Nginx cache directory..."
sudo rm -rf /var/cache/nginx
increment_step

# Remove Nginx web root directory
echo "Removing Nginx web root directory..."
sudo rm -rf /var/www/html
increment_step

# Remove Nginx user and group
echo "Removing Nginx user and group..."
sudo deluser --remove-home nginx
sudo delgroup nginx
increment_step

# Remove Nginx systemd service
echo "Removing Nginx systemd service..."
sudo rm /etc/systemd/system/nginx.service
increment_step

# Reload systemd daemon
echo "Reloading systemd daemon..."
sudo systemctl daemon-reload
increment_step

# Clean up any residual files or directories
echo "Cleaning up residual files or directories..."
sudo apt-get autoremove --purge
increment_step

echo "Nginx has been completely removed from the system."