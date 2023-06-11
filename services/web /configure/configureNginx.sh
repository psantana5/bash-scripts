#!/bin/bash

package_installed() {
  dpkg -s "$1" > /dev/null 2>&1
}

if ! package_installed toilet || ! package_installed boxes || ! package_installed lolcat || ! package_installed git; then
  read -p "Do you want to install the required dependencies (toilet, boxes, lolcat, git)? (y/n) " install_deps

  if [[ $install_deps == "y" || $install_deps == "Y" ]]; then
    sudo apt-get update
    sudo apt-get install toilet boxes lolcat git
  else
    echo "Some required packages are missing. Please install 'toilet', 'boxes', 'lolcat', and 'git' before running this script."
    exit 1
  fi
fi

toilet -f smblock "Nginx Configurator" | boxes -d cat -a hc -p h0 | lolcat

while true; do
    echo "OPTIONS MENU: "
    echo ""
    echo "Change the default port: (1)"
    echo ""
    echo "Configure Virtual Hosts: (2)"
    echo ""
    echo "Enable .htaccess file: (3)"
    echo ""
    echo "Security Options (4)"
    echo ""
    echo "Serve static content (5)"
    echo ""
    echo "Exit (0)"
    echo ""
    read -p "What do you wish to do: " option

    if [ $option == "1" ]; then
        read -p "What's the port you want to use? " port
        sleep 0.5
        echo "Backing up configuration..."
        sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
        echo "Replacing the default port..."
        sleep 0.5
        sudo sed -i "s/listen\s*80;/listen $port;/" /etc/nginx/nginx.conf
        echo "Restarting the Nginx service"
        sleep 0.5
        sudo systemctl restart nginx

    elif [ $option == "2" ]; then
        read -p "Enter the server name (e.g., example.com): " server_name
        read -p "Enter the root directory (e.g., /var/www/html): " root_directory
        sudo tee "/etc/nginx/sites-available/$server_name" > /dev/null <<EOF
server {
    listen 80;
    server_name $server_name;
    root $root_directory;
    index index.html index.htm;

    location / {
        try_files \$uri \$uri/ =404;
    }
}
EOF
        echo "Creating symbolic link..."
        sleep 0.5
        sudo ln -s "/etc/nginx/sites-available/$server_name" "/etc/nginx/sites-enabled/$server_name"
        echo "Restarting Nginx service"
        sleep 0.5
        sudo systemctl restart nginx

    elif [ $option == "3" ]; then
        echo "ATTENTION! THIS WILL INSTALL FURTHER DEPENDENCIES!!!"
        read -p "Do you wish to proceed? y/n " proceed
        if [[ $proceed == "y" || $proceed == "Y" ]]; then
            echo "Cloning the e404/htaccess-for-nginx repository"
            git clone https://github.com/e404/htaccess-for-nginx.git
            sleep 0.5
            echo "Checking current nginx version..."
            nginx_version=$(nginx -v 2>&1)
            echo "Copying files..."
            cp htaccess-for-nginx/ngx_http_htaccess_module.c nginx-$nginx_version/src/http/modules/
            echo "Modifying the Nginx modules file..."
            echo "ngx_http_htaccess_module=yes" >> nginx-$nginx_version/auto/modules
            echo "Compiling and Installing Nginx module"
            cd nginx-$nginx_version
            ./configure --add-module=src/http/modules/ngx_http_htaccess_module
            make
            sudo make install
            echo "Add the htaccess on; and htaccess_types text/plain text/html; lines to the Nginx configuration file"
            sleep 0.5
            sudo sed -i 's/#gzip on;/#gzip on;\n    htaccess on;\n    htaccess_types text\/plain text\/html;/' /etc/nginx/nginx.conf
            echo "Restarting Nginx..."
            sudo systemctl restart nginx
        elif [[ $proceed == "n" || $proceed == "N" ]]; then
            exit
        fi
    elif [ $option == "4" ]; then
     display_menu() {
  echo ""
  echo "Security Options:"
  echo "--------------------------------------"
  echo "Disable unused Nginx modules (1)"
  echo "---------------------------------------"
  echo "Disable the display of Nginx version number (2)"
  echo "----------------------------------------------------------------------------------"
  echo "Set client buffer size to avoid buffer overflow attacks (3)"
  echo "--------------------------------------------------------------"
  echo "Disable HTTP methods that are not necessary (TRACE, DELETE) (4)"
  echo "----------------------------------------------------------------"
  echo "Set up SSL usage (5)"
  echo "------------------------"
  echo "Add security headers to my Nginx configuration (6)"
  echo "------------------------------------------------------"
  echo "File access restriction (7)"
  echo "--------------------------------------------------------"
  echo "Monitor my Nginx web server (8)"
  echo "---------------------------------------------"
  echo "Update Nginx and installed modules (9)"
  echo "---------------------------------------------"
  echo ""
}

