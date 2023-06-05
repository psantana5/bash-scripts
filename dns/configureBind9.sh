#!/bin/bash
#!/bin/bash

check_bind9_installation() {
    echo "Checking if BIND9 is installed..."

    if dpkg -s bind9 &> /dev/null; then
        echo -e "\e[32mBIND9 was found, continuing.\e[0m"
    else
        echo -e "\e[31mBIND9 is not installed.\e[0m"
        echo "Do you want to continue running the script without BIND9? (Y/N)"
        read -r choice

        case $choice in
            [Yy]) echo "Continuing without BIND9." ;;
            [Nn]) echo "Exiting script." ; exit ;;
            *) echo "Invalid choice. Exiting script." ; exit ;;
        esac
    fi
}

check_bind9_installation

toilet -f smblock "bind9 configuration" | boxes -d cat -a hc -p h0 | lolcat

main_menu(){
    echo "Bind 9 Configuration"
    echo "--------------------------------"
    echo "Zone Configuration "
    echo "Name Server Configuration "
    echo "DNS Security "
    echo "Forwarding and Caching "
    echo "Access Control "
    echo "DNS Load Balancing "
    echo "DNS Policies and Redirection "
    echo "Troubleshooting and diagnostics "
    echo "Exit "
    echo "--------------------------------"
}


