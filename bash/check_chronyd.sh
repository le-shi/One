#!/bin/bash
if [[ 1 == $(systemctl status chronyd | tail -n 1 | grep "Source 192.168.10.2 offline" -c) ]]
then
    systemctl restart chronyd
    echo "help sb. up [chronyd]"
fi
