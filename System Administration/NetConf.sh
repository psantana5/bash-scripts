#!/bin/bash

# Function to display IP addresses
display_ip_addresses() {
  echo "IP addresses:"
  ifconfig
}

# Function to display network interfaces
display_network_interfaces() {
  echo "Network interfaces:"
  ip link show
}

# Function to display routing table
display_routing_table() {
  echo "Routing table:"
  ip route show
}

# Function to set static IP address
set_static_ip_address() {
  echo "Setting static IP address..."
  read -p "Enter IP address: " ip
  read -p "Enter subnet mask: " subnet
  read -p "Enter gateway: " gateway
  sudo ifconfig eth0 $ip netmask $subnet
  sudo route add default gw $gateway
}

# Function to enable/disable network interface
toggle_network_interface() {
  echo "Enable/disable network interface:"
  read -p "Enter interface name (e.g., eth0): " interface
  read -p "Enter action (enable/disable): " action
  sudo ifconfig $interface $action
}

# Function to flush DNS cache
flush_dns_cache() {
  echo "Flushing DNS cache..."
  sudo systemctl restart network-manager
}

# Function to configure DNS server
configure_dns_server() {
  echo "Configuring DNS server..."
  read -p "Enter DNS server IP address: " dns
  echo "nameserver $dns" | sudo tee /etc/resolv.conf
}

# Function to check network connectivity
check_network_connectivity() {
  echo "Checking network connectivity..."
  ping -c 5 google.com
}

# Function to enable/disable network services
toggle_network_services() {
  echo "Enable/disable network services:"
  read -p "Enter service name (e.g., ssh): " service
  read -p "Enter action (enable/disable): " action
  sudo systemctl $action $service
}

# Function to display network statistics
display_network_statistics() {
  echo "Network statistics:"
  netstat -s
}

# Display main menu
display_main_menu() {
  echo "=== Network Configuration Menu ==="
  echo "1. Network Information"
  echo "2. IP Configuration"
  echo "3. DNS Configuration"
  echo "4. Network Services"
  echo "5. Network Tools"
  echo "6. Exit"
}

# Display network information submenu
display_network_info_submenu() {
  echo "=== Network Information ==="
  echo "1. Display IP addresses"
  echo "2. Display network interfaces"
  echo "3. Display routing table"
  echo "4. Display network statistics"
  echo "5. Go back"
}

# Display IP configuration submenu
display_ip_config_submenu() {
  echo "=== IP Configuration ==="
  echo "1. Set static IP address"
  echo "2. Enable/disable network interface"
  echo "3. Go back"
}

# Display DNS configuration submenu
display_dns_config_submenu() {
  echo "=== DNS Configuration ==="
  echo "1. Flush DNS cache"
  echo "2. Configure DNS server"
  echo "3. Go back"
}

# Display network services submenu
display_network_services_submenu() {
  echo "=== Network Services ==="
  echo "1. Check network connectivity"
  echo "2. Enable/disable network services"
  echo "3. Go back"
}

# Display network tools submenu
display_network_tools_submenu() {
  echo "=== Network Tools ==="
  echo "1. Display listening ports"
  echo "2. Display established connections"
  echo "3. Display interfaces with IP addresses"
  echo "4. Go back"
}

# Main program loop
while true; do
  clear
  display_main_menu

  # Read user's choice
  read -p "Enter your choice (1-6): " main_choice

  case $main_choice in
    1) # Network Information
      while true; do
        clear
        display_network_info_submenu
        read -p "Enter your choice (1-5): " network_info_choice

        case $network_info_choice in
          1) display_ip_addresses ;;
          2) display_network_interfaces ;;
          3) display_routing_table ;;
          4) display_network_statistics ;;
          5) break ;;
          *) echo "Invalid choice. Try again." ;;
        esac
        read -p "Press enter to continue..."
      done
      ;;

    2) # IP Configuration
      while true; do
        clear
        display_ip_config_submenu
        read -p "Enter your choice (1-3): " ip_config_choice

        case $ip_config_choice in
          1) set_static_ip_address ;;
          2) toggle_network_interface ;;
          3) break ;;
          *) echo "Invalid choice. Try again." ;;
        esac
        read -p "Press enter to continue..."
      done
      ;;

    3) # DNS Configuration
      while true; do
        clear
        display_dns_config_submenu
        read -p "Enter your choice (1-3): " dns_config_choice

        case $dns_config_choice in
          1) flush_dns_cache ;;
          2) configure_dns_server ;;
          3) break ;;
          *) echo "Invalid choice. Try again." ;;
        esac
        read -p "Press enter to continue..."
      done
      ;;

    4) # Network Services
      while true; do
        clear
        display_network_services_submenu
        read -p "Enter your choice (1-3): " network_services_choice

        case $network_services_choice in
          1) check_network_connectivity ;;
          2) toggle_network_services ;;
          3) break ;;
          *) echo "Invalid choice. Try again." ;;
        esac
        read -p "Press enter to continue..."
      done
      ;;

    5) # Network Tools
      while true; do
        clear
        display_network_tools_submenu
        read -p "Enter your choice (1-4): " network_tools_choice

        case $network_tools_choice in
          1) display_listening_ports ;;
          2) display_established_connections ;;
          3) display_interfaces_with_ip ;;
          4) break ;;
          *) echo "Invalid choice. Try again." ;;
        esac
        read -p "Press enter to continue..."
      done
      ;;

    6) # Exit
      echo "Exiting..."
      exit 0
      ;;

    *) echo "Invalid choice. Try again." ;;
  esac
  read -p "Press enter to continue..."
done
