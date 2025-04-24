# DLT Log Analyzer

A Bash-based tool for analyzing and interacting with log files. It supports parsing, filtering, summarizing, and generating reports for logs using simple CLI interactions.

---

## 🔍 Features

- **Log Parsing**: Extracts and displays timestamp, log level, and message.
- **Filtering**: Filters logs by user-selected levels like `ERROR`, `WARN`, `INFO`, or `DEBUG`.
- **Error and Warning Summary**: Provides a count and details of all `ERROR` and `WARN` entries.
- **Event Tracking**: Tracks custom event keywords input by the user.
- **Report Generation**: Generates a summary for all log levels including details.

---

## 📁 File Format Assumption

The script assumes each log entry follows this structure:
[YYYY-MM-DD HH:MM:SS] <Component> <LOG_LEVEL> Message...
Example:
[2024-07-24 18:23:59] engine ERROR Engine failure detected

## 🚀 How to Use

### 1. Make the script executable
chmod +x log_analyzer.sh
### 2. Run the script 
./log_analyzer.sh path/to/logfile.log
