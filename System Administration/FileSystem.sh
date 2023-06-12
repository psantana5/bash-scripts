#!/bin/bash
RED='\033[0;31m' # RED COLOR
NC='\033[0m' # NO COLOR

toilet -f smblock "Simple File System" | boxes -d cat -a hc -p h0 | lolcat

main(){
    clear
    echo "Simple File System Menu"
    echo "------------------------"
    echo "1. File search and filtering"
    echo "2. File integrity check"
    echo "3. File Sync"
    echo "4. File archiving and compression"
    echo "5. File monitoring"
    echo "6. Disk space analysis"
    echo "7. File encryption and decryption"
    echo "8. File versioning"
    echo "9. File permissions audit"
    echo "10. File Transfer and remote sync"
    echo "0. Exit"
    echo
}

search(){
    clear
    echo "File search and filtering menu"
    echo "1. Find files with a specific extension"
    echo "2. Find files larger than a certain size"
    echo "3. Find files modified within a specific date range"
    echo "0. Exit"
    echo
    read -p "> " option
    extension(){
        clear
        echo "Find files that meet a specific extension"
        echo
        read -p "What's the path to the directory? " path
        read -p "What's the type of file you want to search for? " extension
        find $path -type f -name "$extension"
    }
    size(){
        clear
        echo "Find files based on size"
        echo
        read -p "What's the directory path? " path1
        read -p "What's size do you want to look for? (Greater than) " size
        find $path1 -type f -size $size
    }
    dates(){
        clear
        echo "Find files based on date"
        echo
        read -p "What directory do you want to search on? " path2
        read -p "First modification date. Format 2023-06-21 " dates
        read -p "Last modification date Format 2023-06-21 " date1
        find $path2 -type f -newermt "$dates" ! -newermt "$date1"
    }
    case $option in
      1) extension ;;
      2) size ;;
      3) dates ;;
      0) main ;;
      *) echo "Option not recognized." ;;
    esac
}

integrity(){
    int(){
        echo 
        echo "File Integrity Menu"
        echo
        echo "1. Calculate MD5 checksum"
        echo "2. Calculate SHA-256 checksum"
        echo "3. Calculate SHA-512 checksum"
        echo "0. Exit"
        echo
    }

    md5(){
        clear
        echo "Calculate MD5 checksum"
        read -p "What's the file to be calculated? (path to the file): " md5_input
        echo "Your MD5 checksum is: $(md5sum md5_input)"
    }

    sha512(){
        clear
        echo "Calculate SHA-512 checksum"
        read -p "What's the file to be calculated? (path to the file): " sha512_input
        echo "Your SHA512 checksum is: $(sha512sum $sha512sum)"
    }

    sha256(){
        clear
        echo "Calculate SHA256 checksum"
        read -p "What's the file to be calculated? (path to the file): " sha256_input
        echo "Your SHA256 checksum is: $(sha256sum $sha256_input)"
    }

    while true; do
      int
      read -p "What do you want to do? " int_choice
      case $int_choice in
        1) md5 ;;
        2) sha256 ;;
        3) sha512 ;;
        0) exit ;;
        *) echo "Invalid Option"
      esac
    done
      
}

sync() {
    clear
    echo
    echo "File synchronization menu"
    echo -e "${RED}ATTENTION! THIS WILL PERFORM FILE & DIRECTORY SYNC ONLY!${NC}"
    sleep 1

    read -p "What's the source path? " source
    source="$(echo -e "${source}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    read -p "What's the destination path? " destination
    destination="$(echo -e "${destination}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
 
    if [[ -z $source ]] || [[ -z $destination ]]; then
        echo "Error: Source or destination path is empty."
        return 1
    fi
    
    if [[ ! -d $source ]]; then
        echo "Error: Source path does not exist or is not a directory."
        return 1
    fi
    
    if [[ ! -d $destination ]]; then
        echo "Error: Destination path does not exist or is not a directory."
        return 1
    fi
    rsync -av "$source" "$destination"
}

