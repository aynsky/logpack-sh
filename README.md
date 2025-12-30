# Bash Log Management Tools

A collection of lightweight, dependency-minimal Bash scripts for analyzing and managing server logs. Perfect for system administrators, DevOps engineers, and anyone dealing with log file management.

## 🛠️ Tools Included

### 1. Nginx Log Analyzer (`nginx_log_analyser.sh`)
Analyze Nginx access logs and generate detailed traffic statistics with zero configuration.

**Key Features:**
- Top 5 IP addresses, paths, status codes, and user agents
- Hourly traffic distribution
- Error rate calculation
- Percentage-based insights


---

### 2. Log Archive Tool (`logtool.sh`)
Flexible log archiving and cleanup utility with both interactive and configuration-based modes.

**Key Features:**
- Filter logs by size, modification time, or keyword content
- Automated log deletion for cleanup
- Interactive menu-driven interface
- Config file support for automation
- Timestamped archive creation


---

## 🚀 Quick Start

### Clone the Repository
```bash
git clone https://github.com/aynsky/logpack-sh.git
cd bash-log-tools
```

### Make Scripts Executable
```bash
chmod +x nginx_log_analyser.sh logtool.sh
```

### Run a Tool
```bash
# Analyze Nginx logs
./nginx_log_analyser.sh /var/log/nginx/access.log

# Archive logs interactively
./logtool.sh
```

## 📋 Requirements

All scripts require standard Unix utilities available on most Linux distributions:

- Bash 4.0 or higher
- `awk`, `sed`, `grep`
- `find`, `tar`
- `sort`, `uniq`, `wc`
- `bc` (for nginx_log_analyser.sh)
- `date`

### Installing Missing Dependencies

**Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install gawk tar findutils bc coreutils
```

**CentOS/RHEL:**
```bash
sudo yum install gawk tar findutils bc coreutils
```

**macOS:**
```bash
brew install coreutils gnu-tar gawk bc
```

## 📖 Usage Overview

### Nginx Log Analyzer
```bash
# Basic analysis
./nginx_log_analyser.sh /var/log/nginx/access.log

# Save report to file
./nginx_log_analyser.sh /var/log/nginx/access.log > report.txt

# Analyze filtered logs
grep "01/Jan/2024" /var/log/nginx/access.log | ./nginx_log_analyser.sh
```

### Log Archive Tool

**Interactive Mode:**
```bash
./logtool.sh
# Follow the menu prompts
```

**Config Mode:**
```bash
# Edit configuration section in logtool.sh
USE_CONFIG_MODE=true
log_dir="/var/log"
filter_type="1"  # 1=size, 2=time, 3=keyword, 4=delete
size_threshold="1000"
output_file="/backup/logs-archive.tar.gz"

# Run with config
./logtool.sh
```

## 🎯 Common Use Cases

### Daily Log Analysis
```bash
# Analyze today's traffic
./nginx_log_analyser.sh /var/log/nginx/access.log > daily-report-$(date +%Y%m%d).txt
```

### Automated Log Archival
```bash
# Archive large logs weekly (via cron)
0 2 * * 0 /path/to/logtool.sh
```

### Log Cleanup
```bash
# Delete logs older than 30 days
./logtool.sh
# Choose option 4, enter 30 days
```

### Incident Investigation
```bash
# Find all logs containing error keyword
./logtool.sh
# Choose option 3, enter "ERROR" or "500"
```

## 🔧 Automation with Cron

Add to crontab (`crontab -e`):

```bash
# Daily Nginx log analysis at 1 AM
0 1 * * * /opt/scripts/nginx_log_analyser.sh /var/log/nginx/access.log > /var/reports/nginx-$(date +\%Y\%m\%d).txt

# Weekly log archival on Sundays at 2 AM
0 2 * * 0 /opt/scripts/logtool.sh

# Monthly cleanup of logs older than 90 days
0 3 1 * * /opt/scripts/logtool.sh
```

## 📊 Sample Outputs

### Nginx Log Analyzer Output
```
IP Address                Requests  (Percentage)
------------------------  --------  -----------
192.168.1.100                 1250       25.00%
10.0.0.50                      980       19.60%

Status Code               Requests  (Percentage)
------------------------  --------  -----------
200                           4200       84.00%
404                            450        9.00%

Error Rate: 12.50% of requests returned errors (625 out of 5000)
```

### Log Archive Tool Output
```
Archive created successfully: /backup/logs-archive-2024-01-15.tar.gz
Files archived: 47
Total size: 2.3 GB
```

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Make your changes
4. Test thoroughly
5. Commit your changes (`git commit -am 'Add new feature'`)
6. Push to the branch (`git push origin feature/improvement`)
7. Open a Pull Request

### Contribution Ideas
- Add support for other web server log formats (Apache, Caddy)
- Implement compression ratio reporting
- Add email notification support
- Create log rotation integration
- Add support for remote log analysis

## 🐛 Troubleshooting

### Permission Issues
```bash
# Grant execution permissions
chmod +x *.sh

# Run with sudo for system logs
sudo ./nginx_log_analyser.sh /var/log/nginx/access.log
```

### Missing Dependencies
```bash
# Check what's missing
for cmd in find tar grep awk bc date; do 
    command -v $cmd >/dev/null || echo "Missing: $cmd"
done
```

### Log Format Issues
Ensure your Nginx uses the standard combined log format:
```nginx
log_format combined '$remote_addr - $remote_user [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    '"$http_referer" "$http_user_agent"';
```

## 📝 License

MIT License - See [LICENSE](LICENSE) file for details.

## 👤 Author

Created and maintained by system administrators for system administrators.

## 🌟 Star History

If you find these tools useful, please consider giving the repository a star!


## 🔗 Related Projects

- [GoAccess](https://goaccess.io/) - Real-time web log analyzer
- [Logrotate](https://github.com/logrotate/logrotate) - Log rotation utility
- [Lnav](https://lnav.org/) - Advanced log file viewer

---

**Made with ❤️ for the DevOps community**

---
This project is part of the roadmap.sh DevOps projects: https://roadmap.sh/projects/nginx-log-analyser
