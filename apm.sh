#!/bin/bash

IP_ADDR="192.168.1.100"
INTERFACE="ems160"
DISK_DEV="sda"

# initializing arrays for APM processes and their corresponding PIDs
PROC_ARR=(APM1 APM2 APM3 APM4 APM5 APM6)
PID_ARR=()

START_TIME=$(date +%s)

# Starts each APM process in the background, stores their PIDs in PID_ARR, and confirms their successful startup
start_process() {
    echo "Starting APM processes..."
    
    for process in "${PROC_ARR[@]}"; do
        ./"$process" "$IP_ADDR" &
        pid=$!

        if [ -z "$pid" ]; then
            echo "Error in starting $process..."
            exit 1
        else
            PID_ARR+=("$pid")
        fi
    done

    sleep 2
    echo "Processes started: ${PID_ARR[@]}"
}

# Continuously logs CPU and Memory usage for each running PID in PID_ARR to CSV files every 5 seconds, stopping after 15 minutes
process_metrics() {
    echo "Processing APM metrics..."

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        # stop after 15 minutes (900 seconds)
        if [ "$ELAPSED_TIME" -ge 900 ]; then
        	echo "15 minutes reached. Stopping processes..."
        	cleanup
        fi

        for pid in "${PID_ARR[@]}"; do
            if ps -p "$pid" > /dev/null 2>&1; then

                PROC_NAME=$(ps -p "$pid" -o comm=)
                METRICS=$(ps -p "$pid" -o %cpu,%mem --no-headers | awk '{printf "%.1f,%.1f\n", $1, $2}')
                CSV_FILE="${PROC_NAME}_metrics.csv"
                echo "${ELAPSED_TIME},${METRICS}" >> "$CSV_FILE"
            fi 

        done
        sleep 5
    done 
}

# Continuously logs system metrics (network Rx/Tx rates, disk writes, and avaiable disk space) to a CSV file every 5 seconds, stopping after 15 minutes
system_metrics() {
    echo "Collecting system metrics..."

    SYS_FILE="system_metrics.csv"

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

        # stop after 15 minutes (900 seconds)
        if [ "$ELAPSED_TIME" -ge 900 ]; then
        	echo "15 minutes reached. Stopping processes..."
        	cleanup
        fi
        
        RATES=$(ifstat -i "$INTERFACE" 1 1 2>/dev/null | tail -1 | awk '{print $1 ", " $2}')
        [ -z "$RATES"  ] && RATES="0,0"
        
        WRITES=$(iostat -d -y "$DISK_DEV" 1 1 2>/dev/null | tail -1 | awk '{print $3}')
        [ -z "$WRITES"  ] && WRITES="0"

        AVAILABLE=$(df / | tail -1 | awk '{print $4}')
        
        echo "${ELAPSED_TIME},${RATES},${WRITES},${AVAILABLE}" >> "$SYS_FILE"     
        
        sleep 5 
    done    
}

# Terminates all tracked APM processes nd any child processes of the script, then exits cleanly
cleanup() {
    echo "Stopping APM processes..."

    for pid in "${PID_ARR[@]}"; do
        kill "$pid" 2>/dev/null
    done

    pkill -P $$
    
    echo "Cleanup complete!"
    exit
}

# Calls the cleanup function when a SIGINT signal is received, ensuring processes are terminated properly
trap cleanup SIGINT

# Starts the processes, runs process and system metrics collection in parallel (background), and waits for them to finish
start_process
process_metrics &
system_metrics &

wait