disable_unused_modules() {
  echo "Disable unused Nginx modules"
  sleep 0.5
  echo "THE MODULE USAGE THRESHOLD IS 40 DAYS!"
  sleep 1
  module_dir=/usr/lib/nginx/modules
  days=40
  for file in $module_dir/*.so; do
    last_access=$(stat -c %X "$file")
    days_since_access=$(( ($(date +%s) - $last_access) / (60*60*24) ))
  
    if [ $days_since_access -gt $days ]; then
      echo "Disabling module $file"
      mv "$file" "$file.disabled"
    fi
  done
  echo "Reloading Nginx service..."
  sudo systemctl restart nginx
}

hide_version_number() {
  nginx_config="/etc/nginx/nginx.conf"
  echo "Backing up config file..."
  sudo cp "$nginx_config" "$nginx_config.bak"
  sleep 0.5
  echo "Adding the version number hiding directive..."
  sudo sed -i 's/server_tokens.*/server_tokens off;/g' "$nginx_config"
  echo "Restarting Nginx service"
  sudo service nginx restart
}

set_client_buffer() {
  nginx_config="/etc/nginx/nginx.conf"
  sudo cp "$nginx_config" "$nginx_config.bak"
  echo "Adding client max_body_size and client_body_buffer_size"
  sleep 0.5
  echo "Attention! Buffer size for clients will be set at 10 MB."
  sudo sed -i '/http {/a \    client_max_body_size 10m;\n    client_body_buffer_size 10m;' "$nginx_config"
  echo "Restarting the nginx service"
  sudo service nginx restart
}

disable_http_methods() {
  nginx_config="/etc/nginx/nginx.conf"
  sudo cp "$nginx_config" "$nginx_config.bak"
  echo "Adding the deny directives for TRACE and DELETE methods"
  sleep 0.3
  sudo sed -i '/http {/a \    if ($request_method ~* "(TRACE|DELETE)") {\n        return 405;\n    }' "$nginx_config"
  echo "Restarting Nginx service"
  sudo service nginx restart
}

setup_ssl() {
  echo "Creating a self-signed SSL cert"
  sleep 0.5
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/nginx/ssl/nginx.key -out /etc/nginx/ssl/nginx.crt
  echo "Creating a backup of the original Nginx configuration"
  sudo cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bak
  echo "Updating the Nginx SSL configuration"
  sudo sed -i 's/#\s*listen\s*80/listen 443 ssl/' /etc/nginx/nginx.conf
  sudo sed -i '/# the default server/a \ \n\tssl_certificate \/etc\/nginx\/ssl\/nginx.crt\;\n\tssl_certificate_key \/etc\/nginx\/ssl\/nginx.key\;\n' /etc/nginx/nginx.conf
  echo "Restarting the Nginx service"
  sudo service nginx restart
}

add_security_headers() {
  echo "Add security headers..."
  sleep 0.5
  echo "Creating a backup file..."
  sleep 0.5
  nginx_config="/etc/nginx/nginx.conf"
  sudo cp "$nginx_config" "$nginx_config.bak"
  echo "Adding security headers to the nginx.conf file"
  sudo sed -i '/http {/a \    add_header X-Content-Type-Options "nosniff";\n    add_header X-Frame-Options "SAMEORIGIN";\n    add_header X-XSS-Protection "1; mode=block";\n    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;\n    add_header Content-Security-Policy "default-src https:";' "$nginx_config"
  echo "Restarting the Nginx service"
  sudo service nginx restart
}

monitor_web_server(){
  echo "Monitoring the Nginx web server"
  echo ""
  echo "Status will be output to a monitoring log file"
  echo ""
  touch monitoring.log
  echo "REPORT AS OF $(date) for Nginx Server"
  echo "RAM Usage: $(free -h)" >> monitoring.log
  echo "----------------------------------------------------"
  echo "CPU Usage: $(  top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1"%"}')" >> monitoring.log
  echo "-------------------------------------------------------------------------------------------------------------------------------"
  echo "Service Status:$(sudo service nginx status)" >> monitoring.log
  echo "------------------------------------------------------------------"
  echo "Disk usage: $(df -h)" >> monitoring.log
}

