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
    elif [ $option == "4"]; then
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
    fi
done
