#!/bin/bash

toilet -f smblock "User Management" | boxes -d cat -a hc -p h0 | lolcat

user_conf(){
  echo 
  echo "USER RELATED CONFIGURATION"
  echo "---------------------------"
  echo "1. User Creation"
  echo "2. User Modification"
  echo "3. User Deletion"
  echo "4. User Permission"
  echo "5. User Groups"
  echo "0. Exit"
  echo
}


other_conf(){
  echo
  echo "OTHER USER RELATED CONFIGURATION"
  echo "--------------------------------"
  echo "6. Password Policies"
  echo "7. User Activity Monitoring"
  echo "8. User Authentication"
  echo "0. Exit"
  echo 
}

create_user() {
    clear
    echo "User Creation Menu"
    echo "-------------------"

    # Validate and sanitize username
    while true; do
        echo "Enter the username for the new user:"
        read -p "> " username

        if [[ -z $username ]]; then
            echo "Username cannot be empty. Please try again."
        else
            # Check if username contains only alphanumeric characters
            if [[ ! $username =~ ^[[:alnum:]]+$ ]]; then
                echo "Username should only contain alphanumeric characters. Please try again."
            else
                break
            fi
        fi
    done

    # Validate and sanitize password
    while true; do
        echo "Enter the password for the new user:"
        read -s -p "> " password
        echo

        if [[ -z $password ]]; then
            echo "Password cannot be empty. Please try again."
        else
            break
        fi
    done

    echo "Do you want to create a home directory for the user? (y/n)"
    read -p "> " home

    if [[ $home =~ ^[Yy]$ ]]; then
        echo "Do you want to add the user to a group? (y/n)"
        read -p "> " group

        if [[ $group =~ ^[Yy]$ ]]; then
            # Validate and sanitize groupname
            while true; do
                echo "Enter the group name:"
                read -p "> " groupname

                if [[ -z $groupname ]]; then
                    echo "Group name cannot be empty. Please try again."
                else
                    # Check if groupname contains only alphanumeric characters
                    if [[ ! $groupname =~ ^[[:alnum:]]+$ ]]; then
                        echo "Group name should only contain alphanumeric characters. Please try again."
                    else
                        break
                    fi
                fi
            done

            echo "Creating user '$username' with home directory and adding to group '$groupname'..."
            sudo useradd -g $groupname -m $username
        else
            echo "Creating user '$username' with home directory..."
            sudo useradd -m $username
        fi

        echo "Setting password for user '$username'..."
        echo "$username:$password" | sudo chpasswd
    else
        echo "Creating user '$username' without a home directory..."
        sudo useradd -M $username
    fi

    echo "User creation completed successfully!"
}

