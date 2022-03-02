#!/bin/bash
#this script is used to get tcp and udp connetion status
#tcp status
metric=$1
tmp_file=/tmp/tcp_status.txt
touch ${tmp_file}
chmod 666 ${tmp_file}
/usr/sbin/ss -ant | sed 1d | awk '{++S[$1]}END{for(a in S) print a,S[a]}' > $tmp_file

case $metric in
   CLOSED)
          output=$(awk '/CLOSED/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   LISTEN)
          output=$(awk '/LISTEN/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   SYN-RECV)
          output=$(awk '/SYN-RECV/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   SYN-SENT)
          output=$(awk '/SYN-SENT/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   ESTAB)
          output=$(awk '/ESTAB/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   TIME-WAIT)
          output=$(awk '/TIME-WAIT/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   CLOSING)
          output=$(awk '/CLOSING/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   CLOSE-WAIT)
          output=$(awk '/CLOSE-WAIT/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
        ;;
   LAST-ACK)
          output=$(awk '/LAST-ACK/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
         ;;
   FIN-WAIT-1)
          output=$(awk '/FIN-WAIT-1/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
         ;;
   FIN-WAIT-2)
          output=$(awk '/FIN-WAIT-2/{print $2}' $tmp_file)
          if [ "$output" == "" ];then
             echo 0
          else
             echo $output
          fi
         ;;
         *)
          echo -e "\e[033mUsage: sh  $0 [CLOSED|CLOSING|CLOSEWAIT|SYNRECV|SYNSENT|FINWAIT1|FINWAIT2|LISTEN|ESTABLISHED|LASTACK|TIMEWAIT]\e[0m"
   
esac
