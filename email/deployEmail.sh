#!/bin/bash


read -p "Enter mail server hostname: " hostname
read -p "Enter mail server domain: " domain
read -p "Enter mail origin: " origin


sudo apt update
sudo apt upgrade -y


sudo apt install -y postfix dovecot-core dovecot-imapd dovecot-pop3d


sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
sudo bash -c "cat << EOF > /etc/postfix/main.cf
myhostname = $hostname
mydomain = $domain
myorigin = $origin
inet_interfaces = all
mydestination = \$myhostname, \$mydomain, localhost.\$mydomain, localhost
mynetworks = 127.0.0.0/8 [::1]/128
relay_domains =
home_mailbox = Maildir/
EOF"


sudo cp /etc/dovecot/dovecot.conf /etc/dovecot/dovecot.conf.bak
sudo bash -c "cat << EOF > /etc/dovecot/dovecot.conf
protocols = imap pop3
disable_plaintext_auth = no
mail_location = maildir:~/Maildir
EOF"


sudo useradd -m mailuser


sudo systemctl restart postfix
sudo systemctl restart dovecot

echo "Mail server deployment completed."
