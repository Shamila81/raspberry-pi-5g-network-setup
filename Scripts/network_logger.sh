#!/bin/bash

# 5G Network Traffic Logger
LOG_DIR="/home/pi/network_logs"
DATE=$(date +%Y%m%d_%H%M%S)
PCAP_FILE="$LOG_DIR/5g_traffic_$DATE.pcap"
PING_FILE="$LOG_DIR/ping_log_$DATE.txt"
SIGNAL_FILE="$LOG_DIR/signal_log_$DATE.txt"
STATUS_FILE="$LOG_DIR/status_log_$DATE.txt"

mkdir -p $LOG_DIR

echo "==============================="
echo "5G Network Logger Started"
echo "Date: $(date)"
echo "Logs saved to: $LOG_DIR"
echo "==============================="

# Log 1 - Capture all packets on 5G interface
echo "Starting packet capture on usb0..."
tshark -i usb0 -w $PCAP_FILE &
TSHARK_PID=$!

# Log 2 - Continuous ping to check connection
echo "Starting ping logger..."
while true; do
    RESULT=$(ping -I usb0 -c 1 8.8.8.8 2>&1)
    echo "$(date): $RESULT" >> $PING_FILE
    sleep 5
done &
PING_PID=$!

# Log 3 - Log signal strength every 30 seconds
echo "Starting signal strength logger..."
while true; do
    echo "$(date): Checking signal..." >> $SIGNAL_FILE
    echo "AT+QENG=\"servingcell\"" | sudo tee /dev/ttyUSB2 >> $SIGNAL_FILE
    echo "AT+CSQ" | sudo tee /dev/ttyUSB2 >> $SIGNAL_FILE
    sleep 30
done &
SIGNAL_PID=$!

# Log 4 - Log connection status every 10 seconds
echo "Starting connection status logger..."
while true; do
    echo "$(date)" >> $STATUS_FILE
    echo "--- Interface Status ---" >> $STATUS_FILE
    ip addr show usb0 >> $STATUS_FILE
    echo "--- Route Table ---" >> $STATUS_FILE
    ip route >> $STATUS_FILE
    echo "========================" >> $STATUS_FILE
    sleep 10
done &
STATUS_PID=$!

echo "All loggers running!"
echo "Press Ctrl+C to stop"

# Wait and handle stop
trap "echo 'Stopping...'; kill $TSHARK_PID $PING_PID $SIGNAL_PID $STATUS_PID; exit" INT
wait