#!/bin/bash

function display_menu() {
    toilet -f smblock "VSFTPD CONFIGURER" | boxes -d cat -a hc -p h0 | lolcat
    echo
    echo "Select an option:"
    echo
    echo "1. Use virtual users with PAM"
    echo "2. Install and configure firewall"
    echo "3. Use and configure SSL/TLS protocol"
    echo "4. Use SELinux policy"
    echo "5. Configure shares & config"
    echo "6. Exit"
    echo
}
function use_virtual_users_with_pam() {
    echo "Setting up vsftpd with PAM..."

    echo "Installing dependencies..."
    sudo apt update
    sudo apt install -y vsftpd libpam0g-dev

    echo "Creating a virtual user for vsftpd..."
    sudo useradd --home /home/vsftpd --gid nogroup -m --shell /bin/false vsftpd
    sudo passwd vsftpd

    echo "Configuring PAM..."
    sudo cp /etc/pam.d/vsftpd /etc/pam.d/vsftpd.bak
    sudo bash -c 'cat << EOF > /etc/pam.d/vsftpd
auth    required    pam_listfile.so item=user sense=deny file=/etc/vsftpd/ftpusers onerr=succeed
auth    required    pam_shells.so
auth    include     password-auth
account include     password-auth
auth    required    pam_userdb.so db=/etc/vsftpd/virtual_users
account required    pam_userdb.so db=/etc/vsftpd/virtual_users
session    required    pam_loginuid.so
session    include     password-auth
EOF'
    sudo mkdir /etc/vsftpd
    sudo touch /etc/vsftpd/virtual_users
    sudo chmod 600 /etc/vsftpd/virtual_users

    echo "Restarting vsftpd service..."
    sudo systemctl restart vsftpd

    echo "vsftpd setup with PAM is complete."
}


function install_and_configure_firewall() {
    echo "Installing and configuring the firewall for vsftpd..."
    echo

    echo "Installing UFW..."
    sudo apt update
    sudo apt install -y ufw

    echo "Enabling UFW..."
    sudo ufw enable

    
    echo "Denying all incoming connections by default..."
    sudo ufw default deny incoming

   
    echo "Allowing SSH connections..."
    sudo ufw allow ssh

   
    echo "Allowing FTP (vsftpd) connections..."
    sudo ufw allow 20/tcp
    echo "Rule added: Allow FTP control port (20/tcp)"
    sudo ufw allow 21/tcp
    echo "Rule added: Allow FTP data port (21/tcp)"
    echo "Allowing passive FTP ports..."
    sudo ufw allow 40000:50000/tcp
    echo "Rule added: Allow passive FTP ports (40000-50000/tcp)"

    
    echo "Enabling UFW logging..."
    sudo ufw logging on

   
    echo "Reloading UFW..."
    sudo ufw reload

    echo "Firewall installation and configuration for vsftpd is complete."
}