file_access_logic(){
  echo "File Access Logic"
  nginx_bak="/etc/nginx/nginx.conf.bak"
  private_dir="/root"
  block_1="/var/www/html"
  block_2="/etc"
  block_3="/var/log"
  block_4="/root/.ssh"
  echo "Creating backup of the original Nginx Configuration"
  sleep 1
  sudo cp "$nginx_config" "$nginx_config_backup"
  echo "Disabling browsing to private directories"
  sleep 0.5
  sudo sed -i '/location \/private\// { /autoindex on;/ s//autoindex off;/ }' "$nginx_config"
  sudo sed -i "/location $block_1/ { /autoindex on;/ s//autoindex off;/ }" "$nginx_config"
  sudo sed -i "/location $block_2/ { /autoindex on;/ s//autoindex off;/ }" "$nginx_config"
  sudo sed -i "/location $block_3/ { /autoindex on;/ s//autoindex off;/ }" "$nginx_config"
  sudo sed -i "/location $block_4/ { /autoindex on;/ s//autoindex off;/ }" "$nginx_config"
  echo "Testing the nginx configuration for errors..."
  sleep 1
  nginx -t
  if [ $? -eq 0 ]; then
    sudo service nginx reload
    echo "Directory browsing disabled for: $private_dir, $block_1, $block_2, $block_3, $block_4"
  else
    echo "There was an error in the Nginx config. Restoring backup file"
    sudo cp "$nginx_bak" "$nginx_config"
    sudo service nginx reload
    echo "Nginx config restored correctly. Directory browsing remains enabled."
  fi
}

update_nginx(){
  echo "Checking for Nginx updates..."
  sudo apt update
  nginx_updates=$(apt list --upgradable 2>/dev/null | grep nginx)
  if [ -n "$nginx_updates" ]; then
    echo "There are updates available for Nginx:"
    echo -e "$nginx_updates"
  else
    echo "Nginx is up to date"
  fi
  echo "Checking for updates to installed Nginx modules..."
  module_dir="/usr/lib/nginx/modules"
  module_updates=""
  for file in $module_dir/*.so; do
    module_name=$(basename "$file")
    module_package=$(dpkg -S "$file" 2>/dev/null | cut -d':' -f1)
    if [ -n "$module_package" ]; then
      module_update=$(apt list --upgradable 2>/dev/null | grep "$module_package")
      if [ -n "$module_update" ]; then
        module_updates+="Module: $module_name\nPackage: $module_package\nUpdate: $module_update\n\n"
      fi
    fi
  done
  if [ -n "$module_updates" ]; then
    echo "There are updates available for installed Nginx modules:"
    echo -e "$module_updates"
  else
    echo "No updates were found for installed Nginx modules"
  fi

}

read_user_choice() {
  read -p "What do you wish to do: " choice
  case $choice in
    1)
      disable_unused_modules
      ;;
    2)
      hide_version_number
      ;;
    3)
      set_client_buffer
      ;;
    4)
      disable_http_methods
      ;;
    5)
      setup_ssl
      ;;
    6)
      add_security_headers
      ;;
    7)
      file_access_logic
      ;;
    8)
      monitor_web_server
      ;;
    9)
      update_nginx
      ;;
    *)
      echo "Invalid choice. Please try again."
      ;;
  esac
}

display_menu
read_user_choice
    elif [ $option == "5" ]; then
      echo "Serve Static Content Options:"
      echo "1. Serve Images"
      echo "2. Serve CSS"
      echo "3. Serve JavaScript"
      read -p "Choose an option: " static_option
      if [ "$static_option" == "1" ]; then
        echo "Configuring Nginx to serve images"
        sleep 0.5
        sudo sed -i 's/#gzip on;/#gzip on;\n location ~* \.(jpg|jpeg|gif|png|ico|bmp|svg)$ {\n expires 30d;\n add_header Pragma public;\n add_header Cache-Control '\''public'\'';\n }/' /etc/nginx/nginx.conf
        echo "Restarting Nginx..."
        sudo systemctl restart nginx
        echo "Nginx succesfully serving images!"
      
      elif [ $static_option == "2" ]; then
        echo "Configure Nginx to serve CSS"
        sleep 0.5
        sudo sed -i 's/#gzip on;/#gzip on;\n    location ~* \.css$ {\n        expires 7d;\n    }/' /etc/nginx/nginx.conf
        echo "Restarting Nginx"
        sudo systemctl restart nginx
        echo "Nginx successfully serving CSS"

      elif [ $static_option == "3" ]; then
        echo "Configure Nginx to serve JS"
        sleep 0.5
        sudo sed -i 's/#gzip on;/#gzip on;\n    location ~* \.js$ {\n        expires 7d;\n    }/' /etc/nginx/nginx.conf
        echo "Restarting Nginx"
        sudo systemctl restart nginx
        echo "Nginx succesfully serving JS"
      else 
        echo "Invalid option, operation canceled."
      fi
      elif [ $option == "0" ]; then
      exit
    fi
done
