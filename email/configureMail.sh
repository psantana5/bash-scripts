#!/bin/bash


configure_domain() {
    read -p "Enter your domain name: " domain
    read -p "Enter your DNS server IP: " dns_ip

    
    sudo hostnamectl set-hostname mail.$domain

    
    echo "127.0.0.1 localhost" | sudo tee /etc/hosts
    echo "127.0.1.1 mail.$domain mail" | sudo tee -a /etc/hosts

    
    if grep -q "nameserver $dns_ip" /etc/resolv.conf; then
        echo "Using local DNS server configuration."
    else
        echo "nameserver $dns_ip" | sudo tee /etc/resolv.conf
    fi

    echo "Domain configuration completed."
}


configure_dns() {
    local_dns=$(grep -E '^nameserver' /etc/resolv.conf | awk '{print $2}' | paste -sd ',')

    if [[ -n $local_dns ]]; then
        echo "Local DNS servers found: $local_dns"
        echo "Adding local DNS servers to DNS configuration..."

        echo "nameserver $local_dns" | sudo tee -a /etc/resolv.conf >/dev/null
    else
        echo "No local DNS servers found. Setting up DNS..."

        
        read -p "Enter DNS server addresses (comma-separated): " dns_servers
        IFS=',' read -ra dns_servers_array <<< "$dns_servers"

        # Set up DNS configuration with user-provided DNS servers
        for dns_server in "${dns_servers_array[@]}"; do
            echo "nameserver $dns_server" | sudo tee -a /etc/resolv.conf >/dev/null
        done
    fi

    echo "DNS configuration completed."
}



install_certificates() {
    read -p "Enter your domain name: " domain
    read -p "Enter your email address for certificate management: " email

    
    sudo apt update
    sudo apt install -y certbot

    
    sudo certbot certonly --standalone -d mail.$domain --agree-tos --email $email --non-interactive

    
    sudo cp /etc/postfix/main.cf /etc/postfix/main.cf.bak
    sudo bash -c "cat << EOF > /etc/postfix/main.cf
    ...
    smtpd_tls_cert_file = /etc/letsencrypt/live/mail.$domain/fullchain.pem
    smtpd_tls_key_file = /etc/letsencrypt/live/mail.$domain/privkey.pem
    ...
    EOF"

    sudo cp /etc/dovecot/conf.d/10-ssl.conf /etc/dovecot/conf.d/10-ssl.conf.bak
    sudo bash -c "cat << EOF > /etc/dovecot/conf.d/10-ssl.conf
    ...
    ssl_cert = </etc/letsencrypt/live/mail.$domain/fullchain.pem
    ssl_key = </etc/letsencrypt/live/mail.$domain/privkey.pem
    ...
    EOF"

    echo "SSL/TLS certificate installation completed."
}



configure_firewall() {
   
    sudo ufw allow ssh

    
    sudo ufw allow 25

    
    sudo ufw allow 143

    
    sudo ufw allow 110
    
    sudo ufw enable

    echo "Firewall rules configured."
}


enable_ids_ips() {
    
    sudo apt update
    sudo apt install -y snort

   
    sudo cp /etc/snort/snort.conf /etc/snort/snort.conf.bak
    sudo sed -i 's/# output alert_syslog: LOG_AUTH LOG_ALERT/output alert_syslog: LOG_AUTH LOG_ALERT/' /etc/snort/snort.conf
    sudo sed -i 's/# output alert_fast: alert/drop/output alert_fast: alert/drop/' /etc/snort/snort.conf

    
    sudo sed -i 's/include \$RULE\_PATH/#include \$RULE\_PATH/' /etc/snort/snort.conf
    sudo echo "include \$RULE_PATH/local.rules" | sudo tee -a /etc/snort/snort.conf

    
    sudo touch /etc/snort/rules/local.rules
    sudo chown snort:snort /etc/snort/rules/local.rules

    
    sudo systemctl enable snort
    sudo systemctl start snort

    echo "Intrusion Detection and Prevention (IDS/IPS) enabled."
}



enable_spam_filtering() {
    
    sudo apt update
    sudo apt install -y spamassassin

    
    sudo sed -i 's/ENABLED=0/ENABLED=1/' /etc/default/spamassassin

    sudo systemctl enable spamassassin
    sudo systemctl start spamassassin

    echo "Spam filtering enabled."
}


while true; do
    echo "-------------------------------------"
    echo "          Mail Server Menu            "
    echo "-------------------------------------"
    echo "1. Configure Domain"
    echo "2. Setup DNS"
    echo "3. Install SSL/TLS Certificates"
    echo "4. Configure Firewall"
    echo "5. Enable IDS/IPS"
    echo "6. Enable Spam Filtering"
    echo "7. Quit"
    echo "-------------------------------------"

    read -p "Enter your choice [1-7]: " choice
    echo

    case $choice in
        1)
            configure_domain
            ;;
        2)
            setup_dns
            ;;
        3)
            install_certificates
            ;;
        4)
            configure_firewall
            ;;
        5)
            enable_ids_ips
            ;;
        6)
            enable_spam_filtering
            ;;
        7)
            echo "Exiting..."
            exit 0
            ;;
        *)
            echo "Invalid choice. Please enter a valid option."
            ;;
    esac

    echo
done

