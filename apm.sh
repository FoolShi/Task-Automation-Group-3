#!/bin/bash

IP_ADDR="192.168.1.100"
INTERFACE="ems160"
DISK_DEV="sda"
PROC_ARR=(APM1, APM2, APM3, APM4, APM5, APM6)
PID_ARR=()
#START_TIME=$(date +%s)

start_process() {
    echo "Starting APM process..."
    # Simulate starting the APM process
    for i in $PROC_ARR
    do
        ./$[PROC_ARR[i]]
        pid=$(pgrep $PROC_ARR[i])
        if [ -z "$pid" ]
            echo "Error in starting processes..."
            exit 1
        else
            PID_ARR+=$pid
            exit 0
    done
    sleep 5
    echo "All APM processes started successfully"
}

process_metrics() {
    echo "Processing APM metrics..."
    # Simulate processing metrics
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