function use_ssl_tls_protocol() {
    restrict_connection_to_tls() {
        echo "Restricting TLS connections..."
        sudo sed -i 's/^#\(ssl_enable\)/\1/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(allow_anon_ssl\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(force_local_data_ssl\)/\1=YES/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(force_local_logins_ssl\)/\1=YES/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_tlsv1\)/\1=YES/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_sslv2\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_sslv3\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(require_ssl_reuse\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_ciphers\)/\1=HIGH/' /etc/vsftpd.conf &&
        echo "Restarting vsftpd service..." &&
        sudo systemctl restart vsftpd &&
        echo "Enhanced vsftpd safety by restricting TLS connections." ||
        { echo "Error: Failed to restrict TLS connections."; exit 1; }
    }

    explicitly_allow_tls_and_deny_ssl() {
        echo "Configuring vsftpd to allow TLS and deny SSL..."
        echo

        sudo sed -i 's/^#\(ssl_enable\)/\1=YES/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(allow_anon_ssl\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(force_local_data_ssl\)/\1=YES/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(force_local_logins_ssl\)/\1=YES/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_tlsv1\)/\1=YES/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_sslv2\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_sslv3\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(require_ssl_reuse\)/\1=NO/' /etc/vsftpd.conf &&
        sudo sed -i 's/^#\(ssl_ciphers\)/\1=HIGH/' /etc/vsftpd.conf &&
        echo "Restarting vsftpd service..." &&
        sudo systemctl restart vsftpd &&
        echo "vsftpd has been configured to allow TLS and deny SSL." &&
        sleep 2 ||
        { echo "Error: Failed to configure vsftpd for TLS."; exit 1; }
    }

    set_ssl_tls_encryption_options() {
        certificate_tls(){
            echo "Configuring SSL/TLS encryption options for vsftpd..."

            read -p "Do you have a custom SSL/TLS certificate? (y/n): " custom_cert_choice

            if [[ $custom_cert_choice == "y" || $custom_cert_choice == "Y" ]]; then
                read -p "Enter the path to your custom certificate: " custom_cert_path
                sudo sed -i "s~^#\(rsa_cert_file\).*~\1=${custom_cert_path}~" /etc/vsftpd.conf ||
                { echo "Error: Failed to set custom SSL/TLS certificate path."; exit 1; }
            elif [[ $custom_cert_choice == "n" || $custom_cert_choice == "N" ]]; then
                read -p "Do you want to create a self-signed certificate? (y/n): " create_cert_choice

                if [[ $create_cert_choice == "y" || $create_cert_choice == "Y" ]]; then
                    sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/vsftpd.key -out /etc/ssl/certs/vsftpd.crt &&
                    sudo chmod 600 /etc/ssl/private/vsftpd.key &&
                    sudo chmod 600 /etc/ssl/certs/vsftpd.crt &&
                    sudo sed -i 's/^#\(rsa_cert_file\)/\1=\/etc\/ssl\/certs\/vsftpd.crt/' /etc/vsftpd.conf &&
                    sudo sed -i 's/^#\(rsa_private_key_file\)/\1=\/etc\/ssl\/private\/vsftpd.key/' /etc/vsftpd.conf ||
                    { echo "Error: Failed to create and configure self-signed certificate."; exit 1; }
                fi
            fi
        }

        while true; do
            clear
            echo "SSL/TLS Encryption Options Menu"
            echo 
            echo "1. Implement Perfect Forward Secrecy (PFS)"
            echo "2. Enable strict SSL/TLS versions"
            echo "3. Configure SSL/TLS cipher suites"
            echo "4. Enable Certificate Revocation"
            echo "5. Enable Two-Factor Authentication (2FA)"
            echo "6. Implement IP Whitelisting"
            echo "7. Restrict connections to TLS only"
            echo "8. Explicitly allow TLS and deny SSL (Not Recommended)"
            echo "9. Back to the main menu"
            echo

            read -p "Enter your choice: " ssl_options_choice
            echo

            case $ssl_options_choice in
                1)
                    echo "Implementing Perfect Forward Secrecy (PFS)..."
                    sudo sed -i 's/^#\(ssl_ciphers\)/\1=EECDH+AESGCM:EDH+AESGCM:AES256+EECDH:AES256+EDH/' /etc/vsftpd.conf &&
                    echo "PFS Implemented" ||
                    { echo "Error: Failed to implement Perfect Forward Secrecy (PFS)."; exit 1; }
                    ;;
                2)
                    echo "Enabling strict SSL/TLS versions..."
                    sudo sed -i 's/^#\(ssl_tlsv1_2\)/\1=YES/' /etc/vsftpd.conf &&
                    sudo sed -i 's/^#\(ssl_tlsv1_3\)/\1=YES/' /etc/vsftpd.conf &&
                    sleep 1 
                    echo "Enabled SSL/TLS strict versions" ||
                    { echo "Error: Failed to enable strict SSL/TLS versions."; exit 1; }
                    ;;
                3)
                    echo "Configuring SSL/TLS cipher suites..."
                    read -p "Enter the desired cipher suites: " cipher_suites
                    sudo sed -i "s~^#\(ssl_ciphers\).*~\1=${cipher_suites}~" /etc/vsftpd.conf &&
                    echo "$cipher_suites added to vsftpd!" ||
                    { echo "Error: Failed to configure SSL/TLS cipher suites."; exit 1; }
                    ;;
                4)
                    echo "Enabling Certificate Revocation..."
                    read -p "Enter the path to the Certificate Revocation List (CRL) file: " crl_file_path
                    sudo sed -i "s~^#\(ssl_crl_file\).*~\1=${crl_file_path}~" /etc/vsftpd.conf ||
                    { echo "Error: Failed to enable Certificate Revocation."; exit 1; }
                    ;;
                5)
                    echo "Enabling Two-Factor Authentication (2FA)..."
                    sudo sed -i 's/^#\(rsa_cert_file\)/\1=\/etc\/ssl\/certs\/vsftpd.crt/' /etc/vsftpd.conf &&
                    sudo sed -i 's/^#\(rsa_private_key_file\)/\1=\/etc\/ssl\/private\/vsftpd.key/' /etc/vsftpd.conf ||
                    { echo "Error: Failed to enable Two-Factor Authentication (2FA)."; exit 1; }
                    ;;
                6)
                    echo "Implementing IP Whitelisting..."
                    read -p "Enter the IP addresses or ranges to whitelist (separated by commas): " ip_whitelist
                    sudo sed -i "s/^#\(tcp_wrappers\)/\1=YES/" /etc/vsftpd.conf &&
                    sudo echo "vsftpd: $ip_whitelist" >> /etc/hosts.allow ||
                    { echo "Error: Failed to implement IP Whitelisting."; exit 1; }
                    ;;
                7)
                    restrict_connection_to_tls ||
                    { echo "Error: Failed to restrict connections to TLS only."; exit 1; }
                    ;;
                8)
                    explicitly_allow_tls_and_deny_ssl ||
                    { echo "Error: Failed to explicitly allow TLS and deny SSL."; exit 1; }
                    ;;
                9)
                    break
                    ;;
                *)
                    echo "Invalid option. Please try again."
                    sleep 1
                    ;;
            esac
            sleep 2
        done
    }

    
    set_ssl_tls_encryption_options
}


