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
    for process in "${PROC_ARR[@]}";
    do
        ./"$process" &
        pid=$!

        if [ -z "$pid" ]; then
            echo "Error in starting $proc..."
            exit 1
        else
            PID_ARR+=("$pid")
        fi
    done

    sleep 5
    echo "All APM processes started successfully!"
    echo "PIDs: ${PID_ARR[@]}"
}

process_metrics() {
    echo "Processing APM metrics..."
    # Simulate processing metrics
    for i in "${PID_ARR[@]}";
    do 
        PROC_NAME=$(ps -p "$i" -o comm=)
        CSV_FILE="${PROC_NAME}_metrics.csv"
    done

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        for i in "${PID_ARR[@]}";
        do
            METRICS=$(ps -p "$PID" -o %cpu,%mem --no-headers | awk '{print "%.1f,%.1f", $1, $2}')
            echo "${ELASPED},${METRICS}" >> "$CSV_FILE" #change to format with elasped time
        done
    sleep 5
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