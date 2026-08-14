#!/bin/bash

# 5G Connection Loss Monitor
LOG_DIR="/home/pi/network_logs"
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/connection_loss_$DATE.txt"

mkdir -p $LOG_DIR

echo "===============================" >> $LOG_FILE
echo "5G Connection Monitor Started" >> $LOG_FILE
echo "Date: $(date)" >> $LOG_FILE
echo "Monitoring 5G interface: usb0" >> $LOG_FILE
echo "===============================" >> $LOG_FILE

echo "5G Connection Monitor Started - $(date)"

# Track connection state
WAS_CONNECTED=true
DISCONNECT_TIME=""
TOTAL_DROPS=0

while true; do
    # Test 5G connection
    ping -I usb0 -c 1 -W 3 8.8.8.8 > /dev/null 2>&1
    RESULT=$?

    if [ $RESULT -eq 0 ]; then
        # Connection is UP
        if [ "$WAS_CONNECTED" = false ]; then
            # Connection just came BACK
            RECONNECT_TIME=$(date)
            echo "" >> $LOG_FILE
            echo "CONNECTION RESTORED: $RECONNECT_TIME" >> $LOG_FILE
            echo "   Was disconnected since: $DISCONNECT_TIME" >> $LOG_FILE
            echo "   Total drops so far: $TOTAL_DROPS" >> $LOG_FILE
            echo "===============================" >> $LOG_FILE
            echo "CONNECTION RESTORED: $RECONNECT_TIME"
            WAS_CONNECTED=true
        fi
    else
        # Connection is DOWN
        if [ "$WAS_CONNECTED" = true ]; then
            # Connection just DROPPED
            DISCONNECT_TIME=$(date)
            TOTAL_DROPS=$((TOTAL_DROPS + 1))
            echo "" >> $LOG_FILE
            echo "CONNECTION LOST: $DISCONNECT_TIME" >> $LOG_FILE
            echo "   Drop number: $TOTAL_DROPS" >> $LOG_FILE
            echo "   Interface status:" >> $LOG_FILE
            ip addr show usb0 >> $LOG_FILE
            echo "   Signal at time of drop:" >> $LOG_FILE
            echo "Signal logging skipped" >> $LOG_FILE            
            echo "===============================" >> $LOG_FILE
            echo "CONNECTION LOST: $DISCONNECT_TIME"
            WAS_CONNECTED=false
        fi
    fi

    # Log status every 60 seconds
    echo "$(date): 5G Status - Connected: $WAS_CONNECTED - Total drops: $TOTAL_DROPS" >> $LOG_FILE

    sleep 10
done