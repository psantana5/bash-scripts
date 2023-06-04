#!/bin/bash
packages=("mailutils")
missing_packages=()

for package in "${packages[@]}"
do
    if ! dpkg -s "$package" > /dev/null 2>&1; then
        missing_packages+=("$package")
    fi
done

# Prompt user to install missing packages
if [ ${#missing_packages[@]} -gt 0 ]; then
    echo -e "The following packages are required but not installed: ${missing_packages[@]}\033[0m"
    read -p "Do you want to install them now? (y/n) " choice
    case "$choice" in
        y|Y ) sudo apt-get update && sudo apt-get install -y "${missing_packages[@]}";;
        n|N ) echo "Exiting..."; exit 1;;
        * ) echo "Invalid choice. Exiting..."; exit 1;;
    esac
fi

toilet -f smblock "Log Monitor" | boxes -d cat -a hc -p h0 | lolcat

# Set log file path and keyword to search for
log_file="/var/log/syslog"
read -p "What keyword do you want to search for? " keyword

# Get total number of lines in log file
total_lines=$(wc -l < "$log_file")

# Initialize progress variables
current_line=0
start_time=$(date +%s)

# Monitor log file for keyword
tail -f "$log_file" | while read line
do
    # Update progress variables
    current_line=$((current_line + 1))
    current_time=$(date +%s)
    elapsed_time=$((current_time - start_time))

    # Calculate progress percentage
    progress=$((current_line * 100 / total_lines))

    # Print progress bar
    printf "\r[%-50s] %d%% (%d/%d) Time up: %ds Current time: %s" \
           $(printf "#%.0s" {1..$((progress / 2))}) \
           $progress \
           $current_line \
           $total_lines \
           $elapsed_time \
           $(date +"%T")

    # Check for keyword
    if echo "$line" | grep -q "$keyword"; then
        # Send alert
        echo "Error found in log file: $line" | mail -s "Log Alert" pausantanapi2@gmail.com
    fi
done

# Print newline after progress bar
echo ""
