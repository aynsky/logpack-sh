#!/usr/bin/env bash
set -euo pipefail

# logtool.sh
# Single-file log archiving tool
# Supports config-based mode or interactive/manual mode

###===========================config section===========================###
log_dir=""        # Directory containing log files
output_file=""    # Output archive file location
filter_type=""    # Type of filter: size = 1, time = 2, keyword = 3

# Fil parameters only filter mode you choose

### Filter parameters for size
size_threshold="" # Size threshold in KB for size  filter             

### Filter parameters for time
time_threshold="" # Time threshold in days for time filter

### Filter parameters for keyword       
keyword=""        # Keyword for keyword filter

USE_CONFIG_MODE=false  # Set to true to use config mode, false for interactive/manual mode



###===========================interactive section===========================###

#colors
RED='\033[0;31m' 
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

check_deps() {  # Check for required commands
    local missing=()
    for cmd in find tar grep date; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    if [ "${#missing[@]}" -ne 0 ]; then
        echo "Missing required commands: ${missing[*]}"
        exit 1
    fi
}

print_menu() { # Print interactive menu
    echo ""
    echo -e "${YELLOW} Log Archiving Tool - Interactive Mode ${NC}"
    echo ""
    echo "1) Archive logs larger than a specified size"
    echo "2) Archive logs modified within a specified time frame"
    echo "3) Archive logs containing a specific keyword"
    echo "4) Delete log files older than a specified time frame"
    echo "5) Exit"
    echo ""
}

check_dirs(){ # Check if log directory exists and is accessible
    if [ ! -d "$log_dir" ]; then
        echo -e "${RED}Directory does not exist.${NC}"
        exit 1
    elif [ ! -r "$log_dir" ] || [ ! -x "$log_dir" ]; then
        echo -e "${RED}Directory is not accessible. Check permissions (read+execute required).${NC}"
        exit 1
    fi
}


# timestamp
timestamp=$(date +%Y-%m-%d) # Current date for output file naming

filter_logs_by_size() {
    if [ "$USE_CONFIG_MODE" = false ]; then
        read -rp "Enter size threshold (in kilobytes) for archiving: " size_threshold
        read -rp "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): " output_file
    fi

    output_file="${output_file%.tar.gz}-$timestamp.tar.gz"

    # Check if any files exist before creating tar
    if find "$log_dir" -type f -size +"${size_threshold}"k -print0 | grep -qz .; then
        if ! find "$log_dir" -type f -size +"${size_threshold}"k -print0 | tar --null -czvf "$output_file" --files-from=-; then
            echo "Error: Failed to create archive $output_file" >&2
            return 1
        fi
        echo "Archive created successfully: $output_file"
    else
        echo "No files found larger than ${size_threshold}KB. Archive not created."
    fi
}

filter_logs_by_days() {
    if [ "$USE_CONFIG_MODE" = false ]; then
        read -rp "Enter time threshold (in days) for archiving: " time_threshold
        read -rp "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): " output_file
    fi

    output_file="${output_file%.tar.gz}-$timestamp.tar.gz"

    if find "$log_dir" -type f -mtime -"$time_threshold" -print0 | grep -qz .; then
        if ! find "$log_dir" -type f -mtime -"$time_threshold" -print0 | tar --null -czvf "$output_file" --files-from=-; then
            echo "Error: Failed to create archive $output_file" >&2
            return 1
        fi
        echo "Archive created successfully: $output_file"
    else
        echo "No files modified within last $time_threshold days. Archive not created."
    fi
}

filter_logs_by_keyword() {
    if [ "$USE_CONFIG_MODE" = false ]; then
        read -rp "Enter keyword for archiving logs: " keyword
        read -rp "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): " output_file
    fi

    output_file="${output_file%.tar.gz}-$timestamp.tar.gz"

    if grep -rilZ -- "$keyword" "$log_dir" | grep -qz .; then
        if ! grep -rilZ -- "$keyword" "$log_dir" | tar --null -czvf "$output_file" --files-from=-; then
            echo "Error: Failed to create archive $output_file" >&2
            return 1
        fi
        echo "Archive created successfully: $output_file"
    else
        echo "No files found containing keyword '$keyword'. Archive not created."
    fi
}


delete_log_files() { # Cleanup temporary files if any
    if [ "$USE_CONFIG_MODE" = false ]; then
        read -rp "Enter time threshold (in days) for log deletion: " time_threshold
    fi

    files_to_delete=$(find "$log_dir" -type f -mtime +"$time_threshold")
    if [ -z "$files_to_delete" ]; then
        echo "No files older than $time_threshold days to delete."
        return 0
    fi

    if ! find "$log_dir" -type f -mtime +"$time_threshold" -print -delete; then
        echo "Error: Failed to delete some files." >&2
        return 1
    fi

    echo "Old log files deleted successfully."
}


       

interactive_mode() { # Interactive/manual mode
    clear
    cat << "EOF"
    __                   ___                __    _             
   / /   ____  ____ _   /   |  __________  / /_  (_)   _____    
  / /   / __ \/ __ `/  / /| | / ___/ ___/ / __ \/ / | / / _ \   
 / /___/ /_/ / /_/ /  / ___ |/ /  / /__  / / / / /| |/ /  __/   
/_____/\____/\__, /  /_/  |_/_/   \___/ /_/ /_/_/ |___/\___/    
            /____/     
            >> Filter by: Size | Date | Keyword <<                                         
EOF
    
    printf "Enter log directory path: " 
    read -r log_dir 
    check_dirs 
    while true; do
        print_menu 
        printf "Choice: " 
        read -r choice 
        case "$choice" in
            1) filter_logs_by_size ;;
            2) filter_logs_by_days ;;
            3) filter_logs_by_keyword ;;
            4) delete_log_files ;;
            5) echo "Goodbye."; exit 0 ;;
            *) echo -e "${RED}Invalid choice.${NC}" ;; 
        esac 
    done 
}



config_mode() { # Config-based mode
    check_dirs
    case "$filter_type" in
        1) filter_logs_by_size ;;
        2) filter_logs_by_days ;;
        3) filter_logs_by_keyword ;;
        4) delete_log_files ;;
        *) echo -e "${RED} Invalid filter type in config.${NC}" ;;
    esac  
}

main() {
    check_deps # Check for required dependencies
    if [ "$USE_CONFIG_MODE" = false ]; then
        interactive_mode
    else
        config_mode
    fi
    
}
main 


