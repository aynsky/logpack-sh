#!/bin/bash
# Nginx Log Analyzer Script
# Usage: ./nginx_log_analyser.sh /path/to/nginx/access.log

LOG_FILE="${1:-nginx.log}"

if [[ ! -f "$LOG_FILE" ]]; then
    echo "Error: Log file '$LOG_FILE' does not exist."
    exit 1
fi

total=$(wc -l < "$LOG_FILE")

# Function to print section headers
print_header() {
    printf "\n%-25s %10s %12s\n" "$1" "Requests" "(Percentage)"
    printf "%-25s %10s %12s\n" "------------------------" "--------" "-----------"
}

# Top 5 IPs
print_header "IP Address"
awk '{print $1}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 \
| awk -v total=$total '{percent=$1*100/total; printf "%-25s %10d %12.2f%%\n", $2, $1, percent}'

# Top 5 Paths
print_header "Path"
awk '{print $7}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 \
| awk -v total=$total '{percent=$1*100/total; printf "%-25s %10d %12.2f%%\n", $2, $1, percent}'

# Top 5 Status Codes
print_header "Status Code"
awk '{print $9}' "$LOG_FILE" | sort | uniq -c | sort -nr | head -5 \
| awk -v total=$total '{percent=$1*100/total; printf "%-25s %10d %12.2f%%\n", $2, $1, percent}'

# Top 5 User-Agents
echo -e "\nTop 5 User Agents:"
awk -F\" '{print $6}' "$LOG_FILE" \
| sort | uniq -c | sort -nr | head -5 \
| awk -v total=$total '{
    count=$1; $1=""; sub(/^ /,""); ua=$0;
    percent=count*100/total;
    printf "%-60s %10d %12.2f%%\n", substr(ua,1,60), count, percent
}'

# Hourly distribution
echo -e "\nRequests per Hour:"
printf "%-16s %10s %12s\n" "Hour" "Requests" "(Percentage)"
printf "%-16s %10s %12s\n" "----------------" "--------" "-----------"
awk '{split($4, a, ":"); print a[1]":"a[2]}' "$LOG_FILE" \
| sort | uniq -c | sort -nr \
| awk -v total=$total '{percent=$1*100/total; printf "%-16s %10d %12.2f%%\n", $2, $1, percent}'

# Error rate
errors=$(awk '$9 ~ /^[45]/ {count++} END {print count+0}' "$LOG_FILE")
percent=$(echo "scale=2; $errors*100/$total" | bc)
echo -e "\nError Rate: $percent% of requests returned errors ($errors out of $total)"
