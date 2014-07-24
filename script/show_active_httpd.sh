#!/bin/sh
#查看有多少活动的httpd
while(true)
do pstree |grep "*\[httpd\]$"|sed 's/.*-\([0-9]*\)\*\[httpd\]$/\1/'
sleep 3
done
