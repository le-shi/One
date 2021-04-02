#!/bin/bash

Get_System_Name (){
    system_version_num=$(awk -F 'VERSION_ID=' '/VERSION_ID=/ {print $2}' /etc/os-release | sed 's/"//g')
    if grep -Eqii "CentOS" /etc/issue || grep -Eq "CentOS" /etc/*-release 2>/dev/null; then
        system_version='CentOS'
        PM='yum'
    elif grep -Eqi "Red Hat Enterprise Linux Server" /etc/issue || grep -Eq "Red Hat Enterprise Linux Server" /etc/*-release 2>/dev/null; then
        system_version='RHEL'
        PM='yum'
    elif grep -Eqi "Aliyun" /etc/issue || grep -Eq "Aliyun" /etc/*-release 2>/dev/null; then
        system_version='Aliyun'
        PM='yum'
    elif grep -Eqi "Fedora" /etc/issue || grep -Eq "Fedora" /etc/*-release 2>/dev/null; then
        system_version='Fedora'
        PM='yum'
    elif grep -Eqi "Debian" /etc/issue || grep -Eq "Debian" /etc/*-release 2>/dev/null; then
        system_version='Debian'
        PM='apt'
    elif grep -Eqi "Ubuntu" /etc/issue || grep -Eq "Ubuntu" /etc/*-release 2>/dev/null; then
        system_version='Ubuntu'
        PM='apt'
    elif grep -Eqi "Raspbian" /etc/issue || grep -Eq "Raspbian" /etc/*-release 2>/dev/null; then
        system_version='Raspbian'
        PM='apt'
    elif grep -Eqi "Mint" /etc/issue || grep -Eq "Mint" /etc/*-release 2>/dev/null; then
        system_version='Mint'
        PM='apt'
    elif grep -Eqi "Kylin" /etc/issue || grep -Eq "Kylin" /etc/*-release 2>/dev/null; then
        system_version='Kylin'
        PM='apt'
    else
        system_version='unknow'
        system_version_num='unknow'
    fi
}
Get_System_Name
echo -e "System Version: ${system_version} ${system_version_num}"