zone_configuration() {
    show_menu() {
        echo "DNS Management Menu"
        echo "-------------------"
        echo "1. Set up zone configuration"
        echo "2. Map domain name to IP address"
        echo "3. Map IP address to domain name"
        echo "4. Set up zone transfers"
        echo "5. Manage DNS records"
        echo "0. Exit"
        echo "-------------------"
    }

    # Function to set up zone configuration
    set_up_zone() {
        read -p "Enter the zone name (e.g., example.com): " zone_name
        read -p "Enter the zone file name (e.g., db.example.com): " zone_file
        read -p "Enter the zone type (master/slave): " zone_type

        echo "
        zone \"$zone_name\" {
            type $zone_type;
            file \"/etc/bind/$zone_file\";
        };" | sudo tee -a /etc/bind/named.conf

        echo "Creating the zone file..."
        sleep 0.5
        sudo touch "/etc/bind/$zone_file"

        echo "Setting permissions for the zone file..."
        sleep 0.5
        sudo chown bind:bind "/etc/bind/$zone_file"

        echo "Zone configuration for $zone_name has been set up."
        echo "Restarting services now..."
        sleep 0.5
        sudo systemctl restart bind9
    }

    # Function to map domain names to IP addresses
    map_domain_to_ip() {
        read -p "Enter the domain name: " domain_name
        read -p "Enter the IP address: " ip_address

        echo "$domain_name.    IN    A    $ip_address" | sudo tee -a "/etc/bind/$zone_file"

        echo "Domain name '$domain_name' mapped to IP address '$ip_address'."
        echo "Restarting services now..."
        sleep 0.5
        sudo systemctl restart bind9
    }

    # Function to map IP addresses to domains
    map_ip_to_domain() {
        read -p "Enter the IP address: " ip_address
        read -p "Enter the domain name: " domain_name

        echo "$ip_address    IN    PTR    $domain_name." | sudo tee -a "/etc/bind/$zone_file"

        echo "IP address '$ip_address' mapped to domain name '$domain_name'."
        echo "Restarting services now..."
        sleep 0.5
        sudo systemctl restart bind9
    }

    # Function to set up zone transfers
    set_up_zone_transfers() {
        read -p "Enter the zone name for transfer (e.g., example.com): " zone_name
        read -p "Enter the IP address of the secondary DNS server: " secondary_dns_ip

        echo "
        zone \"$zone_name\" {
            type master;
            allow-transfer { $secondary_dns_ip; };
            file \"/etc/bind/$zone_file\";
        };" | sudo tee -a /etc/bind/named.conf

        echo "Zone transfer configured for zone '$zone_name'."
        echo "Restarting services now..."
        sleep 0.5
        sudo systemctl restart bind9
    }

    # Function to manage DNS records
    manage_dns_records() {
        read -p "Enter the domain name: " domain_name
        read -p "Enter the record type (A, AAAA, CNAME, MX, TXT): " record_type
        read -p "Enter the record value: " record_value

        echo "$domain_name.    IN    $record_type    $record_value" | sudo tee -a "/etc/bind/$zone_file"

        echo "DNS record '$record_type' added for domain '$domain_name' with value '$record_value'."
        echo "Restarting services now..."
        sleep 0.5
        sudo systemctl restart bind9
    }

    # Main script
    while true; do
        show_menu
        read -p "Enter your choice (0-5): " choice
        echo

        case $choice in
            1) set_up_zone ;;
            2) map_domain_to_ip ;;
            3) map_ip_to_domain ;;
            4) set_up_zone_transfers ;;
            5) manage_dns_records ;;
            0) exit ;;
            *) echo "Invalid choice. Please try again." ;;
        esac

        echo
    done
}
dns_config() {
    show_dns_config_menu() {
        echo "DNS Configuration Menu"
        echo "----------------------"
        echo "1. Configure BIND9 as a master name server"
        echo "2. Configure BIND9 as a slave name server"
        echo "3. Define server roles"
        echo "4. Set up server IP addresses"
        echo "5. Configure DNS views"
        echo "6. Manage DNS caching"
        echo "0. Exit"
        echo "----------------------"
    }

    configure_master_server() {
        read -p "Enter the master server IP address: " master_ip

        echo "Configuring BIND9 as a master name server..."
        sudo sed -i "s/^masters {.*};/masters { $master_ip; };/" /etc/bind/named.conf.options
        echo "Restarting the bind9 service"
        sudo systemctl restart bind9
        echo "Master server IP address: $master_ip"
        
    }

    configure_slave_server() {
        read -p "Enter the slave server IP address: " slave_ip
        sudo sed -i "s/^allow-transfer {.*};/allow-transfer { $slave_ip; };/" /etc/bind/named.conf.options
        echo "Configuring BIND9 as a slave name server..."
        echo "Master server IP address: $slave_ip"
    }

    define_server_roles() {
        read -p "Enter the server role (primary/secondary): " server_role
        if [[ "$server_role" == "primary" ]]; then
          sudo sed -i "s/^type slave;/type master;/" /etc/bind/named.conf.local
        elif [[ "$server_role" == "secondary" ]]; then
          sudo sed -i "s/^type master;/type slave;/" /etc/bind/named.conf.local
        else
          echo "Invalid server role. Please, choose either primary or secondary"
        fi
        echo "Restarting bind9 service..."
        sleep 0.5
        sudo systemctl restart bind9
    }

    setup_server_ips() {
        read -p "Enter the server IP address: " server_ip
        sudo sed -i "s/^listen-on {.*};/listen-on { $server_ip; };/" /etc/bind/named.conf.options
        sudo sed -i "s/^allow-query {.*};/allow-query { any; };/" /etc/bind/named.conf.options
        echo "Setting up server IP addresses..."
        echo "Server IP address: $server_ip"
        echo "Restarting bind9 service"
        sleep 1
        sudo systemctl restart bind9
    }

    configure_dns_views() {
    read -p "Enter the DNS view name: " view_name
    read -p "Enter the match client IP address (CIDR notation): " match_client_ip

    sudo tee "/etc/bind/views/$view_name.conf" > /dev/null <<EOF
view "$view_name" {
    match-clients { $match_client_ip; };

    # Configure the zone within the view
    read -p "Enter the zone name (e.g., example.com): " zone_name
    read -p "Enter the zone file name (e.g., db.example.com): " zone_file
    read -p "Enter the zone type (master/slave): " zone_type

    zone "$zone_name" {
        type $zone_type;
        file "/etc/bind/$zone_file";
    };
};
EOF

    sudo sed -i "/^include \/etc\/bind\/views\/.*.conf;/d" /etc/bind/named.conf.local
    echo "include \"/etc/bind/views/$view_name.conf\";" | sudo tee -a /etc/bind/named.conf.local > /dev/null

    echo "Configuring DNS views..."
    echo "DNS view name: $view_name"
    }

    manage_dns_caching() {
        show_dns_caching_menu(){
            echo "DNS Caching Management"
            echo "----------------------"
            echo "1. Enable DNS Caching"
            echo "2. Disable DNS Caching"
            echo "0. Exit"
            echo "-----------------------"
        }
        enable_dns_caching(){
            sudo sed -i 's/^dnssec-enable yes;/dnssec-enable no;/' /etc/bind/named.conf.options
            sudo systemctl restart bind9
            echo "DNS caching has been enabled."
        }

        disable_dns_caching(){
          sudo sed -i 's/^dnssec-enable no;/dnssec-enable yes;/' /etc/bind/named.conf.options
          sudo systemctl restart bind9
          echo "DNS caching has been disabled."
        }
        while true; do
          show_dns_caching_menu
          read -p "Enter your choice (0-2):" choice2
          echo

          case $choice2 in
            1) enable_dns_caching ;;
            2) disable_dns_caching ;;
            0) exit ;;
            *) echo "Invalid choice";;
          esac
          echo
        done
    }

    while true; do
        show_dns_config_menu
        read -p "Enter your choice (0-6): " choice
        echo

        case $choice in
            1) configure_master_server ;;
            2) configure_slave_server ;;
            3) define_server_roles ;;
            4) setup_server_ips ;;
            5) configure_dns_views ;;
            6) manage_dns_caching ;;
            0) exit ;;
            *) echo "Invalid choice. Please try again." ;;
        esac

        echo
    done
}