mod_user() {
    clear
    echo "User Modification Menu"
    echo "----------------------"

    while true; do
        read -p "Enter the username of the user you want to modify: " username

        if [[ -z $username ]]; then
            echo "Username cannot be empty. Please try again."
        elif ! id "$username" >/dev/null 2>&1; then
            echo "User '$username' not found. Please try again."
        else
            break
        fi
    done

    echo "User '$username' found."

    change_username() {
        while true; do
            read -p "Enter the new username: " new_username

            if [[ -z $new_username ]]; then
                echo "Username cannot be empty. Please try again."
            elif ! [[ $new_username =~ ^[[:alnum:]_]+$ ]]; then
                echo "Username should only contain alphanumeric characters and underscores. Please try again."
            else
                sudo usermod -l "$new_username" "$username"
                echo "Username changed to '$new_username'."
                break
            fi
        done
    }

    change_password() {
        sudo passwd "$username"
    }

    change_uid() {
        while true; do
            read -p "Enter the new UID: " new_uid

            if [[ -z $new_uid ]]; then
                echo "UID cannot be empty. Please try again."
            elif ! [[ $new_uid =~ ^[0-9]+$ ]]; then
                echo "UID should be a numeric value. Please try again."
            else
                sudo usermod -u "$new_uid" "$username"
                echo "UID changed to '$new_uid'."
                break
            fi
        done
    }

    change_gid() {
        while true; do
            read -p "Enter the new GID: " new_gid

            if [[ -z $new_gid ]]; then
                echo "GID cannot be empty. Please try again."
            elif ! [[ $new_gid =~ ^[0-9]+$ ]]; then
                echo "GID should be a numeric value. Please try again."
            else
                sudo usermod -g "$new_gid" "$username"
                echo "GID changed to '$new_gid'."
                break
            fi
        done
    }

    change_home_directory() {
        read -p "Enter the new home directory: " new_home

        if [[ -z $new_home ]]; then
            echo "Home directory cannot be empty. Please try again."
        else
            sudo usermod -d "$new_home" "$username"
            echo "Home directory changed to '$new_home'."
        fi
    }

    change_default_shell() {
        read -p "Enter the new default shell: " new_shell

        if [[ -z $new_shell ]]; then
            echo "Default shell cannot be empty. Please try again."
        else
            sudo chsh -s "$new_shell" "$username"
            echo "Default shell changed to '$new_shell'."
        fi
    }

    modify_group_membership() {
        echo "Current groups for '$username':"
        groups "$username"
        echo

        while true; do
            read -p "Enter the group to add or remove from: " groupname

            if [[ -z $groupname ]]; then
                echo "Group name cannot be empty. Please try again."
            else
                read -p "Add or remove from the group? (add/remove): " action

                if [[ $action == "add" ]]; then
                    sudo usermod -aG "$groupname" "$username"
                    echo "User '$username' added to group '$groupname'."
                elif [[ $action == "remove" ]]; then
                    sudo deluser "$username" "$groupname"
                    echo "User '$username' removed from group '$groupname'."
                else
                    echo "Invalid action. Please try again."
                fi

                break
            fi
        done
    }

    while true; do
        echo "What attribute would you like to modify?"
        echo "1. Change username"
        echo "2. Change password"
        echo "3. Change UID"
        echo "4. Change GID"
        echo "5. Change home directory"
        echo "6. Change default shell"
        echo "7. Modify group membership"
        echo "0. Exit"

        read -p "> " choice

        case $choice in
            1) change_username ;;
            2) change_password ;;
            3) change_uid ;;
            4) change_gid ;;
            5) change_home_directory ;;
            6) change_default_shell ;;
            7) modify_group_membership ;;
            0) echo "Exiting user modification menu."; break ;;
            *) echo "Invalid choice. Please try again." ;;
        esac
    done
}

del_user() {
    # Function to validate and sanitize input
    validate_input() {
        local input=$1
        local pattern=$2

        if [[ -z $input ]]; then
            echo "Input cannot be empty. Please try again."
            return 1
        fi

        if [[ ! $input =~ $pattern ]]; then
            echo "Invalid input. Please try again."
            return 1
        fi
    }

    # Function to delete a user
    delete_user() {
        echo "User Deletion Menu"
        echo "------------------"

        while true; do
            read -p "Enter the username to delete: " username
            validate_input "$username" "^[[:alnum:]_][[:alnum:]_-]*$"
            if [[ $? -eq 0 ]]; then
                break
            fi
        done

        echo "Deleting user '$username'..."
        sudo userdel -r "$username"
        echo "User deletion completed."
    }

    # Function to delete a group
    delete_group() {
        echo "Group Deletion Menu"
        echo "-------------------"

        while true; do
            read -p "Enter the group name to delete: " groupname
            validate_input "$groupname" "^[[:alnum:]_][[:alnum:]_-]*$"
            if [[ $? -eq 0 ]]; then
                break
            fi
        done

        echo "Deleting group '$groupname'..."
        sudo groupdel "$groupname"
        echo "Group deletion completed."
    }

    # Main menu
    while true; do
        clear
        echo "User and Group Management"
        echo "------------------------"
        echo "1. Delete User"
        echo "2. Delete Group"
        echo "3. Exit"
        echo

        read -p "Enter your choice: " choice

        case $choice in
            1) delete_user ;;
            2) delete_group ;;
            3) echo "Exiting..."; exit ;;
            *) echo "Invalid choice. Please try again." ;;
        esac

        read -p "Press Enter to continue..."
    done
}
perm_user() {
    clear
    echo "User Permissions Management"
    echo "---------------------------"

    while true; do
        echo "Enter the username:"
        read -p "> " username

        if [[ -z $username ]]; then
            echo "Username cannot be empty. Please try again."
        else
            if [[ ! $username =~ ^[[:alnum:]]+$ ]]; then
                echo "Username should only contain alphanumeric characters. Please try again."
            else
                break
            fi
        fi
    done

    echo "Select the permission option:"
    echo "1. Set file/directory permissions"
    echo "2. Change ownership"
    echo "3. Modify group memberships"
    echo "4. Manage sudo privileges"
    echo "5. Control network permissions"
    echo "6. Configure service permissions"
    echo "7. Adjust system configuration"
    read -p "> " option

    case $option in
        1)
            set_permissions
            ;;
        2)
            change_ownership
            ;;
        3)
            modify_group_memberships
            ;;
        4)
            manage_sudo_privileges
            ;;
        5)
            control_network_permissions
            ;;
        6)
            configure_service_permissions
            ;;
        7)
            adjust_system_configuration
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
}

