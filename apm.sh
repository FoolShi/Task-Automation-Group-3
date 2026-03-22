#!/bin/bash

IP_ADDR="192.168.1.100"
INTERFACE="ems160"
DISK_DEV="sda"

PROC_ARR=(APM1 APM2 APM3 APM4 APM5 APM6)
PID_ARR=()

START_TIME=$(date +%s)

start_process() {
    echo "Starting APM process..."
    
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

process_metrics() {
    echo "Processing APM metrics..."

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))

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

system_metrics() {
    echo "Collecting system metrics..."

    SYS_FILE="system_metrics.csv"

    while true; do
        CURRENT_TIME=$(date +%s)
        ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
        
        RATES=$(ifstat -i "$INTERFACE" 1 1 2>/dev/null | tail -1 | awk '{print $1 ", " $2}')
        [ -z "$RATES"  ] && RATES="0,0"
        
        WRITES=$(iostat -d -y "$DISK_DEV" 1 1 2>/dev/null | tail -1 | awk '{print $3}')
        [ -z "$WRITES"  ] && WRITES="0"

        AVAILABLE=$(df / | tail -1 | awk '{print $4}')
        
        echo "${ELAPSED_TIME},${RATES},${WRITES},${AVAILABLE}" >> "$SYS_FILE"     
        
        sleep 5 
    done    
}


cleanup() {
    echo "Stopping APM processes..."

    for pid in "${PID_ARR[@]}"; do
        kill "$pid" 2>/dev/null
    done

    pkill -P $$
    
    echo "Cleanup complete!"
    exit
}

trap cleanup SIGINT

start_process
process_metrics &
system_metrics &

wait