#!/bin/bash
localdir=/backups
remotedir="/etc /root /home"
remoteip="10.107.17.203"
[-d ${localdir}] || mkdir ${localdir}
for dir in ${remotedir}
do 
	rsync -av -e ssh root@${remoteip}:${dir} ${localdir}
done
