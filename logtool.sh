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

### Filter parameters for keywordkeyword       
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
    echo -e "${CYAN} Log Archiving Tool - Interactive Mode ${NC}"
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

timestamp=$(date +%Y-%m-%d) # Current date for output file naming

filter_logs_by_size() { # Filter logs by size
    if [ "$USE_CONFIG_MODE" = false ]; then
        printf "Enter size threshold (in kilobytes) for archiving: "
        read -r size_threshold
        printf "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): "
        read -r output_file
        output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
        find "$log_dir" -type f -size +"${size_threshold}"k -print0 2>/dev/null | \
            tar --null -czvf "$output_file" --files-from=-
    else
        output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
        find "$log_dir" -type f -size +"${size_threshold}"k -print0 2>/dev/null | \
                tar --null -czvf "$output_file" --files-from=-
    fi
    
}

filter_logs_by_days() { # Filter logs by modification time
    if [ "$USE_CONFIG_MODE" = false ]; then
        printf "Enter time threshold (in days) for archiving (files modified within N days): "
        read -r time_threshold
        printf "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): "
        read -r output_file
        output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
        find "$log_dir" -type f -mtime -"$time_threshold" -print0 2>/dev/null | \
            tar --null -czvf "$output_file" --files-from=-
    else
        output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
        find "$log_dir" -type f -mtime -"$time_threshold" -print0 2>/dev/null | \
            tar --null -czvf "$output_file" --files-from=-
    fi
}



filter_logs_by_keyword() { # Filter logs by keyword
    if [ "$USE_CONFIG_MODE" = false ]; then
        printf "Enter keyword for archiving logs: "
        read -r keyword
        printf "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): "
        read -r output_file
        output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
        grep -rilZ -- "$keyword" "$log_dir" 2>/dev/null | \
            tar --null -czvf "$output_file" --files-from=-
    else
        output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
        grep -rilZ -- "$keyword" "$log_dir" 2>/dev/null | \
            tar --null -czvf "$output_file" --files-from=-
    fi
}

delete_log_files() { # Cleanup temporary files if any
    if [ "$USE_CONFIG_MODE" = false ]; then
        echo "Enter time threshold (in days) for log deletion: "
        read -r time_threshold
        find "$log_dir" -type f -mtime +"$time_threshold" -delete || true
            echo "Old log files deleted."
    else
        find "$log_dir" -type f -mtime +"$time_threshold" -delete || true
            echo "Old log files deleted."
    fi
}


       

interactive_mode() { # Interactive/manual mode

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