dns_security(){
    configure_dnssec(){
        echo "Configuring DNSSEC..."
        read -p "Enter the zone name (e.g., example.com): " dnssec_zonename
        read -p "Enter the zone file name (e.g., db.example.com): " dnssec_zonefile
        echo "Generating DNSSEC keys for zone $dnssec_zonename..."
        sudo dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE -f KSK $dnssec_zonename
        sudo dnssec-keygen -a NSEC3RSASHA1 -b 2048 -n ZONE $dnssec_zonename
        echo "Signing the zone with DNSSEC keys..."
        sudo dnssec-signzone -A -3 $(head -c 1000 /dev/random | sha1sum | cut -b 1-16) -N INCREMENT -o $dnssec_zonename -t $dnssec_zonefile
        echo "Restarting bind9 service"
        sudo systemctl restart bind9
        echo "DNSSEC Configured Correctly."
    }
    configure_tsig(){
        read -p "Enter the TSIG key name: " key_name
        read -p "Enter the TSIG key algorithm (e.g., hmac-md5): " key_algorithm
        read -p "Enter the TSIG key secret: " key_secret

        echo "Adding the TSIG key to the named.conf.local file..."
        echo "key \"$key_name\" {
        algorithm $key_algorithm;
        secret \"$key_secret\";
        }:" | sudo tee -a /etc/bind/named.conf.local > /dev/null
        echo "TSIG key configuration has been added."
        echo "Restarting bind9 service..."
        sudo systemctl restart bind9
    }
    sec_menu(){
        echo "DNS Security Menu"
        echo "--------------------"
        echo "1. Configure DNSSEC"
        echo "2. Configure TSIG"
        echo "0. Exit"
        echo "---------------------"
    }
    while true; do
      sec_menu
      read -p "Enter your choice (0-2): " choice
      echo

      case $choice in
        1) configure_dnssec ;;
        2) configure_tsig ;;
        0) exit ;;
        *) echo "Invalid choice" ;;
      esac

      echo
    done
}

