#!/bin/bash

IP_ADDR="192.168.1.100"
INTERFACE="ems160"
DISK_DEV="sda"

get_elapsed_seconds() {
  current_time=$(date +%s)
  echo $((current_time - START_TIME))
}

start_process() {
    echo "Starting APM process..."
    # Simulate starting the APM process
    sleep 2
    echo "APM process started successfully."
}

process_metrics() {
    echo "Processing APM metrics..."
    # Simulate processing metrics
    sleep 2
    echo "APM metrics processed successfully."
}

system_metrics() {
    echo "Collecting system metrics..."
    # Simulate collecting system metrics
    sleep 2
    echo "System metrics collected successfully."
}


stop_process() {
    echo "Stopping APM process..."
    # Simulate stopping the APM process
    sleep 2
    echo "APM process stopped successfully."
}

# iudhgiudhfgiuhdfg