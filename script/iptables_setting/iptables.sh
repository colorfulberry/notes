#!/bin/bash
#define related number
EXTIF="eth0"
INIF="eth1"
INNET="192.168.8.0/24"

# to local firewall
# 1.set kernel network
echo "1" > /proc/sts/net/ipv4/tcp_syncookies
echo "1" > /proc/sts/net/ipv4/icmp_echo_ignore_broadcasts
for i in /proc/sys/net/ipv4/conf/*/{rp_filter,log_martians}; do
	echo "1" > $i
done
for i in /proc/sys/net/ipv4/conf/*/{accept_source_route,accept_redirects,send_redirects}; do
	echo "0" > $i
done

# 2.clean iptables default rule 
PATH=/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/sbin:/usr/local/bin; EXPORT PATH

iptables -F
iptbales -X
iptables -Z
iptables -p INPUT DROP
iptables -p OUTPUT ACCEPT
iptables -p FORWARD ACCEPT
iptables -p INPUT -i lo -j ACCEPT
iptables -p INPUT -m state --state RELATED ,ESTABLISHED -j ACCEPT

# 3.start firewall
if [-f /usr/local/virus/iptables/iptables.deny ]; then
	sh /usr/local/virus/iptables/iptables.deny
fi
if [-f /usr/local/virus/iptables/iptables.allow]; then
	sh /usr/local/virus/iptables/iptables.allow
fi
if [-f /usr/local/virus/httpd-err/iptables.http]; then
	sh /usr/local/virus/httpd-err/iptables.http
fi

# 4.allow some type icmp date in
AICMP="0 3 3/4 4 11 12 14 16 18"
for tyicmp in $AICMP
do 
   iptables -A INPUT -i $EXTIF -p icmp --icmp-type $tyicmp -j ACCEPT
done

# 5.allow some service in, it dependenice to your enviroment
iptables -A INPUT -p TCP -i $EXTIF --dport 21 --sport 1024:65534 -j ACCEPT  #ftp
iptables -A INPUT -p TCP -i $EXTIF --dport 22 --sport 1024:65534 -j ACCEPT  #ssh
iptables -A INPUT -p TCP -i $EXTIF --dport 25 --sport 1024:65534 -j ACCEPT  #smpt
iptables -A INPUT -p TCP -i $EXTIF --dport 53 --sport 1024:65534 -j ACCEPT  #dns
iptables -A INPUT -p UDP -i $EXTIF --dport 53 --sport 1024:65534 -j ACCEPT  #dns
iptables -A INPUT -p TCP -i $EXTIF --dport 80 --sport 1024:65534 -j ACCEPT  #www
iptables -A INPUT -p TCP -i $EXTIF --dport 110 --sport 1024:65534 -j ACCEPT  #pop3
iptables -A INPUT -p TCP -i $EXTIF --dport 443 --sport 1024:65534 -j ACCEPT  #https

#part two for behind pc denfie firewall
# 1.load some effective modules
modules="ip_tables iptables_nat ip_nat_ftp ip_nat_irc ip_conntrack ip_conntrack_ftp ip_conntrack_irc"
for mod in $modules
do 
	testmod=`lsmod | grep "^${mod} " | awk 'print $1'`
	if ["$testmod" == ""]; then 
		modprobe $mod
	fi
done

# 2. clean the rule about NAT table
iptables -F -t nat
iptables -X -t nat
iptables -Z -t nat
iptables -t nat -P PREROUTING ACCEPT
iptables -t nat -P POSTROUTING ACCEPT
iptables -t nat -P OUTPUT ACCEPT

# 3.if have two eth then open to routing and be to ip sharing
if ["$INIF" ! = "" ]; then 
	iptables -A INPUT -i $INIF -j ACCEPT 
	echo "1" > /proc/sys/net/ipv4/ip_forward
	if ["$innet" != ""]; then
		for innet in $INNET
		do 
			iptables -t nat -A POSTROUTING -s $innet -o $EXTIF -j MASQUERADE
		done
	fi
fi

#if your MSN cannot connect or some website can conect the others cannot
# it may be MTU lead to , you can cancel follow note to start MTU limit range
# iptbales -A FORWARD -p tcp -m tcp --tcp-flags SYN,RST -m tcpmss --mss 1400:1536 -j TCPMSS --clamp-mss-to-pmtu

# 4.set NAT port to inside to out  LAN 
#iptables -t nat -A PREROUTING -p tcp -i $EXTIF --dport 80 -j DNAT --to-destination 192.168.80.101:80

# 5. some other rule like windwos remote desktop example desktop pc 1,2,3,4
# iptbales -t nat -A PREROUTING -p tcp -s 1.2.3.4 --dport 6000 -j DNAT --to-destionation 192.168.83.102
# iptbales -t nat -A PREROUTING -p tcp -s 1.2.3.4 --sport 3389 -j DNAT --to-destionation 192.168.83.103

# 6. save those rule 
/etc/init.d/iptables save
