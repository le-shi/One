#!/bin/bash

# 定时打开和关闭前台网站的互动效果

case $1 in
    hd)
        # 早上8:00 互动
        cp -r /tmp/hd/* /tmp/aaa
    ;;
    nohd)
        # 晚上5:30 不互动
        cp -r /tmp/nohd/* /tmp/aaa
    ;;
    *) echo "[hd|nohd]"
    ;;
esac

# crontab -l
# 30 17 * * * /home/cron_www.sh nohd
# 00 8 * * * /home/cron_www.sh hd