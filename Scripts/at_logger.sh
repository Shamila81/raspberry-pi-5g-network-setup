#!/bin/bash

LOG_DIR="/home/pi/network_logs"
DATE=$(date +%Y%m%d_%H%M%S)
AT_FILE="$LOG_DIR/at_log_$DATE.txt"

mkdir -p $LOG_DIR

echo "===============================" >> $AT_FILE
echo "AT Command Logger Started" >> $AT_FILE
echo "Date: $(date)" >> $AT_FILE
echo "===============================" >> $AT_FILE

while true; do
    echo "" >> $AT_FILE
    echo "--- $(date) ---" >> $AT_FILE

    # Use stty to configure port then send commands
    stty -F /dev/ttyUSB3 115200 cs8 -cstopb -parenb

    # Send each command and capture response
    for CMD in "AT+CSQ" "AT+C5GREG?" 'AT+QENG="servingcell"' "AT+CPIN?"; do
        echo "$CMD" >> $AT_FILE
        echo -e "$CMD\r" > /dev/ttyUSB3
        sleep 2
        timeout 3 cat /dev/ttyUSB3 >> $AT_FILE 2>/dev/null
        echo "" >> $AT_FILE
    done

    echo "========================" >> $AT_FILE
    sleep 60
done