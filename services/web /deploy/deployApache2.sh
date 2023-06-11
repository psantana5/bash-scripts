#!/bin/bash

toilet "APACHE2 AUTO-CONFIGURE" -w 120

echo "Updating the package list..."
sudo apt-get update

echo "Upgrading the package list..."
sudo apt-get upgrade

#Installing LAMP stack.

echo "Installing Apache2 Server, LAMP stack"
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql

echo "Allowing Apache through UFW..."

sudo ufw allow in "Apache full"

#Enable SQL, Apache Services.

sudo systemctl enable apache2
sudo systemctl enable mysql

#Starting services

sudo systemctl start apache2
sudo systemctl enable mysql

#Create a MySQL user & database.

read -p "What will be the name of the database: " database
sudo mysql -e "CREATE DATABASE $database"

read -p "What will be the user of the Database?" user
read -s -p "What will be the password of the database user?" password
sudo mysql -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$password';"

echo "Granting all privileges..."
sudo mysql -e "GRANT ALL PRIVILEGES on $database.* TO '$user'@'localhost';"

#Create a new .php file.

echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

#Restart apache2

echo "Restarting Apache2"
sudo systemctl restart apache2
