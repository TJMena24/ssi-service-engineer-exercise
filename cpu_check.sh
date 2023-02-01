#!/bin/bash

# This script checks the CPU usage and sends an email to the specified address if
# the usage is above the critical or warning thresholds.

# Define the usage function
usage() {
  echo "Usage: $0 -c critical_threshold -w warning_threshold -e email_address"
}

# Get the options
while getopts "c:w:e:" opt; do
  case $opt in
    c) critical_threshold="$OPTARG" ;;
    w) warning_threshold="$OPTARG" ;;
    e) email_address="$OPTARG" ;;
    \?) usage && exit 1 ;;
  esac
done

# Ensure required options are provided
if [ -z "$critical_threshold" ] || [ -z "$warning_threshold" ] || [ -z "$email_address" ]; then
  usage && exit 1
fi

# Ensure that critical threshold is greater than warning threshold
if [ "$critical_threshold" -le "$warning_threshold" ]; then
  echo "Error: Critical threshold must be greater than warning threshold." && exit 1
fi

# Get the total CPU usage
total_cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/ | awk '{print 100 - $1"%"}'"))

# Calculate the used CPU percentage
used_cpu_percent=$((100 - total_cpu))

# Get the current date and time
current_date_time=$(date +%Y%m%d\ %H:%M)

# Check if used CPU is greater than or equal to critical threshold
if [ "$used_cpu_percent" -ge "$critical_threshold" ]; then
  # Get the top 10 processes that use a lot of CPU
  top_processes=$(ps aux --sort=-%cpu | head -n 11)
  # Send an email to the specified address
  echo -e "Subject: $current_date_time cpu_check - critical\n\n$top_processes" | mail -s "$current_date_time cpu_check - critical" "$email_address"
  # Exit with code 2
  exit 2
# Check if used CPU is greater than or equal to warning threshold but less than critical threshold
elif [ "$used_cpu_percent" -ge "$warning_threshold" ]; then
  # Send an email to the specified address
  echo -e "Subject: $current_date_time cpu_check - warning\n\nUsed CPU is above the warning threshold." | mail -s "$current_date_time cpu_check - warning" "$email_address"
  # Exit with code 1
  exit 1
# If used CPU is less than warning threshold
else
  # Exit with code 0
  exit 0
fi

