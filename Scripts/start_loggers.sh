#!/bin/bash

# Wait for network to be ready
sleep 30

LOG_DIR="/home/pi/network_logs"
mkdir -p $LOG_DIR

# Start AT command logger
bash /home/pi/at_logger.sh > $LOG_DIR/at_logger_output.txt 2>&1 &

# Start connection monitor
bash /home/pi/connection_monitor.sh > $LOG_DIR/monitor_output.txt 2>&1 &

# Start tshark packet capture directly
DATE=$(date +%Y%m%d_%H%M%S)
tshark -i usb0 -w $LOG_DIR/5g_traffic_$DATE.pcap > $LOG_DIR/tshark_output.txt 2>&1 &

echo "All loggers started at $(date)" >> $LOG_DIR/startup.txt