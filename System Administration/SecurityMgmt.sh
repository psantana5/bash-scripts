#!/bin/bash
toilet -f smblock "Security Management" | boxes -d dog -a hc -p h0 | lolcat
sleep 1

display_menu(){
    clear  
    echo  "-- Security Management Menu --"
    echo
    echo "1. User Access Control"
    echo "2. Logging and Auditing"
    echo "3. Security Configuration Management"
    echo "4. Vulnerability Scanning and Assessment"
    echo "5. Threat Detection and Intrusion Prevention"
    echo "6. SIEM and Event Management"
    echo "7. Incident Response Automation"
    echo "8. Compliance Management"
    echo "9. Threat Intelligence Integration"
    echo "10. Reporting and Visualization"
    echo "0. Exit"
    echo
}

uac() {
    uac_menu() {
        clear
        echo "-- User Access Control -- "
        echo
        echo "1. RBAC Implementation"
        echo "2. Access Permissions and Privileges"
        echo "3. Access Restrictions"
        echo "4. Session Management"
        echo "5. Password Policies"
        echo "6. Account Lockout"
        echo "7. User Provisioning and Deprovisioning"
        echo "8. Secure Session Handling"
        echo "9. Audit Trials"
        echo "0. Exit back to the main menu"
        echo
    }

    rbac() {
        local action=$1
        local role=$2
        local user=$3

        local rbac_file="/etc/security/rbac.conf"
        echo "RBAC file will be stored at: $rbac_file"

        case $action in
            "assign")
                if [[ -z $role || -z $user ]]; then
                    echo "Error: Role and user are required for assignment."
                    return 1
                fi

                # Sanitize role and user inputs
                role=$(sanitize_input "$role")
                user=$(sanitize_input "$user")

                echo "Assigning role '$role' to user '$user'..."
                echo "$role:$user" >> "$rbac_file"
                echo "Role '$role' assigned to user '$user'."
                ;;

            "revoke")
                if [[ -z $role || -z $user ]]; then
                    echo "Error: Role and user are required for revocation."
                    return 1
                fi

                # Sanitize role and user inputs
                role=$(sanitize_input "$role")
                user=$(sanitize_input "$user")

                echo "Revoking role '$role' from user '$user'..."
                sed -i "/^$role:$user$/d" "$rbac_file"
                echo "Role '$role' revoked from user '$user'."
                ;;

            "list")
                echo "Listing role assignments..."
                if [[ ! -f $rbac_file ]]; then
                    echo "Error: RBAC file does not exist or is inaccessible."
                    return 1
                fi

                if [[ ! -s $rbac_file ]]; then
                    echo "No role assignments found in RBAC file."
                else
                    echo "Role Assignments:"
                    cat "$rbac_file"
                fi
                ;;

            *)
                echo "Error: Invalid action. Supported actions: assign, revoke, list."
                return 1
                ;;
        esac
    }

    access_permissions() {
        access_permissions_menu() {
            clear
            echo "-- Access Permissions and Privileges --"
            echo
            echo "1. Grant Access"
            echo "2. Revoke Access"
            echo "3. List Access Permissions"
            echo "0. Exit to User Access Control menu"
            echo
        }

        grant_access() {
            read -p "Enter the user: " user
            read -p "Enter the resource: " resource

            # Sanitize user and resource inputs
            user=$(sanitize_input "$user")
            resource=$(sanitize_input "$resource")

            echo "Granting access to user '$user' for resource '$resource'..."
            if grep -q "$user:$resource" "$access_file"; then
              echo "Error: User $user already has access to resource $resource"
              return 1
            fi
            echo "$user:$resource" >> "$access_file"
            echo "Access granted to user '$user' for resource '$resource'."
        }

        revoke_access() {
            read -p "Enter the user: " user
            read -p "Enter the resource: " resource

            # Sanitize user and resource inputs
            user=$(sanitize_input "$user")
            resource=$(sanitize_input "$resource")

            echo "Revoking access from user '$user' for resource '$resource'..."
            if ! grep -q "$user:$resource$" "$access_file"; then
              echo "Error: $User does not have acces to $resource"
              return 1
            fi

            sed -i "/^$user:$resource$/d" "$access_file"
            echo "Access revoked from user '$user' for resource '$resource'."
        }

        list_access_permissions() {
            echo "Listing access permissions..."
            cat "$access_file"
        }

        while true; do
            access_permissions_menu
            echo
            read -p "What do you wish to do: " access_choice
            case $access_choice in
                0)
                    break
                    ;;
                1)
                    grant_access
                    ;;
                2)
                    revoke_access
                    ;;
                3)
                    list_access_permissions
                    ;;
                *)
                    echo "Invalid choice. Please select a valid option."
                    ;;
            esac
            echo
        done
    }

    while true; do
        uac_menu
        echo
        read -p "What do you wish to do: " uac_choice
        case $uac_choice in
            0)
                exit
                ;;
            1)
                rbac_menu() {
                    clear
                    echo "-- RBAC Implementation --"
                    echo
                    echo "1. Assign Role"
                    echo "2. Revoke Role"
                    echo "3. List Role Assignments"
                    echo "0. Exit to User Access Control menu"
                    echo
                }

                while true; do
                    rbac_menu
                    echo
                    read -p "What do you wish to do: " rbac_choice
                    case $rbac_choice in
                        0)
                            break
                            ;;
                        1)
                            read -p "Enter the role: " role
                            read -p "Enter the user: " user
                            rbac "assign" "$role" "$user"
                            ;;
                        2)
                            read -p "Enter the role: " role
                            read -p "Enter the user: " user
                            rbac "revoke" "$role" "$user"
                            ;;
                        3)
                            rbac "list"
                            ;;
                        *)
                            echo "Invalid choice. Please select a valid option."
                            ;;
                    esac
                    echo
                done
                ;;
            2)
                access_permissions
                ;;
            *)
                echo "Invalid choice. Please select a valid option."
                ;;
        esac
        echo
    done
}

