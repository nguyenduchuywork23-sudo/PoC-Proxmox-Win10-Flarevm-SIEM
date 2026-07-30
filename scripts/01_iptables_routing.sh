#!/bin/bash
# ==============================================================================
# Script: Air-Gapped Network Isolation & Deception Routing
# Author: Nguyen Duc Huy (Cybersecurity Intern / Aspiring SOC Analyst)
# Environment: Ubuntu 24.04 LTS Gateway (Proxmox VE)
# Interfaces: ens18 (WAN: 192.168.1.221), ens19 (LAN: 10.0.0.1)
# ==============================================================================

echo 1 > /proc/sys/net/ipv4/ip_forward

# 1. KILL-SWITCH (Co lap hoan toan ma doc)
iptables -P FORWARD DROP
iptables -F && iptables -t nat -F

# 2. NETWORK DECEPTION (Be lai traffic ma doc vao INetSim)
iptables -t nat -A PREROUTING -i ens19 -p udp --dport 53 -j REDIRECT --to-port 53
iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 53 -j REDIRECT --to-port 53
iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 80 -j REDIRECT --to-port 80
iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 443 -j REDIRECT --to-port 443
iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 21 -j REDIRECT --to-port 21
iptables -t nat -A PREROUTING -i ens19 -p tcp --dport 25 -j REDIRECT --to-port 25

# 3. LOG PIPELINE (Chi cho phep Wazuh Agent 1514/1515 lien lac ve Server)
iptables -A FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
iptables -A FORWARD -i ens19 -o ens18 -p tcp -d 192.168.1.244 --dport 1514 -j ACCEPT
iptables -A FORWARD -i ens19 -o ens18 -p udp -d 192.168.1.244 --dport 1514 -j ACCEPT
iptables -A FORWARD -i ens19 -o ens18 -p tcp -d 192.168.1.244 --dport 1515 -j ACCEPT

netfilter-persistent save
