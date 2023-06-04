#!/bin/bash

toilet -f smblock "Nginx Configurator" | boxes -d cat -a hc -p h0 | lolcat

while true; do
    echo "OPTION MENU: "
    echo "Change the default port: (1)"
    echo "Configure Virtual Hosts: (2)"
    echo "Enable .htaccess file: (3)"
    echo "Security Options (4)"
    echo "Serve static content (5)"
    echo "Exit (0)"
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
        read -p "Do you wish to proceed? y/n" proceed
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
            break
        fi
    elif [ $option == "4" ]; then
      echo "Security Options: "
      echo "Disable unused Nginx modules (1)"
      echo "Disable the display of Nginx version number to avoid information exposition (2)"
      echo "Set client buffer size to avoid buffer overflow attacks (3)"
      echo "Disable HTTP methods that are not necessary (TRACE, DELETE) (4)"
      echo "Set up SSL usage (5)"
      echo "Add security headers to my Nginx configuration (6)" 
      echo "File access restriction (7)"
      echo "Monitor my Nginx web server (8)"
      echo "Update Nginx and installed modules (9)"

      read -p "What do you wish to do: " choice1
      if [ $choice1 == "1" ]; then
        echo "Disable unused Nginx modules"
        echo "THE MODULE USAGE THRESHOLD IS 40 DAYS!"
        module_dir=/usr/lib/nginx/modules
        days=40
        for file in $module_dir/*.so; do
          last_access=$(stat -c %X "$file")
          days_since_access=$(( ($(date +%s) - $last_access) / (60*60*24) ))
        
          if [ $days_since_access -gt $DAYS ]; then
            echo "Disabling module $file"
            mv "$file" "$file.disabled"
          fi
        done
        echo "Reloading Nginx service..."
        sudo systemctl restart nginx
      fi

    elif [ $option == "2" ]; then
      nginx_config="/etc/nginx/nginx.conf"
      echo "Backing up config file..."
      sudo cp "$nginx_config" "$nginx_config.bak"
      sleep 0.5
      echo "Adding the version number hiding directive..."
      sudo sed -i 's/server_tokens.*/server_tokens off;/g' "$nginx_config"
      echo "Restarting Nginx service"
      sudo service nginx restart
      
    elif [ $option == "3" ]; then
      sudo cp "$nginx_config" "$nginx_config.bak"
      echo "Adding client max_body_size and client_body_buffer_size"
      sleep 0.5
      echo "Attention! Buffer size for clients will be set at 10 MB."
      sudo sed -i '/http {/a \    client_max_body_size 10m;\n    client_body_buffer_size 10m;' "$nginx_config"
      echo "Restarting the nginx service"
      sudo service nginx restart 
    
    elif [ $option == "4" ]; then
      sudo cp "$nginx_config" "$nginx_config.bak"
      echo "Adding the deny directives for TRACE and DELETE methods"
      sleep 0.3
      sudo sed -i '/http {/a \    if ($request_method ~* "(TRACE|DELETE)") {\n        return 405;\n    }' "$nginx_config"
      echo "Restarting Nginx service"
      sudo service nginx restart
    
    elif [ $option == "5" ]; then
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
    
    elif [ $option == "6" ]; then
      echo "Add security headers..."
      sleep 0.5
      echo "Creating a backup file..."
      sleep 0.5
      sudo cp "$nginx_config" "$nginx_config.bak"
      echo "Adding security headers to the nginx.conf file"
      sudo sed -i '/http {/a \    add_header X-Content-Type-Options "nosniff";\n    add_header X-Frame-Options "SAMEORIGIN";\n    add_header X-XSS-Protection "1; mode=block";\n    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;\n    add_header Content-Security-Policy "default-src https:";' "$nginx_config"
      echo "Restarting the Nginx service"
      sudo service nginx restart
    elif [ $option == "7" ]; then
      echo "Set up file access restriction"
      sleep 0.5
      echo "Backing up the config files"
      sudo cp "$nginx_conf" "$nginx_conf.bak"
      sudo sed -i '/http {/a \    location ~ /(config|\.ht|\.git|\.env) {\n        deny all;\n        return 403;\n    }' "$nginx_config"
      function disallow_folders(){
        local nginx_config="$1"
        local folders=("/etc", "/var", "/home", "/usr/local")
        for folder in "${folders[@]}"; do
          sudo sed -i "/http {/a \    location ~ ^/$folder(/|\$) {\n        deny all;\n        return 403;\n    }" "$nginx_config"
        done
      }
      disallow_folders "$nginx_config"
      echo "Restarting the nginx service"
      sudo service nginx restart

    elif [ $option == "8"] ; then
      check_cpu(){
        cpu_usage=$(top -bn1 | grep load | awk '{printf "%.2f%%\n", $(NF-2)}')
        echo "CPU Usage: $cpu_usage"
        echo "CPU Usage Info will now be output to a monitoring log file."
        echo "CPU Usage: $cpu_usage" >> monitoring.log
      }
      check_ram(){
        ram_usage=$(free -m | awk '/Mem:/ { printf "%.2f%%\n", ($3/$2)*100 }')
        echo "RAM Usage: $ram_usage"
        echo "RAM Usage will now be output to a monitoring log file"
        echo "RAM Usage: $ram_usage" >> monitoring.log
      }
      check_disk(){
        disk_usage=$(df -h / | awk '/\// {print $5}')
        echo "Disk Usage: $disk_usage"
        echo "Disk Usage will now be output to a monitoring log file"
        echo "Disk Usage: $disk_usage" >> monitoring.log
      }
      check_service(){
        service_status=$(systemctl is-active nginx)
        echo "Nginx Service Status: $service_status"
        echo "Nginx Service Status will now be output to a log monitoring file"
        echo "Nginx Service Status: $service_status" >> monitoring.log
      }

      #MAIN SCRIPT

      while true; do
          echo "-------------------------"
          echo "Nginx Configuration Menu"
          echo "-------------------------"
          echo "1. Check CPU Usage"
          echo "2. Check RAM Usage"
          echo "3. Check Disk Usage"
          echo "4. Check Nginx Service Status"
          echo "5. Exit"

          read -p "Choose an option: " option

          if [ $option == "1" ]; then
            check_cpu
          elif [ $option == "2" ]; then
            check_ram
          elif [ $option == "3" ]; then
           check_disk
          elif [ $option == "4" ]; then
            check_service
          elif [ $option == "5" ]; then
           echo "Bye :)"
           exit
          else
            echo "Invalid Option. Please choose a valid option"
          fi
      done

        
    elif [ $option == "9" ]; then
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
    fi
done