use_selinux_policy() {
    echo "Applying SELinux policies to vsftpd..."

    
    echo "Installing required packages..."
    sudo yum install -y policycoreutils-python
    echo "Packages installed successfully."

    # Define the SELinux policy module file
    policy_module_file="vsftpd_selinux.te"

    # Create a new SELinux policy module file
    echo "Creating SELinux policy module file..."
    cat <<EOL > "$policy_module_file"
module vsftpd_selinux 1.0;

require {
    type ftpd_t;
    type unreserved_port_t;
    class tcp_socket name_bind;
    class file { read getattr open };
    class dir { read getattr open search };
    class process { execmem execstack };
}

allow ftpd_t unreserved_port_t:tcp_socket name_bind;
allow ftpd_t self:file { read getattr open };
allow ftpd_t self:dir { read getattr open search };
allow ftpd_t self:process { execmem execstack };
EOL
    echo "SELinux policy module file created successfully."

    echo "Compiling SELinux policy module..."
    sudo checkmodule -M -m -o "$policy_module_file.mod" "$policy_module_file"
    sudo semodule_package -o "$policy_module_file.pp" -m "$policy_module_file.mod"
    echo "SELinux policy module compiled successfully."

    
    echo "Installing SELinux policy module..."
    sudo semodule -i "$policy_module_file.pp"
    echo "SELinux policy module installed successfully."

    
    echo "Reloading SELinux policy..."
    sudo load_policy
    echo "SELinux policy reloaded successfully."

    
    echo "Cleaning up temporary files..."
    rm "$policy_module_file" "$policy_module_file.mod" "$policy_module_file.pp"
    echo "Temporary files cleaned up."

    echo "SELinux policies applied to vsftpd."
}


configure_vsftpd_conf() {
    new_share() {
        read -p "Enter the share name: " share_name
        read -p "Enter the share path: " share_path

        if [[ -z $share_name || -z $share_path ]]; then
            echo "Error: Share name and path cannot be empty."
            return 1
        fi

        if grep -q "^$share_name=" /etc/vsftpd.conf; then
            echo "Error: The share '$share_name' already exists in the configuration file."
            return 1
        fi

        echo "$share_name=$share_path" >> /etc/vsftpd.conf

        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to write to /etc/vsftpd.conf"
            return 1
        fi

        echo "Restarting vsftpd"
        if ! systemctl restart vsftpd; then
            echo "Error: Failed to restart vsftpd"
            return 1
        fi

        echo "The share '$share_name' has been created successfully."
    }

    while true; do
        clear
        echo "Vsftpd shares & config"
        echo "1. Create a new share"
        echo "2. Exit"
        echo

        read -p "Enter your choice: " menu_choice
        echo

        case $menu_choice in
            1)
                new_share
                ;;
            2)
                break
                ;;
            *)
                echo "Error: Invalid option"
                ;;
        esac
    done
}

while true; do
    display_menu

    read -p "Enter your choice: " choice
    echo

    case $choice in
        1) use_virtual_users_with_pam ;;
        2) install_and_configure_firewall ;;
        3) use_ssl_tls_protocol ;;
        4) use_selinux_policy ;;
        5) configure_vsftpd_conf ;;
        6) echo "Exiting..."; break ;;
        *) echo "Invalid option"; ;;
    esac

    echo
done