archiving(){
    clear
    echo "File archiving and compression"
    echo "------------------------------"
    echo "1. Create a TAR file"
    echo "2. Extract a file from a TAR archive"
    echo "3. Create a ZIP file"
    echo "4. Extract from a ZIP file"
    echo "5. Compress a single file"
    echo "6. Decompressing a single file"
    echo "0. Exit"
    echo

    create_tar(){
        clear
        echo "Create a .TAR file"
        echo 
        echo "1. Create a TAR out of a folder"
        echo "2. Create a TAR out of an archive"
        read -p "What do you want to do? " tar_choice

        folder(){
            read -p "What will be the name of the output .TAR folder? " output_tar
            read -p "What directory do you want to turn into a .TAR folder? " input_tar

            # Sanitize input
            output_tar="$(echo -e "${output_tar}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            input_tar="$(echo -e "${input_tar}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

            # Check if input is empty
            if [[ -z $output_tar ]] || [[ -z $input_tar ]]; then
                echo "Error: Output or input path is empty."
                return 1
            fi

            tar -cvf "$output_tar.tar" "$input_tar"     
        }

        archive(){
            read -p "What will be the name of the output archive? " output_file_tar
            read -p "What file do you want to turn into a tar archive? " input_file_tar

            # Sanitize input
            output_file_tar="$(echo -e "${output_file_tar}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
            input_file_tar="$(echo -e "${input_file_tar}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

            # Check if input is empty
            if [[ -z $output_file_tar ]] || [[ -z $input_file_tar ]]; then
                echo "Error: Output or input path is empty."
                return 1
            fi

            tar -cvzf "$output_file_tar.tar.gz" "$input_file_tar"
        }

        case $tar_choice in
          1) folder ;;
          2) archive ;;
          *) echo "Option not found" ;;
        esac
    }

    extract_tar(){
        clear
        echo "Extract a .TAR file"
        echo
        read -p "What's the path of the file? " extract_path

        # Sanitize input
        extract_path="$(echo -e "${extract_path}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        # Check if input is empty
        if [[ -z $extract_path ]]; then
            echo "Error: Extract path is empty."
            return 1
        fi

        tar -xvf "$extract_path"
    }

    create_zip(){
        clear
        echo "Create a ZIP file (directories only)"
        echo
        read -p "What will be the output name for the zip folder? " output_zip
        read -p "What is the absolute path for the folder? " input_zip

        # Sanitize input
        output_zip="$(echo -e "${output_zip}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        input_zip="$(echo -e "${input_zip}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        # Check if input is empty
        if [[ -z $output_zip ]] || [[ -z $input_zip ]]; then
            echo "Error: Output or input path is empty."
            return 1
        fi

        zip -r "$output_zip.zip" "$input_zip"
    }

    extract_zip(){
        clear
        echo "Extract files from .ZIP"
        echo
        read -p "What's the archive path? " archive_path

        # Sanitize input
        archive_path="$(echo -e "${archive_path}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        # Check if input is empty
        if [[ -z $archive_path ]]; then
            echo "Error: Archive path is empty."
            return 1
        fi

        unzip "$archive_path"
    }

    compress_file(){
        clear
        echo "Compress a single file"
        echo
        read -p "What's the path of the file? " file_path

        # Sanitize input
        file_path="$(echo -e "${file_path}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        # Check if input is empty
        if [[ -z $file_path ]]; then
            echo "Error: File path is empty."
            return 1
        fi

        gzip "$file_path"
    }

    decompress_file(){
        clear
        echo "Decompress a file compressed with gzip"
        echo
        read -p "What's the path of the file? " gzip_path

        # Sanitize input
        gzip_path="$(echo -e "${gzip_path}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"

        # Check if input is empty
        if [[ -z $gzip_path ]]; then
            echo "Error: Gzip path is empty."
            return 1
        fi

        gunzip "$gzip_path"
    }

    while true; do
      read -p "What do you want to do? " archiving_option
      case $archiving_option in
        1) create_tar ;;
        2) extract_tar ;;
        3) create_zip ;;
        4) extract_zip ;;
        5) compress_file ;;
        6) decompress_file ;;
        0) exit ;;
        *) echo "Option not found" ;;
       esac
    done
}

while true; do
  main
  read -p "What do you want to do? " choice
  case $choice in
    1) search ;;
    2) integrity ;;
    3) sync ;;
    4) archiving ;;
    5) monitoring ;;
    6) disk ;;
    7) encryption ;;
    8) versioning ;;
    9) permissions ;;
    10) transfer_and_sync ;;
    0) exit ;;
    *) echo "Option not recognized"
  esac
done
