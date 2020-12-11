#!/usr/bin/python2
#Usage: discover micro services
#Last Modified:

import subprocess
import json
import sys

def list():
  args="curl http://127.0.0.1:8761/eureka/apps/  -H 'Accept:application/json' 2>/dev/null | jq .applications.application[].name | sed 's/\"//g'"
  t=subprocess.Popen(args,shell=True,stdout=subprocess.PIPE).communicate()[0]
  apps=[]
  for app in t.split('\n'):
      if len(app) != 0:
          apps.append({'{#APP_NAME}':app})
  print json.dumps({'data':apps},indent=4,separators=(',',':'))

def check():
  checkurl="curl http://127.0.0.1:8761/eureka/apps/{0} -H 'Accept:application/json' 2> /dev/null | jq .application.instance[].status".format(ms_name)
  t=subprocess.Popen(checkurl,shell=True,stdout=subprocess.PIPE).communicate()[0]
  print t,

if len(sys.argv[1:]) == 0:
  list()
else:
  ms_name=sys.argv[1]
  ms_name=ms_name.lower()
  check()