perm_user() {
    clear
    echo "User Permissions Management"
    echo "---------------------------"

    while true; do
        echo "Enter the username:"
        read -p "> " username

        if [[ -z $username ]]; then
            echo "Username cannot be empty. Please try again."
        else
            if [[ ! $username =~ ^[[:alnum:]]+$ ]]; then
                echo "Username should only contain alphanumeric characters. Please try again."
            else
                break
            fi
        fi
    done

    echo "Select the permission option:"
    echo "1. Set file/directory permissions"
    echo "2. Change ownership"
    echo "3. Modify group memberships"
    echo "4. Manage sudo privileges"
    echo "5. Control network permissions"
    echo "6. Configure service permissions"
    echo "7. Adjust system configuration"
    read -p "> " option

    case $option in
        1)
            set_permissions
            ;;
        2)
            change_ownership
            ;;
        3)
            modify_group_memberships
            ;;
        4)
            manage_sudo_privileges
            ;;
        5)
            control_network_permissions
            ;;
        6)
            configure_service_permissions
            ;;
        7)
            adjust_system_configuration
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac

  set_permissions() {
    clear
    echo "Set File/Directory Permissions"
    echo "-----------------------------"

    echo "Enter the file/directory path:"
    read -p "> " path

    if [[ -z $path ]]; then
        echo "Path cannot be empty. Please try again."
        return
    fi

    echo "Enter the permission mode (e.g., 755, 644):"
    read -p "> " mode

    if [[ ! $mode =~ ^[0-7]{3}$ ]]; then
        echo "Invalid permission mode. Please try again."
        return
    fi

    chmod $mode $path

    echo "Permissions set for $path successfully."
    sleep 1
  }

  change_ownership() {
    clear
    echo "Change Ownership"
    echo "----------------"

    echo "Enter the file/directory path:"
    read -p "> " path

    if [[ -z $path ]]; then
        echo "Path cannot be empty. Please try again."
        return
    fi

    echo "Enter the new owner:"
    read -p "> " owner

    if [[ -z $owner ]]; then
        echo "Owner cannot be empty. Please try again."
        return
    fi

    chown $owner $path

    echo "Ownership changed for $path successfully."
    sleep 1
  }

  modify_group_memberships() {
    clear
    echo "Modify Group Memberships"
    echo "-----------------------"

    echo "Enter the username:"
    read -p "> " username

    if [[ -z $username ]]; then
        echo "Username cannot be empty. Please try again."
        return
    fi

    echo "Enter the group:"
    read -p "> " group

    if [[ -z $group ]]; then
        echo "Group cannot be empty. Please try again."
        return
    fi

    usermod -aG $group $username

    echo "User $username added to group $group successfully."
    sleep 1
  }

  manage_sudo_privileges() {
    clear
    echo "Manage Sudo Privileges"
    echo "----------------------"

    echo "Enter the username:"
    read -p "> " username

    if [[ -z $username ]]; then
        echo "Username cannot be empty. Please try again."
        return
    fi

    usermod -aG sudo $username

    echo "Sudo privileges granted to user $username successfully."
    sleep 1
  }

  control_network_permissions() {
    clear
    echo "Control Network Permissions"
    echo "---------------------------"

    # TODO: Implement network permission control logic

    echo "Network permissions controlled successfully."
    sleep 1
  }

  configure_service_permissions() {
    clear
    echo "Configure Service Permissions"
    echo "----------------------------"

    # TODO: Implement service permission configuration logic

    echo "Service permissions configured successfully."
    sleep 1
  }

  adjust_system_configuration() {
    clear
    echo "Adjust System Configuration"
    echo "---------------------------"

    # TODO: Implement system configuration adjustment logic

    echo "System configuration adjusted successfully."
    sleep 1
  }
}
grp_user() {
    create_group() {
        read -p "Enter the group name: " group_name

        if grep -q "^$group_name:" /etc/group; then
            echo "Error: Group '$group_name' already exists."
            return 1
        fi

        groupadd $group_name
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to create group '$group_name'."
            return 1
        fi

        echo "Group '$group_name' has been created successfully."
    }

    delete_group() {
        read -p "Enter the group name to delete: " group_name

        if ! grep -q "^$group_name:" /etc/group; then
            echo "Error: Group '$group_name' does not exist."
            return 1
        fi

        groupdel $group_name
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to delete group '$group_name'."
            return 1
        fi

        echo "Group '$group_name' has been deleted successfully."
    }

    list_groups() {
        echo "List of groups:"
        awk -F: '{print $1}' /etc/group
    }

    manage_groups() {
        while true; do
            clear
            echo "Group Management"
            echo "------------------"
            echo "1. Create a group"
            echo "2. Delete a group"
            echo "3. List all groups"
            echo "4. Exit"
            echo

            read -p "Enter your choice: " menu_choice
            echo

            case $menu_choice in
                1)
                    create_group
                    ;;
                2)
                    delete_group
                    ;;
                3)
                    list_groups
                    ;;
                4)
                    break
                    ;;
                *)
                    echo "Error: Invalid option"
                    ;;
            esac
            echo
            read -p "Press Enter to continue..."
        done
    }

    
    manage_groups
}

