#!/bin/sh
netstat -an| grep SYN_RECV | awk '{print$5}'|awk -F: '{print$1}'|sort|uniq| -c|sort -rn| awk
'{if ($1>5) print$2}'>/tmp/dropip
for i in $(cat /tmp/dropip)
	do
		/abin/iptables -I INPUT -s $i -j DROP
		echo "$i kill at 'date'">>/var/log/ddos
	done
done
