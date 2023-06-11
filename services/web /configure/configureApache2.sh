#!/bin/bash

toilet -f smblock "Apache Configurator" | boxes -d cat -a hc -p h0 | lolcat

while true; do
  echo "OPTION MENU:  "
  echo "Change the default port: (1)"
  echo "Configure Virtual Hosts: (2)"
  echo "Enable .htaccess file: (3)"
  echo "Security Options (4)"
  echo "Exit (0)"

  read -p "What do you wish to do: " option

  if [ "$option" == "1" ]; then
    echo "Change the default port"
    read -p "What port do you want to use? " port
    sudo sed -i "s/Listen 80/Listen $port/g" /etc/apache2/ports.conf
    sleep 1.5
    echo "Restarting the Apache2 service..."
    sudo systemctl restart apache2
    sleep 0.5
    echo "Port successfully changed to $port"
    echo "Press Enter to continue..."
    read
  elif [ "$option" == "2" ]; then
    echo "Configure Virtual Hosts"
    read -p "Enter the domain name: " domain_name
    read -p "Enter the document root directory: " document_root
    read -p "Enter the log directory: " log_directory
    sleep 0.5
    echo "Creating a new .conf file for your Virtual Host"
    sudo touch /etc/apache2/sites-available/$domain_name.conf
    echo "<VirtualHost *:$port>
    ServerName $domain_name
    DocumentRoot $document_root
    ErrorLog $log_directory/$domain_name_error.log
    CustomLog $log_directory/$domain_name_access.log combined
  </VirtualHost>" | sudo tee /etc/apache2/sites-available/$domain_name.conf > /dev/null
    echo "Enabling the Virtual Host"
    sleep 0.5
    sudo a2ensite $domain_name.conf
    echo "Restarting the Apache2 service"
    sudo systemctl restart apache2
    sleep 0.5
    echo "Virtual host $domain_name created successfully"
    echo "Press Enter to continue..."
    read
  elif [ "$option" == "3" ]; then
    echo "Enable .htaccess files "
    sudo sed -i 's/AllowOverride None/AllowOverride All/g' /etc/apache2/apache2.conf
    sleep 0.5
    echo "Restarting Apache2 service"
    sudo systemctl restart apache2
    echo ".htaccess files enabled correctly"
    echo "Press Enter to continue..."
    read
  elif [ "$option" == "4" ]; then
    echo "Disable unnecessary modules (1)"
    echo "Restrict access to the root directory (2)"
    echo "Set up SSL/TLS (3)"
    echo "Update Server (4)"
    echo "Disable server-info directive (5)"
    echo "Restrict unwanted services (6)"
    echo "Back to main menu (0)"
    read -p "What do you want to do: " option1
    if [ "$option1" == "1" ]; then
      echo "Getting the list of enabled modules..."
      enabled_modules=$(apachectl -M | awk '{print $1}')
      echo "Checking the last time of the module file, and disabling it if not used in 6 months"
      for module in $enabled_modules; do
        module_file=$(find /usr/lib/apache2/modules/ -name "$module.so")
        last_modified=$(stat -c %Y $module_file)
        echo "Module removal if older than 6 months and no use"
        six_months_ago=$(date +%s --date="6 months ago")
        if [ $last_modified -lt $six_months_ago ]; then
          sudo a2dismod $module
          echo "Module $module disabled"
        fi
      done
      echo "Restarting Apache2 service..."
      sleep 0.5
      sudo systemctl restart apache2
      echo "Modules disabled successfully."
      echo "Press Enter to continue..."
      read
    elif [ "$option1" == "2" ]; then
      echo "Getting the IP address of the server"
      server_ip=$(hostname -I | awk '{print $1}')
      echo "Creating a new .conf file for the root directory"
      sudo touch /etc/apache2/sites-available/000-default.conf
      echo "Adding the configuration to the file"
      sleep 2
      echo "<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    <Directory />
        Options FollowSymLinks
        AllowOverride None
        Require all denied
    </Directory>
    <Directory /var/www/html>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride None
        Require all granted
    </Directory>
      ErrorLog \${APACHE_LOG_DIR}/error.log
      CustomLog \${APACHE_LOG_DIR}/access.log combined
    </VirtualHost>" | sudo tee /etc/apache2/sites-available/000-default.conf > /dev/null
      echo "Enabling the new configuration..."
      sudo a2ensite 000-default.conf
      sleep 0.5
      echo "Restarting the Apache2 service"
      sudo systemctl restart apache2
      echo "Access to the root directory restricted successfully"
      echo "Press Enter to continue..."
      read
    elif [ "$option1" == "3" ]; then
      echo "Install SSL/TLS"
      echo "Installing the mod_ssl module"
      sudo a2enmod ssl
      echo "Generating a self-signed SSL certificate"
      sleep 0.5
      sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt -subj "/C=US/ST=State/L=City/O=Organization/OU=Department/CN=example.com"
      echo "Adding the SSL configuration to the file"
      echo "<IfModule mod_ssl.c>
    <VirtualHost _default_:443>
        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/html
        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined
        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
        SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
    </VirtualHost>
</IfModule>" | sudo tee /etc/apache2/sites-available/default-ssl.conf > /dev/null
      echo "Enabling the SSL virtual host"
      sleep 1
      sudo a2ensite default-ssl.conf
      echo "Restarting the Apache2 service"
      sleep 1
      sudo systemctl restart apache2
      sleep 1
      echo "TLS/SSL set up successfully"
      echo "Press Enter to continue..."
      read
    elif [ "$option1" == "4" ]; then
      echo "Updating the packages list"
      sudo apt update
      echo "Upgrading the installed packages"
      sleep 0.5
      sudo apt upgrade apache2 -y
      echo "Server updated successfully"
      echo "Press Enter to continue..."
      read
    elif [ "$option1" == "5" ]; then
      echo "Disabling server-info directive"
      sudo sed -i 's/ServerTokens OS/ServerTokens Prod/g' /etc/apache2/conf-available/security.conf
      sudo sed -i 's/ServerSignature On/ServerSignature Off/g' /etc/apache2/conf-available/security.conf
      sleep 0.5
      echo "Restarting the Apache2 service"
      sudo systemctl restart apache2
      echo "server-info directive disabled successfully"
      echo "Press Enter to continue..."
      read
     elif [ $option1 == "6" ]
     then
       read -p "Do you wish to disable unwanted services (CGI, AutoIndex) for Apache2? (y/n) " choice
       if [[ $choice =~ ^[Yy]$ ]]
       then
        echo "Disabling CGI service"
        sleep 0.5
        sudo a2dismod cgi
        echo "Disabling autoindex service"
        sleep 0.5
        a2dismod autoindex
        echo "Restarting Apache2"
        sudo systemctl restart apache2
        echo "Unwanted services disabled correctly"
       else
        echo "No services were disabled"
       fi
    elif [ "$option1" == "0" ]; then
      echo "Returning to the main menu..."
      sleep 0.5
      continue
    else
      echo "Invalid option! Returning to the main menu..."
      sleep 0.5
      continue
    fi
  elif [ "$option" == "0" ]; then
    echo "Exiting the Apache Configurator..."
    sleep 0.5
    break
  else
    echo "Invalid option! Please select a valid option."
    echo "Press Enter to continue..."
    read
  fi
done
