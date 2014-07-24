#!/bin/sh
groupadd vbirdgroup
for username in  vbirduser1 vbirduser3 vbirduser2 vbirduser5 vbirduser4
do
    useradd -G vbirdgroup $username
    echo "passwd" | passwd  --stdin $username
 done
 #you can check through id vbirduser1
