#!/bin/bash

# */10 * * * * cron_restart_dm.sh

DM_PID=$(ps -ef | grep './dmserver /home/dmdba/dmdb/dmdb/dm.ini -noconsole' | grep -v grep | grep -v '.sh' | awk '{print $2}')

DM_PROC_COUNT=$(ls -1 /proc/${DM_PID}/fd | wc -l)

echo "[INFO-1] $0 running $(date +%FT%T.%N)"

echo "DM open fd ${DM_PROC_COUNT}, max 65535"
if (( $DM_PROC_COUNT > 60000 ))
then
  /home/dmdba/stop_dm.sh
  su - dmdba -c "/home/dmdba/run_dm.sh"
  > /home/dmdba/dmdbms/bin/nohup.out
  echo "[INFO-2] $0 running restart $(date +%FT%T.%N)"
fi

echo

echo """
# run_dm.sh
cd /home/dmdba/dmdbms/bin
nohup ./dmserver /home/dmdba/dmdb/dmdb/dm.ini -noconsole &

# stop_dm.sh
ps -ef | grep dmdba | grep -v grep |grep -v '.sh' | awk '{print $2}' | xargs kill -9

"""