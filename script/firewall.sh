#!/bin/bash
# clear iptables rule
iptables -F
iptables -X
iptables -Z

#set policy
iptables -P INPUT DROP
iptables -P OUTPUT ACCEPT 
iptables -P FORWARD ACCEPT

# set other policy
iptables -A INPUT -i lo -j ACCEPT
iptables -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT
# opent to internal 
#iptables -A INPUT -i -s 10.107.17.0/24 -j ACCEPT

# written in policy to firewall
/etc/init.d/iptables save
