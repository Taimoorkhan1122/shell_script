#!/bin/bash

# Check if the correct number of arguments are provided
if [ "$#" -ne 2 ]; then
    echo "Usage: ./disk_space_monitor.sh <threshold> <email>"
    exit 1
fi

# Assign the arguments to variables
THRESHOLD=$1
EMAIL=$2

# Check if the threshold is a number
if ! [[ $THRESHOLD =~ ^[0-9]+$ ]]; then
    echo "Error: Threshold must be a number."
    exit 1
fi

# Check if the threshold is between 0 and 100
if [ $THRESHOLD -lt 0 ] || [ $THRESHOLD -gt 100 ]; then
    echo "Error: Threshold must be between 0 and 100."
    exit 1
fi

# Get the disk space usage
USAGE=$(df --output=pcent,target | tail -n +2 | tr -dc '0-9\n' | awk -v threshold=$THRESHOLD '$1 > threshold {print $1, $2}')

# Check if any partition exceeds the threshold
if [ -z "$USAGE" ]; then
    echo "No partitions exceed the threshold."
    exit 0
fi

# Send an email alert
echo -e "The following partitions exceed the disk space usage threshold of $THRESHOLD%:\n$USAGE" | mail -s "Disk Space Alert" $EMAIL

# Check if the email was sent successfully
if [ $? -eq 0 ]; then
    echo "Email alert sent successfully."
else
    echo "Error: Failed to send email alert."
    exit 1
fi
