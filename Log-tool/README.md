# Log Archiving Tool

A flexible bash script for archiving and managing log files with support for multiple filtering methods and operating modes.

## Features

- **Multiple Filtering Options**
  - Archive logs by file size
  - Archive logs by modification time
  - Archive logs containing specific keywords
  - Delete old log files based on age

- **Two Operating Modes**
  - **Interactive Mode**: User-friendly menu-driven interface
  - **Config Mode**: Automated execution with pre-configured settings

- **Smart Archive Management**
  - Automatic timestamp appending to archive filenames
  - Validation before creating empty archives
  - Comprehensive error handling and user feedback

## Requirements

The script requires the following commands to be available on your system:
- `find`
- `tar`
- `grep`
- `date`

These are typically pre-installed on most Unix-like systems (Linux, macOS, BSD).

## Installation

1. Download the script:
   ```bash
   git clone https://github.com/aynsky/logpack-sh.git 
   ```

2. Make it executable:
   ```bash
   chmod +x logtool.sh
   ```

3. Optionally, move it to your PATH:
   ```bash
   sudo mv logtool.sh /usr/local/bin/logtool
   ```

## Usage

### Interactive Mode (Default)

Simply run the script without any configuration:

```bash
./logtool.sh
```

You'll be presented with an interactive menu:

```
    __                   ___                __    _             
   / /   ____  ____ _   /   |  __________  / /_  (_)   _____    
  / /   / __ \/ __ `/  / /| | / ___/ ___/ / __ \/ / | / / _ \   
 / /___/ /_/ / /_/ /  / ___ |/ /  / /__  / / / / /| |/ /  __/   
/_____/\____/\__, /  /_/  |_/_/   \___/ /_/ /_/_/ |___/\___/    
            /____/     
            >> Filter by: Size | Date | Keyword <<

 Log Archiving Tool - Interactive Mode

1) Archive logs larger than a specified size
2) Archive logs modified within a specified time frame
3) Archive logs containing a specific keyword
4) Delete log files older than a specified time frame
5) Exit
```

Follow the on-screen prompts to select your operation and provide the necessary parameters.

### Config Mode

For automated or scheduled execution, you only need to configure the parameters relevant to your chosen filter type.

**Important:** Only fill in the parameters needed for your specific filter. You don't need to set all parameters—just the ones required for your chosen `filter_type`.

#### Filter Types

| Filter Type | Value | Description |
|-------------|-------|-------------|
| Size | `1` | Archive files larger than threshold |
| Time | `2` | Archive files modified within N days |
| Keyword | `3` | Archive files containing keyword |
| Delete | `4` | Delete files older than N days |

## Configuration Examples

### Example 1: Archive by Size (Filter Type 1)

**What you need:**
- Log directory path
- Output file location
- Filter type = `1`
- Size threshold (in KB)

**Configuration:**
```bash
###===========================config section===========================###
log_dir="/var/log/myapp"
output_file="/backups/large-logs.tar.gz"
filter_type="1"

### Filter parameters for size
size_threshold="5120"  # 5MB in kilobytes

USE_CONFIG_MODE=true
```

**Result:** Archives all files larger than 5MB from `/var/log/myapp` into `/backups/large-logs-20241228-143052.tar.gz`

---

### Example 2: Archive by Time (Filter Type 2)

**What you need:**
- Log directory path
- Output file location
- Filter type = `2`
- Time threshold (in days)

**Configuration:**
```bash
###===========================config section===========================###
log_dir="/var/log/myapp"
output_file="/backups/recent-logs.tar.gz"
filter_type="2"

### Filter parameters for time
time_threshold="7"  # Files modified within last 7 days

