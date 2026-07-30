#!/bin/bash
# ==============================================================================
# Script: Automated PCAP Capture for Deep Packet Inspection
# Target Interface: ens19 (Malware LAN - 10.0.0.1)
# ==============================================================================
CAPTURE_DIR="/home/rootadmin/pcaps"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
mkdir -p $CAPTURE_DIR

sudo tcpdump -i ens19 -nn -s0 -w "$CAPTURE_DIR/traffic_$TIMESTAMP.pcap"
