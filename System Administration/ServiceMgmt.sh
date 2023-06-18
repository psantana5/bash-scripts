#!/bin/bash

# Function to start a service
start_service() {
    service_name=$1
    systemctl start "$service_name"
    echo "Started $service_name"
}

# Function to stop a service
stop_service() {
    service_name=$1
    systemctl stop "$service_name"
    echo "Stopped $service_name"
}

# Function to restart a service
restart_service() {
    service_name=$1
    systemctl restart "$service_name"
    echo "Restarted $service_name"
}

# Main script
echo "Welcome to the Service Manager Script!"
echo "Please choose an option:"
echo "1. Start a service"
echo "2. Stop a service"
echo "3. Restart a service"
read -p "Enter your choice (1-3): " choice

case $choice in
    1)
        read -p "Enter the name of the service to start: " service
        start_service "$service"
        ;;
    2)
        read -p "Enter the name of the service to stop: " service
        stop_service "$service"
        ;;
    3)
        read -p "Enter the name of the service to restart: " service
        restart_service "$service"
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