forward_and_caching(){
    manage_forwarding(){
        read -p "Enter the forwarders (Space separated IP addresses): " forwarders
        read -p "Enable forwarding (yes/no): " enable_forwarding
        if [[ $enable_forwarding == "yes" ]]; then
          echo "options {
          forwarders { $forwarders; };
          forward only;
        };" | sudo tee /etc/bind/named.conf.options > /dev/null

          echo "Forwarding enabled. Forwarders: $forwarders"
        else
          echo "options {
        forwarders {};
    };" | sudo tee /etc/bind/named.conf.options > /dev/null
           echo "Forwarding Disabled"
        fi
        sudo systemctl restart bind9
        echo "Bind9 service has been disabled"
    }
    manage_caching(){
        read -p "Enter the caching duration (In seconds): " caching_duration
        echo "options {
        max-cache-ttl $caching_duration;
        max-ncache-ttl $caching_duration;
    };" | sudo tee /etc/bind/named.conf.options > /dev/null
        echo "Caching duration set to $caching_duration seconds."
        echo "Restarting the Bind9 service"
        sudo systemctl restart bind9
    }
    fwd_menu(){
        echo "DNS Forwarding and Caching Management"
        echo "-------------------------------------"
        echo "1. Manage Forwarding"
        echo "2. Manage Caching"
        echo "0. Exit"
        echo "-------------------------------------"
    }
    while true; do
      fwd_menu
      read -p "Enter your choice (0-2): " choice3
      echo 

      case $choice3 in
        1) manage_forwarding ;;
        2) manage_caching ;;
        0) exit ;;
        *) echo "Invalid Choice"
      esac

      echo
    done
}

access_control(){
    allow_dns_queries(){
        read -p "Enter the IP address or network which you want to allow (CIDR notation): " ip_allow
        echo "acl allowed_clients {
        $ip_allow 
    };
    options {
        allow-query { allowed_clients; };
    };" | sudo tee /etc/bind/named.conf.options > /dev/null
    echo "Access control rule added. DNS queries allowed from: $ip_allow"
    echo "Restarting bind9 service"
    sudo systemctl restart bind9
    }
    deny_dns_queries(){
        read -p "Enter the IP address or network you want to deny (CIDR notation): " ip_deny
        echo "acl denied_clients {
        $ip_deny;
    };

    options {
        allow-query { !denied_clients; };
    };" | sudo tee /etc/bind/named.conf.options > /dev/null
    echo "Access control rule added. DNS queries denied from: $ip_deny"
    echo "Restarting bind9 service"
    sudo systemctl restart bind9
    }
    manage_acl(){
        read -p "Enter the access control action (allow/deny): " action

        if [[ $action == "allow" ]]; then
          allow_dns_queries
        elif [[ $action == "deny" ]]; then
          deny_dns_queries
        else
          echo "Invalid access control action"
          return
        fi
    }
    acl_menu(){
        echo "Access Control Management"
        echo "-------------------------"
        echo "1. Allow DNS Queries"
        echo "2. Deny DNS Queries"
        echo "3. Exit"
        echo "--------------------------"
    }
    while true; do
      acl_menu
      read -p "Enter your choice (0-2): " choice_acl
      echo 

      case $choice_acl in
        1) allow_dns_queries ;;
        2) deny_dns_queries ;;
        0) exit ;;
        *) echo "Invalid choice" ;;
      esac

      echo
    done
}

