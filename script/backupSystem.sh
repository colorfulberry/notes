#!/bin/bash
backdir="/etc /home /root /var/spool/mail"
basedir=/backup
[! -d "$basedir"] && mkdir $backdir
backfile=$basedir/backup.tar.gz
tar -zcvf $backfile $backdir
