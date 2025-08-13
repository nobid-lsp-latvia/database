#!/bin/env sh

if [ "$(grep -c 'error' /tmp/output.txt)" -ge 1 ]
then echo "FAILED!!!"
     cat /tmp/output.txt
     exit 1
else
   cat /tmp/output.txt
   exit 0
fi