pwd_policies() {
    apply_global_policies() {
        read -p "Enter the minimum password length: " min_length

        # Set global password policies
        sudo passwd -n $min_length
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set global password policies."
            return 1
        fi

        echo "Global password policies have been set successfully."
    }

    apply_user_specific_policies() {
        read -p "Enter the username: " username
        read -p "Enter the minimum password length: " min_length

        # Set user-specific password policies
        sudo chage -M $min_length $username
        if [[ $? -ne 0 ]]; then
            echo "Error: Failed to set password policies for user '$username'."
            return 1
        fi

        echo "Password policies for user '$username' have been set successfully."
    }

    while true; do
        clear
        echo "Password Policy Management"
        echo "----------------------------"
        echo "1. Apply global password policies"
        echo "2. Apply user-specific password policies"
        echo "3. Exit"
        echo

        read -p "Enter your choice: " menu_choice
        echo

        case $menu_choice in
            1)
                apply_global_policies
                ;;
            2)
                apply_user_specific_policies
                ;;
            3)
                break
                ;;
            *)
                echo "Error: Invalid option"
                ;;
        esac
        echo
        read -p "Press Enter to continue..."
    done
}
monitoring() {  
    check_webmin_installation() {
        if dpkg -s webmin >/dev/null 2>&1; then
            echo "Webmin is already installed."
            return 0
        else
            echo "Webmin is not installed."
            return 1
        fi
    }

    install_webmin() {
        read -p "Webmin is not installed. Do you want to install it? (y/n): " install_choice

        if [[ $install_choice == "y" || $install_choice == "Y" ]]; then
            echo "Installing Webmin..."

            # Install dependencies
            apt-get update
            apt-get install -y perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions

            # Download and install Webmin package
            wget http://prdownloads.sourceforge.net/webadmin/webmin_1.981_all.deb
            dpkg --install webmin_1.981_all.deb

            if [[ $? -ne 0 ]]; then
                echo "Error: Failed to install Webmin."
                return 1
            fi

            echo -e "\e[31mWebmin has been installed successfully.\e[0m"
            echo -e "\e[31mYou will need a web interface to access Webmin.\e[0m"
        else
            echo "Webmin installation skipped."
            return 1
        fi
    }

    setup_webmin() {
        echo "Setting up Webmin..."

        echo "Starting Webmin"
        systemctl start webmin

        echo "Enabling Webmin on startup..."
        systemctl enable webmin

        echo "Webmin has been set up successfully."
    }

    prepare_webmin() {
        if check_webmin_installation; then
            setup_webmin
        else
            install_webmin
            if [[ $? -ne 0 ]]; then
                return 1
            fi

            setup_webmin
        fi

        echo "Webmin is ready for use."
    }

    prepare_webmin
}

