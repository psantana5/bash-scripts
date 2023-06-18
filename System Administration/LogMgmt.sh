#!/bin/bash

# Function to display available log files
display_log_files() {
  echo "Available log files:"
  ls /var/log/
}

# Function to display the content of a log file
display_log_content() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file content:"
  cat /var/log/$log_file
}

# Function to display the last lines of a log file
display_last_lines() {
  read -p "Enter the name of the log file: " log_file
  read -p "Enter the number of lines to display: " num_lines
  echo "Last $num_lines lines of $log_file:"
  tail -n $num_lines /var/log/$log_file
}

# Function to search for a keyword in log files
search_keyword() {
  read -p "Enter the keyword to search: " keyword
  echo "Searching for \"$keyword\" in log files..."
  grep -r $keyword /var/log/
}

# Function to compress a log file
compress_log_file() {
  read -p "Enter the name of the log file to compress: " log_file
  echo "Compressing $log_file..."
  gzip /var/log/$log_file
}

# Function to extract a compressed log file
extract_log_file() {
  read -p "Enter the name of the compressed log file to extract: " compressed_file
  echo "Extracting $compressed_file..."
  gzip -d /var/log/$compressed_file
}

# Function to clear the content of a log file
clear_log_file() {
  read -p "Enter the name of the log file to clear: " log_file
  echo "Clearing $log_file..."
  echo "" > /var/log/$log_file
}

# Function to display log file size
display_log_file_size() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file size:"
  du -h /var/log/$log_file
}

# Function to display disk space usage of log files directory
display_disk_space_usage() {
  echo "Disk space usage of log files directory:"
  du -h /var/log/
}

# Function to display log file permissions
display_log_file_permissions() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file permissions:"
  ls -l /var/log/$log_file
}

# Function to display log file ownership
display_log_file_ownership() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file ownership:"
  ls -l /var/log/$log_file | awk '{print $3,$4}'
}

# Function to display log file timestamps
display_log_file_timestamps() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file timestamps:"
  ls -l /var/log/$log_file | awk '{print $6,$7,$8}'
}

# Function to display log file modification time
display_log_file_modification_time() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file modification time:"
  stat -c %y /var/log/$log_file
}

# Function to display log file access time
display_log_file_access_time() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file access time:"
  stat -c %x /var/log/$log_file
}

# Function to display log file creation time
display_log_file_creation_time() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file creation time:"
  stat -c %w /var/log/$log_file
}

# Function to display log file permissions in octal format
display_log_file_permissions_octal() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file permissions (octal format):"
  stat -c %a /var/log/$log_file
}

# Function to display log file details
display_log_file_details() {
  read -p "Enter the name of the log file: " log_file
  echo "Log file details:"
  ls -l /var/log/$log_file
  echo "Log file timestamps:"
  ls -l /var/log/$log_file | awk '{print $6,$7,$8}'
  echo "Log file permissions:"
  ls -l /var/log/$log_file | awk '{print $1}'
}

# Function to monitor log file changes
monitor_log_file_changes() {
  read -p "Enter the name of the log file to monitor: " log_file
  echo "Monitoring changes in $log_file..."
  tail -f /var/log/$log_file
}

# Function to rotate log files
rotate_log_files() {
  echo "Rotating log files..."
  sudo logrotate -f /etc/logrotate.conf
}

# Function to backup log files
backup_log_files() {
  echo "Backing up log files..."
  sudo cp -r /var/log/ /var/log_backup/
}

# Function to delete log files
delete_log_files() {
  echo "Deleting log files..."
  sudo rm -rf /var/log/*
}

# Function to display main menu
display_main_menu() {
  echo "=== Log Management Menu ==="
  echo "1. Display Logs"
  echo "2. Manage Log Files"
  echo "3. View Log File Details"
  echo "4. Monitor Log Files"
  echo "5. Log Maintenance"
  echo "6. Exit"
}

# Function to display logs submenu
display_logs_submenu() {
  echo "=== Logs Menu ==="
  echo "1. Display log files"
  echo "2. Display log file content"
  echo "3. Display last lines of a log file"
  echo "4. Search keyword in log files"
}

# Function to display manage log files submenu
display_manage_logs_submenu() {
  echo "=== Manage Log Files Menu ==="
  echo "1. Compress a log file"
  echo "2. Extract a compressed log file"
  echo "3. Clear a log file"
}

# Function to display view log file details submenu
display_view_details_submenu() {
  echo "=== View Log File Details Menu ==="
  echo "1. Display log file size"
  echo "2. Display disk space usage"
  echo "3. Display log file permissions"
  echo "4. Display log file ownership"
  echo "5. Display log file timestamps"
  echo "6. Display log file modification time"
  echo "7. Display log file access time"
  echo "8. Display log file creation time"
  echo "9. Display log file permissions (octal format)"
  echo "10. Display log file details"
}

# Function to display log maintenance submenu
display_log_maintenance_submenu() {
  echo "=== Log Maintenance Menu ==="
  echo "1. Rotate log files"
  echo "2. Backup log files"
  echo "3. Delete log files"
}

# Main program loop
while true; do
  clear
  display_main_menu

  # Read user's choice
  read -p "Enter your choice (1-6): " choice

  case $choice in
    1) # Logs
      clear
      display_logs_submenu
      read -p "Enter your choice (1-4): " logs_choice
      case $logs_choice in
        1) display_log_files ;;
        2) display_log_content ;;
        3) display_last_lines ;;
        4) search_keyword ;;
        *) echo "Invalid choice. Try again." ;;
      esac
      ;;
    2) # Manage Log Files
      clear
      display_manage_logs_submenu
      read -p "Enter your choice (1-3): " manage_logs_choice
      case $manage_logs_choice in
        1) compress_log_file ;;
        2) extract_log_file ;;
        3) clear_log_file ;;
        *) echo "Invalid choice. Try again." ;;
      esac
      ;;
    3) # View Log File Details
      clear
      display_view_details_submenu
      read -p "Enter your choice (1-10): " view_details_choice
      case $view_details_choice in
        1) display_log_file_size ;;
        2) display_disk_space_usage ;;
        3) display_log_file_permissions ;;
        4) display_log_file_ownership ;;
        5) display_log_file_timestamps ;;
        6) display_log_file_modification_time ;;
        7) display_log_file_access_time ;;
        8) display_log_file_creation_time ;;
        9) display_log_file_permissions_octal ;;
        10) display_log_file_details ;;
        *) echo "Invalid choice. Try again." ;;
      esac
      ;;
    4) # Monitor Log Files
      clear
      monitor_log_file_changes ;;
    5) # Log Maintenance
      clear
      display_log_maintenance_submenu
      read -p "Enter your choice (1-3): " log_maintenance_choice
      case $log_maintenance_choice in
        1) rotate_log_files ;;
        2) backup_log_files ;;
        3) delete_log_files ;;
        *) echo "Invalid choice. Try again." ;;
      esac
      ;;
    6) # Exit
      exit 0 ;;
    *) echo "Invalid choice. Try again." ;;
  esac

  read -p "Press enter to continue..."
done
