#!/usr/bin/env bash
set -euo pipefail

# logtool.sh
# Single-file log archiving tool
# Supports config-based mode or interactive/manual mode

###===========================config section===========================###
log_dir=""          # Directory containing log files
output_file=""    # Output archive file location
filter_type=""     # Type of filter: size = 1, time = 2, keyword = 3

### Filter parameters for size
size_threshold="" # Size threshold in KB for size filter

### Filter parameters for time
time_threshold="" # Time threshold in days for time filter

### Filter parameters for keyword
keyword=""        # Keyword for keyword filter


USE_CONFIG_MODE=false  # Set to true to use config mode, false for interactive/manual mode



###===========================interactive section===========================###


check_deps() {
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

print_menu() {
    echo "Log Archiving Tool - Interactive Mode"
    echo "1) Archive logs larger than a specified size"
    echo "2) Archive logs modified within a specified time frame"
    echo "3) Archive logs containing a specific keyword"
    echo "4) Exit"
}

check_dirs(){
    if [ ! -d "$log_dir" ]; then
        echo "Directory does not exist."
        exit 1
    elif [ ! -r "$log_dir" ] || [ ! -x "$log_dir" ]; then
        echo "Directory is not accessible. Check permissions (read+execute required)."
        exit 1
    fi
}

timestamp=$(date +%Y-%m-%d)

        filter_logs_by_size() {
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
        filter_logs_by_days() {
            if [ "$USE_CONFIG_MODE" = false ]; then
                printf "Enter time threshold (in days) for archiving (files modified within N days): "
                read -r time_threshold
                printf "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): "
                read -r output_file
                timestamp=$(date +%Y-%m-%d)
                output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
                find "$log_dir" -type f -mtime -"$time_threshold" -print0 2>/dev/null | \
                    tar --null -czvf "$output_file" --files-from=-
            else
                timestamp=$(date +%Y-%m-%d)
                output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
                find "$log_dir" -type f -mtime -"$time_threshold" -print0 2>/dev/null | \
                    tar --null -czvf "$output_file" --files-from=-
            fi
        }
        filter_logs_by_keyword() {
            if [ "$USE_CONFIG_MODE" = false ]; then
                printf "Enter keyword for archiving logs: "
                read -r keyword
                printf "Enter output file location (full path, e.g., /tmp/logs-archive.tar.gz): "
                read -r output_file
                timestamp=$(date +%Y-%m-%d)
                output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
                grep -rilZ -- "$keyword" "$log_dir" 2>/dev/null | \
                    tar --null -czvf "$output_file" --files-from=-
            else
                timestamp=$(date +%Y-%m-%d)
                output_file="${output_file%.tar.gz}-$timestamp.tar.gz"
                grep -rilZ -- "$keyword" "$log_dir" 2>/dev/null | \
                    tar --null -czvf "$output_file" --files-from=-
            fi
        }
       

interactive_mode() {
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
            4) echo "Goodbye."; exit 0 ;;
            *) echo "Invalid choice." ;;
        esac
    done
}

config_mode() {
    check_dirs
    case "$filter_type" in
        1) filter_logs_by_size ;;
        2) filter_logs_by_days ;;
        3) filter_logs_by_keyword ;;
        *) echo "Invalid filter type in config." ;;
    esac  
}

main() {
    check_deps
    if [ "$USE_CONFIG_MODE" = false ]; then
        interactive_mode
    else
        config_mode
    fi
}
main 