USE_CONFIG_MODE=true
```

**Result:** Archives all files modified in the last 7 days from `/var/log/myapp` into `/backups/recent-logs-20241228-143052.tar.gz`

---

### Example 3: Archive by Keyword (Filter Type 3)

**What you need:**
- Log directory path
- Output file location
- Filter type = `3`
- Keyword to search for

**Configuration:**
```bash
###===========================config section===========================###
log_dir="/var/log/myapp"
output_file="/backups/error-logs.tar.gz"
filter_type="3"

### Filter parameters for keyword
keyword="ERROR"

USE_CONFIG_MODE=true
```

**Result:** Archives all files containing the word "ERROR" from `/var/log/myapp` into `/backups/error-logs-20241228-143052.tar.gz`

---

### Example 4: Delete Old Logs (Filter Type 4)

**What you need:**
- Log directory path
- Filter type = `4`
- Time threshold (in days)

**Configuration:**
```bash
###===========================config section===========================###
log_dir="/var/log/myapp"
filter_type="4"

### Filter parameters for time
time_threshold="30"  # Delete files older than 30 days

USE_CONFIG_MODE=true
```

**Note:** The `output_file` parameter is not needed for delete operations.

**Result:** Deletes all files older than 30 days from `/var/log/myapp`

---

## Quick Reference: What to Configure

| Filter Type | Required Parameters |
|-------------|---------------------|
| **Size (1)** | `log_dir`, `output_file`, `filter_type="1"`, `size_threshold` |
| **Time (2)** | `log_dir`, `output_file`, `filter_type="2"`, `time_threshold` |
| **Keyword (3)** | `log_dir`, `output_file`, `filter_type="3"`, `keyword` |
| **Delete (4)** | `log_dir`, `filter_type="4"`, `time_threshold` |

## Running in Config Mode

After configuring the parameters, simply run:

```bash
./logtool.sh
```

The script will automatically execute based on your configuration.

## Automation with Cron

Schedule regular log archiving using cron:

```bash
# Edit crontab
crontab -e

# Example 1: Archive large logs daily at 2 AM
0 2 * * * /path/to/logtool.sh

# Example 2: Delete old logs weekly on Sunday at 3 AM
0 3 * * 0 /path/to/logtool.sh
```

**Pro Tip:** Create separate copies of the script with different configurations for different scheduled tasks.

## Output

### Archive Naming Convention

Archives are automatically timestamped to prevent overwriting:

```
Configuration:    output_file="/backups/logs-archive.tar.gz"
Generated file:   /backups/logs-archive-20241228-143052.tar.gz
Format:           {basename}-YYYYMMDD-HHMMSS.tar.gz
```

### Success Messages

```bash
# Archive created successfully
Archive created successfully: /backups/logs-archive-20241228-143052.tar.gz

# No matching files found
No files found larger than 1024KB. Archive not created.
No files modified within last 7 days. Archive not created.
No files found containing keyword 'ERROR'. Archive not created.

# Delete operation
Old log files deleted successfully.
No files older than 30 days to delete.
```

### Error Messages

```bash
Error: Failed to create archive /backups/logs-archive.tar.gz
Directory does not exist.
Directory is not accessible. Check permissions (read+execute required).
Missing required commands: tar grep
```

## Permissions

### Required Permissions

- **Read permission** (`r`) on the log directory
- **Execute permission** (`x`) on the log directory (to traverse it)
- **Write permission** (`w`) on the output directory (for creating archives)
- **Delete permission** on log files (for delete operation)

### Example Permission Setup

```bash
# Make log directory readable
chmod 755 /var/log/myapp

# Ensure output directory is writable
mkdir -p /backups
chmod 755 /backups
```

## Troubleshooting

### "Directory does not exist"
**Solution:** Verify the path is correct
```bash
ls -ld /var/log/myapp
```

### "Directory is not accessible"
**Solution:** Check read and execute permissions
```bash
chmod 755 /var/log/myapp
```

### "Failed to create archive"
**Possible causes:**
- Output directory doesn't exist: `mkdir -p /backups`
- No write permission: `chmod 755 /backups`
- Insufficient disk space: `df -h`

### "Missing required commands"
**Solution:** Install missing packages
```bash
# Debian/Ubuntu
sudo apt-get install tar findutils grep coreutils

