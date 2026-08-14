# Raspberry Pi 5G Network Setup

This project documents the setup, configuration, testing, and monitoring of a **Waveshare RM520N-GL 5G HAT** with a **Raspberry Pi 5** for connecting to a private 5G laboratory network.

The project focuses on validating 5G connectivity, monitoring network stability, capturing network traffic, logging 5G module information, and automatically starting monitoring scripts after boot.

## Project Overview

The Raspberry Pi 5 is connected to the Waveshare RM520N-GL 5G HAT using USB 3.0. The RM520N-GL module connects to a private 5G NR Standalone network.

The project includes:

* Raspberry Pi 5 and RM520N-GL 5G HAT configuration
* 5G network registration and connectivity testing
* AT command testing and logging
* Network traffic capture using `tshark`
* Connection loss monitoring
* Ping and interface status logging
* Automatic startup of monitoring scripts
* 5G network performance testing

## Hardware

### Main Components

* Raspberry Pi 5
* Waveshare RM520N-GL 5G HAT
* Quectel RM520N-GL 5G module
* 4 × LTE-A MIMO antennas
* IPEX antenna cables
* Nano SIM card provisioned for the private 5G network
* USB 3.0 dual-plug cable
* 5V 3A USB-C external power supply
* MicroSD card

The RM520N-GL module is installed on the Waveshare HAT and connected to the Raspberry Pi through USB 3.0.

## Software

* Raspberry Pi OS 64-bit
* SSH
* Minicom
* TShark
* Python 3
* Bash
* Git

## Repository Structure

```text
raspberry-pi-5g-network-setup/
│
├── 5G_Project_Report.pdf
│
├── Scripts/
│   ├── at_logger.py
│   ├── at_logger.sh
│   ├── connection_monitor.sh
│   ├── network_logger.sh
│   └── start_loggers.sh
│
└── logs/
    ├── 5g_traffic.pcap
    ├── ping_log.txt
    └── status_log.txt
```

## Hardware Setup

The main hardware configuration is:

1. Install the RM520N-GL module in the M.2 slot.
2. Set the HAT DIP switches to:

   * C = ON
   * A = OFF
   * B = OFF
3. Connect the four antenna cables.
4. Attach the four antennas.
5. Insert the Nano SIM card into SIM1.
6. Connect the HAT to the Raspberry Pi 5 using USB 3.0.
7. Set the HAT power switch to `EXT PWR`.
8. Connect a 5V 3A USB-C power supply to the HAT.

External 5V 3A power is required for reliable operation of the 5G module.

## 5G Module Configuration

After connecting to the Raspberry Pi through SSH, the RM520N-GL module can be detected using:

```bash
usb-devices
```

Serial ports can be checked with:

```bash
ls /dev/ttyUSB*
```

Minicom can be used to communicate with the module:

```bash
sudo minicom -D /dev/ttyUSB2
```

Basic AT commands were used to verify the module and network registration.

Examples:

```text
AT
AT+CPIN?
AT+C5GREG?
AT+COPS?
AT+QENG="servingcell"
```

The module was configured to use ECM USB network mode:

```text
AT+QCFG="usbnet",1
```

The module was then restarted using:

```text
AT+CFUN=1,1
```

The ECM configuration created the `usb0` network interface on Raspberry Pi OS.

## 5G Connectivity Test

After configuration, the 5G interface can be checked using:

```bash
ip addr show
```

The 5G interface used in the project was:

```text
usb0
```

Connectivity was tested using:

```bash
ping -I usb0 8.8.8.8 -c 4
```

5G connectivity was successfully verified with **0% packet loss**.

## 5G Performance Results

The tested private 5G network provided:

| Metric      |           Result |
| ----------- | ---------------: |
| Network     | 5G NR Standalone |
| Operator    |              FXR |
| Band        |              n77 |
| RSRP        |   -67 to -73 dBm |
| SINR        |         19–33 dB |
| Download    |      182.98 Mbps |
| Upload      |      154.99 Mbps |
| Ping        |         10–12 ms |
| Packet Loss |               0% |

The Raspberry Pi successfully connected to the private 5G network and maintained Internet connectivity through `usb0`.

## Network Traffic Logging

The project uses **TShark** to capture network packets from the 5G interface.

Install TShark:

```bash
sudo apt-get install tshark -y
```

The `network_logger.sh` script:

* Captures packets from `usb0`
* Performs periodic ping tests
* Records interface information
* Records routing information
* Saves timestamped log files
* Creates `.pcap` traffic captures

The captured traffic can be analysed using:

```bash
tshark -r 5g_traffic.pcap
```

The traffic analysis identified ARP, ICMP, ICMPv6, and NTP communication through the 5G connection.

## AT Command Logging

The `at_logger.py` script periodically communicates with the RM520N-GL module and records cellular network information.

It monitors:

* 5G registration
* SIM status
* Signal strength
* RSRP
* SINR
* Serving cell information

Example commands include:

```text
AT+CSQ
AT+C5GREG?
AT+QENG="servingcell"
AT+CPIN?
```

The logger runs every 60 seconds.

## Connection Monitoring

The `connection_monitor.sh` script monitors the 5G connection through `usb0`.

It:

* Pings `8.8.8.8`
* Checks the connection every 10 seconds
* Detects connection failures
* Records the time of connection loss
* Records interface status
* Detects connection recovery
* Counts connection drops

A deliberate connection-loss test was also performed by bringing the interface down and restoring it. The monitoring script detected the connection loss within 10 seconds.

## Automatic Startup

The `start_loggers.sh` script starts the monitoring tools automatically after Raspberry Pi boot.

It starts:

* `at_logger.py`
* `connection_monitor.sh`
* TShark packet capture

The startup script waits for the network to become ready before starting the logging services.

The following cron entry was used:

```text
@reboot bash /home/pi/start_loggers.sh
```

The automatic startup was successfully tested across multiple Raspberry Pi boots.

## Key Results

The project successfully achieved the following:

* Raspberry Pi 5 configured with the RM520N-GL 5G HAT
* Connected to a private 5G NR Standalone network
* 5G connectivity successfully validated
* 0% packet loss during connectivity tests
* 182.98 Mbps download speed
* 154.99 Mbps upload speed
* Network traffic captured and analysed using TShark
* AT command logging implemented
* Connection loss monitoring implemented
* Automatic logging after boot implemented
* 5G connectivity tested independently of Wi-Fi

These results confirmed that the Raspberry Pi 5 setup was ready for private 5G network testing and debugging.

## Important Notes

* The HAT requires an external **5V 3A power supply** for reliable 5G module operation.
* DIP switch **C must be ON** for the RM520N-GL/RM50X series.
* The Nano SIM must be provisioned for the private 5G network.
* `ttyUSB2` was used for Minicom AT-command communication.
* `ttyUSB3` was used by the AT logger.
* Wi-Fi and 5G can operate simultaneously.
* The 5G interface is created as `usb0` when ECM mode is configured.
* SSH was used for headless configuration and testing.

## Author

**Shamila Thennakoon**

Bachelor of Engineering in Information Technology
Smart IoT Embedded Systems
Metropolia University of Applied Sciences
Finland

## Project Report

The complete project documentation is available in:

```text
5G_Project_Report.pdf
```

## Disclaimer

This project was developed and tested in a private laboratory 5G network environment. Network configuration, SIM provisioning, IP addresses, and performance results may differ in other environments.