load_balancing(){
    configure_round_robin(){
        read -p "Enter the zone name (e.g., example.com):  zone_name " 
        read -p "Enter the list of IP addresses participating in load balancing (comma-separated): " ip_addresses
        IFS=',' read -ra ADDR_ARRAY <<< "$ip_addresses"
        echo "Configuring round-robin load balancing for $zone_name..."
        for ip in "${ADDR_ARRAY[@]}"; do
          echo "$zone_name    IN    A    $ip" >> /etc/bind/db.$zone_name
        done
        echo "Restarting the BIND9 service..."
        systemctl restart bind9

        echo "Round-robin load balancing has been configured."
    }
    dns_based(){
        echo "DNS Based Load Balancing"
        echo "\$TTL 60"
        echo "@ IN SOA ns1.example.com. hostmaster.example.com. ("
        echo "  2023060501 ; serial"
        echo "  3600 ; refresh"
        echo "  1800 ; retry"
        echo "  604800 ; expire"
        echo "  60 ; minimum TTL"
        echo ")"
        echo "@ IN NS ns1.example.com."
        echo "@ IN NS ns2.example.com."
        for ((i=0; i<${#ADDR_ARRAY[@]}; i++)); do
          echo "server$i IN A ${ADDR_ARRAY[$i]}"
        done
        echo "example.com IN MX 10 server0"
        for ((i=1; i<${#ADDR_ARRAY[@]}; i++)); do
          echo "example.com IN MX $((i+10)) server$i"
        done
    }
    load_balancing_menu(){
        echo "Load Balancing Configuration Menu"
        echo "---------------------------------"
        echo "1. Configure Round-Robin based Load Balancing"
        echo "2. Configure DNS-Based Load Balancing"
        echo "0. Exit"
        echo "---------------------------------"

        while true; do
          read -p "Enter your choice: (0-2): " balancing_choice
          echo

          case $balancing_choice in
            1) configure_round_robin ;;
            2) dns_based ;;
            0) exit ;;
            *) echo "Invalid Choice"
          esac

          echo

        done
    }
}
dns_policies(){
    dns_policies_menu(){
        echo "DNS Policies Menu"
        echo "-----------------"
        echo "1. DNS-Based Blacklisting"
        echo "2. Redirection of Domain Names or Subdomains"
        echo "3. DNS-Based Content Filtering"
        echo "0. Exit"
        echo "-----------------"
    }
    dns_based_blacklisting(){
        read -p "Enter the domain name to blacklist: " domain_name
        echo "$domain_name IN A 127.0.0.1" | sudo tee -a /etc/bind/blacklist.conf > /dev/null
        echo "DNS-Based blacklisting for $domain_name has been set up."
        echo "Restarting bind9 service..."
        sudo systemctl restart bind9
    }
    redirect_domain(){
        read -p "Enter the domain to redirect: " domain
        read -p "Enter the IP address to redirect to: " red_ip
        echo "$domain IN A $red_ip" | sudo tee -a /etc/bind/redirect.conf > /dev/null
        echo "Domain/Subdomain redirection for $domain to $ip_red has been set up."
        echo "Restarting bind9 service..."
        sudo systemctl restart bind9
    }
    content_filtering(){
        read -p "Enter the domain name to filter: " filter_domain
        read -p "Enter the IP address to redirect filtered requests: " filter_ip
        read -p "Enter the content filtering message: " filter_message
        echo "$filter_domain IN A $filter_ip" | sudo tee -a /etc/bind/content_filtering.conf > /dev/null
        echo "*.$filter_domain IN TXT \"$filter_message\"" | sudo tee -a /etc/bind/content_filtering.conf > /dev/null
        echo ""
        echo "DNS-Based content filtering for $filter_domain has been set up."
        echo "Redirect IP: $filter_ip"
        echo "Filtering message: $filtering_message"
        echo "Restarting bind9 service..."
        sudo systemctl restart bind9
    }
    while true; do
      dns_policies_menu
      read -p "Enter your choice (0-3): " policies_choice
      echo
      
      case $policies_choice in
        1) dns_based_blacklisting ;;
        2) redirect_domain ;;
        3) content_filtering ;;
        0) exit ;;
        *) echo "Invalid choice"

      esac

      echo
    done
}

