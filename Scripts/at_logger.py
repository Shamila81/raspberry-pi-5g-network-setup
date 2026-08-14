#!/usr/bin/env python3

import serial
import time
import os
from datetime import datetime

LOG_DIR = "/home/pi/network_logs"
os.makedirs(LOG_DIR, exist_ok=True)

DATE = datetime.now().strftime("%Y%m%d_%H%M%S")
AT_FILE = f"{LOG_DIR}/at_log_{DATE}.txt"

def send_at(ser, cmd, wait=2):
    ser.write((cmd + "\r\n").encode())
    time.sleep(wait)
    response = ""
    while ser.in_waiting:
        response += ser.read(ser.in_waiting).decode(errors="ignore")
        time.sleep(0.1)
    return response.strip()

with open(AT_FILE, "a") as f:
    f.write("===============================\n")
    f.write("AT Command Logger Started\n")
    f.write(f"Date: {datetime.now()}\n")
    f.write("===============================\n")

print(f"Logging to {AT_FILE}")

while True:
    try:
        with serial.Serial("/dev/ttyUSB3", 115200, timeout=3) as ser:
            time.sleep(1)
            with open(AT_FILE, "a") as f:
                f.write(f"\n--- {datetime.now()} ---\n")

                cmds = [
                    ("AT+CSQ", "Signal Strength"),
                    ("AT+C5GREG?", "5G Registration"),
                    ('AT+QENG="servingcell"', "Serving Cell Info"),
                    ("AT+CPIN?", "SIM Status"),
                ]

                for cmd, label in cmds:
                    response = send_at(ser, cmd)
                    f.write(f"{label}: {cmd}\n")
                    f.write(f"{response}\n")
                    f.write("\n")

                f.write("========================\n")
                f.flush()

    except Exception as e:
        with open(AT_FILE, "a") as f:
            f.write(f"Error: {e}\n")

    time.sleep(60)