authentication() {
    enforce_secure_password_policy() {
        echo "Enforcing secure password policy..."
        # Add your commands to enforce a secure password policy
        # Example commands:
        sed -i 's/# minlen=8/minlen=12/' /etc/security/pwquality.conf
        sed -i 's/# dcredit=-1/dcredit=-1/' /etc/security/pwquality.conf
        sed -i 's/# ucredit=-1/ucredit=-1/' /etc/security/pwquality.conf
        sed -i 's/# ocredit=-1/ocredit=-1/' /etc/security/pwquality.conf
        sed -i 's/# lcredit=-1/lcredit=-1/' /etc/security/pwquality.conf
        echo "Secure password policy has been enforced."
    }

    enable_two_factor_authentication() {
        echo "Enabling two-factor authentication..."
        # Add your commands to enable two-factor authentication
        # Example commands:
        echo "auth required pam_google_authenticator.so" >> /etc/pam.d/sshd
        echo "Two-factor authentication has been enabled."
    }

    configure_login_banner() {
        echo "Configuring login banner..."
        # Add your commands to configure the login banner
        # Example commands:
        echo "Enter the login banner message:"
        read -r login_banner
        echo "$login_banner" > /etc/issue
        echo "Login banner has been configured."
    }

    configure_logout_message() {
        echo "Configuring logout message..."
        # Add your commands to configure the logout message
        # Example commands:
        echo "Enter the logout message:"
        read -r logout_message
        echo "$logout_message" > /etc/issue.net
        echo "Logout message has been configured."
    }

    display_menu() {
        echo "Authentication Menu"
        echo "1. Enforce secure password policy"
        echo "2. Enable two-factor authentication"
        echo "3. Configure login banner"
        echo "4. Configure logout message"
        echo "5. Exit"
        echo
    }

    read_menu_choice() {
        local choice
        read -p "Enter your choice (1-5): " choice
        echo "$choice"
    }

    validate_menu_choice() {
        local choice=$1
        if [[ $choice =~ ^[1-5]$ ]]; then
            return 0
        else
            return 1
        fi
    }

    sanitize_menu_choice() {
        local choice=$1
        echo "$choice" | tr -d '[:space:]'
    }

    handle_menu_choice() {
        local choice=$1
        case $choice in
            1)
                enforce_secure_password_policy
                ;;
            2)
                enable_two_factor_authentication
                ;;
            3)
                configure_login_banner
                ;;
            4)
                configure_logout_message
                ;;
            5)
                exit
                ;;
            *)
                echo "Invalid choice. Please try again."
                ;;
        esac
    }

    while true; do
        display_menu
        choice=$(read_menu_choice)
        choice=$(sanitize_menu_choice "$choice")

        if validate_menu_choice "$choice"; then
            handle_menu_choice "$choice"
        else
            echo "Invalid input. Please enter a valid choice."
        fi

        echo
    done
}

while true; do
   user_conf
   other_conf
   read -p "What do you wish to do: " choice
   echo

   case $choice in
     1) create_user ;;
     2) mod_user ;;
     3) del_user ;;
     4) perm_user ;;
     5) grp_user ;;
     6) pwd_policies ;;
     7) monitoring ;;
     8) authentication ;;
     0) exit ;;
     *) echo "Invalid Choice, please, choose correctly."

    esac

    echo
done
   
   