troubleshooting(){
    analyze_logs(){
        echo "Analyzing bind9 logs for errors"
        log_file="/var/log/named/named.log"
        errors=$(grep -iE 'error|failed|warning' "$log_file")
        if [[ -n $errors ]]; then
          echo "Errors found in the BIND9 log file:"
          echo "$errors"
        else
          echo "No errors were found in the Bind9 log file"
        fi
    }
    check_zone_configuration(){
        echo "Checking zone configuration..."
        config_file=/etc/bind/named.conf
        zones=$(grep -E 'zone\s+"[^"]+"\s+{' "$config_file")
        if [[ -n $zones ]]; then
          echo "Zone configurations found in the BIND9 configuration file:"
          echo "$zones"
        else
          echo "No zone configurations found in the Bind9 configuration file"
        fi
    }
    testing(){
        read -p "Enter the domain name to test: " dig_ip
        echo "Testing DNS resolution using dig..."
        dig_result=$(dig +short "$dig_ip")
        if [[ -n $dig_result ]]; then
          echo "dig output:"
          echo "$dig_result"
        else
          echo "Failed to resolve the domain using dig"
        fi

        echo

        echo "Testing DNS resolution using nslookup"
        nslookup_result=$(nslookup -type=A "$dig_ip" | awk '/^Address: / { print $2 }')
        if [[ -n $nslookup_result ]]; then
          echo "nslookup output:"
          echo "$nslookup_result"
        else
          echo "Failed to resolve the domain using nslookup"
        fi
    }
    commonDNS(){
        echo "Checking for common DNS bind9 errors"
        sleep 2
        echo "Checking if bind9 service is running..."
        if ! systemctl is-active --quiet bind9; then
          echo "BIND9 service is not running."
        fi
        echo "Checking for named.conf syntax errors..."
        named_checkconf_result=$(named-checkconf 2>&1)
        if [[ -n $named_checkconf_result ]]; then
          echo "Errors found in named.conf file:"
          echo "$named_checkconf_result"
        fi
        sleep 1
        echo "Checking zone files for errors..."
        named_checkzone_result=$(named-checkzone $zone_name /etc/bind/$zone_file 2>&1)
        if [[ -n $named_checkzone_result ]]; then
          echo "Errors found in zone file for example.com:"
          echo "$named_checkzone_result"
        fi
        sleep 1
        echo "Checking for DNSSEC configuration errors"
        dnssec_checkzone_result=$(dnssec-checkzone $zone_name /etc/bind/$zone_file 2>&1)
        if [[ -n $dnssec_checkzone_result ]]; then
          echo "DNSSEC configuration errors for $zone_name:"
          echo "$dnssec_checkzone_result"
        fi
        sleep 1
        echo "Checking for stale DNS cache"
        rndc_flush_result=$(rndc flush 2>&1)
        if [[ $rndc_flush_result == *"rndc: connect failed"* ]]; then
          echo "Failed to flush DNS cache: $rndc_flush_result"
        fi
        sleep 1
        echo "DNS error checking completed."
    }
    troubleshooting_menu(){
        echo "Troubleshooting Menu"
        echo "--------------------" 
        echo "1. Analyze logs"
        echo "2. Check Zone Configuration"
        echo "3. Test DNS"
        echo "4. Check common DNS mistakes"
        echo "0. Exit"
        echo "---------------------"
    }
    while true; do
      troubleshooting_menu
      read -p "Enter your choice (0-4): " tr_choice
      echo

      case $tr_choice in 
        1) analyze_logs ;;
        2) check_zone_configuration ;;
        3) testing ;;
        4) commonDNS ;;
      esac

      echo
    done
}
main_menu
read_user_choice(){
    read -p "Enter choice (1-9): " option
      case $option in 
      1)
        zone_configuration
        ;;
      2)
        dns_config
        ;;
      3)
        dns_security
        ;;
      4)
        forward_and_caching
        ;;
      5)
        access_control
        ;;
      6)
        load_balancing
        ;;
      7)
        dns_policies
        ;;
      8)
        troubleshooting
        ;;
      *)
        echo "Option not found. Please, try again"
        ;;    
    esac
}
read_user_choice