# RHEL/CentOS/Fedora
sudo yum install tar findutils grep coreutils

# macOS (usually pre-installed)
# No action needed
```

### No files archived
**Troubleshooting steps:**
1. Verify files exist: `ls -lh /var/log/myapp`
2. Check if threshold is too strict (size too large, date too narrow)
3. For keyword search, remember it's case-sensitive
4. Test your find command manually:
   ```bash
   find /var/log/myapp -type f -size +5120k
   find /var/log/myapp -type f -mtime -7
   grep -ril "ERROR" /var/log/myapp
   ```

## Best Practices

1. **Test First**: Always test in interactive mode with a test directory before setting up config mode
2. **Start Small**: Begin with conservative thresholds and adjust as needed
3. **Backup Before Delete**: Always create an archive before using the delete function
4. **Monitor Disk Space**: Ensure sufficient space before archiving: `df -h`
5. **Verify Archives**: Test your archives after creation:
   ```bash
   tar -tzf /backups/logs-archive-20241228-143052.tar.gz
   ```
6. **Use Absolute Paths**: Always use full paths in config mode to avoid confusion
7. **Separate Configs**: For cron jobs, create separate script copies with different configurations

## Common Use Cases

### Daily Large File Archiving
```bash
log_dir="/var/log/webapp"
output_file="/backups/daily/large-logs.tar.gz"
filter_type="1"
size_threshold="10240"  # 10MB
USE_CONFIG_MODE=true
```
**Cron:** `0 1 * * * /path/to/logtool-daily.sh`

### Weekly Error Log Collection
```bash
log_dir="/var/log/webapp"
output_file="/backups/weekly/errors.tar.gz"
filter_type="3"
keyword="ERROR"
USE_CONFIG_MODE=true
```
**Cron:** `0 2 * * 0 /path/to/logtool-errors.sh`

### Monthly Cleanup
```bash
log_dir="/var/log/webapp"
filter_type="4"
time_threshold="90"  # Delete logs older than 90 days
USE_CONFIG_MODE=true
```
**Cron:** `0 3 1 * * /path/to/logtool-cleanup.sh`

## Security Considerations

- Run with minimum required privileges (avoid root unless necessary)
- Be extremely careful with delete operations—files cannot be recovered
- Use absolute paths to prevent accidental operations on wrong directories
- Protect the script file if it contains sensitive paths
- Review what will be archived/deleted before running in production
- Set appropriate file permissions: `chmod 750 logtool.sh`

## Tips & Tricks

### Multiple Operations with One Script
Create symbolic links or copies with different names:
```bash
cp logtool.sh logtool-size.sh
cp logtool.sh logtool-cleanup.sh
# Configure each separately
```

### Preview Before Archiving
Test your filter criteria manually:
```bash
# Size
find /var/log -type f -size +5120k -ls

# Time
find /var/log -type f -mtime -7 -ls

# Keyword
grep -ril "ERROR" /var/log
```

### Extract Archives
```bash
# List contents
tar -tzf archive.tar.gz

# Extract to current directory
tar -xzf archive.tar.gz

# Extract to specific directory
tar -xzf archive.tar.gz -C /restore/location/
```

## License

This script is provided as-is without any warranty. Feel free to modify and distribute according to your needs.

## Contributing

Contributions, issues, and feature requests are welcome. Please ensure any changes maintain backward compatibility and include appropriate error handling.

## Version History

- **v1.0**: Initial release
  - Interactive and config modes
  - Size, time, and keyword-based filtering
  - Automatic timestamp appending
  - Comprehensive error handling

---

**Need Help?** Run the script in interactive mode and follow the prompts—it's designed to guide you through each step!


This project is part of the roadmap.sh DevOps projects:
https://roadmap.sh/projects/log-archive-tool