log_and_aud() {
    log_menu() {
        clear
        echo "-- Logging and Auditing Menu --"
        echo
        echo "1. Configure Logging"
        echo "2. Log Event"
        echo "3. Perform Audit"
        echo "4. Filter and Search Logs"
        echo "5. Set Log Alerts"
        echo "6. Analyze Logs"
        echo "7. Export Log Reports"
        echo "0. Exit to Main Menu"
        echo
    }

    configure_logging() {
        echo "Configure Logging"
        echo
        read -p "Enter the log file path to analyze: " log_file
        read -p "Enter the log level (INFO, DEBUG, ERROR): " log_level

        if [[ -z $log_file || -z $log_level ]]; then
            echo "Error: Log file path and Log level are required."
            return 1
        fi

        if ! validate_log_level "$log_level"; then
            echo "Error: Invalid Log Level. Supported Log Levels are listed as examples."
            return 1
        fi

        if [[ -f $log_config_file ]]; then
            # Update Current Configuration
            sed -i "s|logfile=.*|logfile=$log_file|" "$log_config_file"
            sed -i "s|loglevel=.*|loglevel=$log_level|" "$log_config_file"
            echo "Logging configuration updated."
        else
            echo "logfile=$log_file" >>"$log_config_file"
            echo "loglevel=$log_level" >>"$log_config_file"
            echo "Logging configuration created."
        fi
    }

    log_event() {
        log_file="/var/log/application.log"

        echo "-- Log Events --"
        echo

        read -p "Enter the event message: " event_message
        read -p "Enter the log level (e.g., INFO, DEBUG, ERROR): " log_level

        if [[ -z $event_message || -z $log_level ]]; then
            echo "Error: Event message and log level are required."
            return 1
        fi

        # Validate log level
        if ! validate_log_level "$log_level"; then
            echo "Error: Invalid log level. Supported log levels: INFO, DEBUG, ERROR."
            return 1
        fi

        # Log the event to the log file
        echo "$(date +"%Y-%m-%d %H:%M:%S") [$log_level] $event_message" >>"$log_file"
        echo "Event logged successfully."
    }

    perform_auditing() {
        audit_log="/var/log/audit.log"

        echo " -- Auditing Menu -- "
        echo "1. User Activity Monitoring"
        echo "2. File Integrity Checking"
        echo "3. Network Traffic Analysis"
        echo "4. System Configuration Review"
        echo "5. Privilege Escalation Detection"

        echo

        read -p "What do you wish to do: " auditing_feature

        monitor_users() {
            clear
            echo " -- Monitor Users --"
            echo "1. Track User Logins"
            echo "2. Monitor Executed Commands"
            echo "3. Monitor File Changes"
            echo "4. Tracking Network Connections"
        }

        track_logins() {
            echo "Will track user logins to a file"
            read -p "Enter a destination path for the user_logins.log file: " dest_path
            who >>"$dest_path.log"
            echo "User Logins can be found at $dest_path"
        }

        monitor_commands() {
            echo "Monitor Executed Commands"
            audit_rule="-a exit,always -F arch=b64 -F euid!=0 -S execve"
            read -p "Enter a destination path for the user_commands.log file: " monitor_path

            echo "Monitoring executed commands"
            auditctl $audit_rule -k user_commands
            auditctl -l

            tail -f $monitor_path
            echo "Continuously monitoring the audit log file for executed commands"
        }

        monitor_file() {
            echo "File and Folder monitoring"
            directory="/"
            read -p "Enter a destination path for the changes.log file: " dest_path1
            echo "Attention! This will search all of the directories in the OS for changes."
            sleep 0.5
            audit_rule="-w $directory -p wa"

            echo "Monitoring file changes in $directory..."
            auditctl $audit_rule -k file_changes
            auditctl -l

            echo "Continuously monitoring the audit log file for file changes..."
            tail -f "$dest_path1"

            parse_file_changes() {
                echo "Parsing file changes log"
                aureport --file --input $dest_path1
            }

            parse_file_changes
        }

        track_network(){
            clear
            network_menu(){
              echo "-- Tracking Network Connections -- "
              echo
              echo "1. Real-time Monitoring"
              echo "2. Logging"
              echo "3. User Identification"
              echo "4. Alerting"
              echo "5. Reporting"
              echo "6. IP Geolocation"
              echo "7. Configuration"
              echo
            }

            realtime_monitoring(){
              monitor_network_connections(){
                  while true; do
                    netstat tunp | awk 'NR>2 {print $5, $4, $1, $6}' | while read -r source_ip dest_ip port protocol status; do
                      echo "$(date +"%Y-%m-%d %H:%M:%S") - Source: $source_ip, Destination: $dest_ip, Port: $port, Protocol: $protocol, Status: $status"

                      log_network_connection "$source_ip" "$dest_ip" "$port" "$protocol" "$status"

                      if [[ "$protocol" == "TCP" && "$status" == "ESTABLISHED" && "$port" == "22" ]]; then
                        send_alert "$source_ip" "$dest_ip" "$port" "$protocol"
                      fi
                  done
                  sleep 1
                }


            }
            while true; do
            network_menu
            read -p "What do you wish to do? " network_choice

        }

        while true; do
            monitor_users
            echo
            read -p "What do you wish to do? " monitor_choice

            case $monitor_choice in
                1)
                    track_logins
                    ;;
                2)
                    monitor_commands
                    ;;
                3)
                    monitor_file
                    ;;
                4)
                    echo "Tracking Network Connections"
                    ;;
                *)
                    echo "Invalid option. Please select a valid monitoring feature."
                    ;;
            esac

            echo "$(date +"%Y-%m-%d %H:%M:%S") - Monitoring: $monitor_choice" >>"$audit_log"

            read -p "Do you want to monitor another feature? (y/n): " continue_monitor
            if [[ $continue_monitor != "y" ]]; then
                break
            fi

            echo
        done

        echo "Monitoring Completed"
    }

    filter_and_search_logs() {
        # Logic for filtering and searching logs
        echo "Filter and Search Logs - Placeholder"
    }

    set_log_alerts() {
        # Logic for setting log alerts
        echo "Set Log Alerts - Placeholder"
    }

    analyze_logs() {
        # Logic for log analysis
        echo "Analyze Logs - Placeholder"
    }

    export_log_reports() {
        # Logic for exporting log reports
        echo "Export Log Reports - Placeholder"
    }

    while true; do
        log_menu
        echo
        read -p "Select an option: " log_choice
        case $log_choice in
            0)
                break
                ;;
            1)
                configure_logging
                ;;
            2)
                log_event
                ;;
            3)
                perform_auditing
                ;;
            4)
                filter_and_search_logs
                ;;
            5)
                set_log_alerts
                ;;
            6)
                analyze_logs
                ;;
            7)
                export_log_reports
                ;;
            *)
                echo "Invalid choice. Please select a valid option."
                ;;
        esac
        echo
    done
}


while true; do
  display_menu
  read -p "What do you wish to do: " choice
  case $choice in
    1) uac ;;
    2) log_and_aud ;;
    0) exit ;;
  esac
done