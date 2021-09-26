#!/bin/bash
# dependency on notice_wechat.sh
#
# 可以将此文件放到 /etc/profile.d/ 目录下面，有人登录系统会自动执行
#

[[ -z ${SSH_CONNECTION} ]] && break
SSH_CONN_CLI=$(echo ${SSH_CONNECTION} | awk '{print $1}')
SSH_CONN_SER=$(echo ${SSH_CONNECTION} | awk '{print $3}')
SSH_NOTICE_CMD=/opt/notice_wechat.sh

chmod +x ${SSH_NOTICE_CMD}
${SSH_NOTICE_CMD} "== SSH登录通知 ==
\n
\n服务器IP: ${SSH_CONN_SER}
\n登录用户: ${USER}
\n登录IP: ${SSH_CONN_CLI}
\n登录时间: $(date +%FT%T)
"
