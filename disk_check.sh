#!/bin/bash

# This script checks the disk usage and sends an email to the specified address if
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

# Get the disk partition with used disk space greater than or equal to the specified threshold
disk_partition=$(df -P | awk -v threshold="$critical_threshold" '{if (100-$5 >= threshold) print $0}')

# Check if there's a disk partition with used disk space greater than or equal to critical threshold
if [ -n "$disk_partition" ]; then
  # Get the current date and time
  current_date_time=$(date +%Y%m%d\ %H:%M)
  # Send an email to the specified address with the partition details
  echo -e "Subject: $current_date_time disk_check - critical\n\n$disk_partition" | mail -s "$current_date_time disk_check - critical" "$email_address"
  # Exit with code 2
  exit 2
# Check if there's a disk partition with used disk space greater than or equal to warning threshold
elif [ "$warning_threshold" -le "$(df -P | awk '{if (100-$5 >= $threshold) used=1} END {print used}')" ]; then
  # Get the current date and time
  current_date_time=$(date +%Y%m%d\ %H:%M)
  # Send an email to the specified address with a warning message
  echo -e "Subject: $current_date_time disk_check - warning\n\nUsed disk space is above the warning threshold." | mail -s "$current_date_time disk_check - warning" "$email_address"
  # Exit with code 1
  exit 1
# If there's no disk partition with used disk space greater than or equal to warning threshold
else
  # Exit with code 0
  exit 0
fi

