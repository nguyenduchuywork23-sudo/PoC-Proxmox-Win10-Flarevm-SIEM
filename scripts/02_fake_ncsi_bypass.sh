#!/bin/bash
# ==============================================================================
# Script: Windows NCSI Fake Response Generator
# Purpose: Bypass Malware Sleep/Evasion mechanisms by simulating active Internet.
# ==============================================================================
WEB_ROOT="/var/lib/inetsim/http/default"
sudo mkdir -p $WEB_ROOT

# Fake Windows 10/11 Network Response (22 bytes)
sudo bash -c 'echo -n "Microsoft Connect Test" > /var/lib/inetsim/http/default/connecttest.txt'

# Fake Windows 7/8 Network Response (14 bytes)
sudo bash -c 'echo -n "Microsoft NCSI" > /var/lib/inetsim/http/default/ncsi.txt'

sudo chmod 644 $WEB_ROOT/connecttest.txt
sudo chmod 644 $WEB_ROOT/ncsi.txt
