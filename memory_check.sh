#!/bin/bash

# This script checks the memory usage and sends an email to the specified address if
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

# Get the total memory and used memory
total_memory=$(free -m | grep Mem: | awk '{ print $2 }')
used_memory=$(free -m | grep Mem: | awk '{ print $3 }')

# Calculate the used memory percentage
used_memory_percent=$((used_memory * 100 / total_memory))

# Get the current date and time
current_date_time=$(date +%Y%m%d\ %H:%M)

# Check if used memory is greater than or equal to critical threshold
if [ "$used_memory_percent" -ge "$critical_threshold" ]; then
  # Get the top 10 processes that use a lot of memory
  top_processes=$(ps aux --sort=-%mem | head -n 11)
  # Send an email to the specified address
  echo -e "Subject: $current_date_time memory_check - critical\n\n$top_processes" | mail -s "$current_date_time memory_check - critical" "$email_address"
  # Exit with code 2
  exit 2
# Check if used memory is greater than or equal to warning threshold but less than critical threshold
elif [ "$used_memory_percent" -ge "$warning_threshold" ]; then
  # Send an email to the specified address
  echo -e "Subject: $current_date_time memory_check - warning\n\nUsed memory is above the warning threshold." | mail -s "$current_date_time memory_check - warning" "$email_address"
  # Exit with code 1
  exit 1
# If used memory is less than warning threshold
else
  # Exit with code 0
  exit 0
fi

