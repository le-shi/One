#!/usr/bin/python
#coding=utf8
import json, sys
import pylibmc as memcache
import requests
mycontents = " ".join(sys.argv[1:])#用空格作为分隔符，将传进来的参数进行分隔
mc = memcache.Client(["127.0.0.1"], binary=True,
        behaviors={"tcp_nodelay": True,
        "ketama": True})  #以memcache客户端的身份连接到memcache服务器
mytoken = mc.get("token")  # 通过pylibmc模块的get来获取token值

CropID='ccf12d32a1293984e1'
Secret='iMBfiIdmaOcEzU1eIVeiaT-onnIbeyieRGXi_Ocp3FHw'
apiUrl = 'https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=' + CropID + '&corpsecret=' + Secret'#去企业微信接口获取token的值
if mytoken == None:#如果刚才在memcache中获得的token值是空
      mytoken = requests.get(apiUrl, verify=False).json()['access_token']#就把在企业微信接口获得的token值给赋值到mytoken变量中
      mc.set("token", mytoken, time=7200)#然后写入到memcache数据库中。

apiUrl = 'https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=' + mytoken  #调用企业微信的发送消息接口
mydata = {
    'touser': '@all',
    'msgtype': 'text',
    'agentid': '1000025',
    'text': {
        'content': mycontents
    },
    'safe': 0
}  #要提交给企业微信的数据
r = requests.post(apiUrl, json=mydata, verify=False).json()   #向微信企业发送发消息的请求，verify=False是验证ssl证书，默认为true，跳过验证证书直接改值为false，.json是返回json格式
print 'Sent ' + r['errmsg'] #  打印出返回值的信息，是否发送成功。
mytoken = mc.delete('token')

####zabbix-server需要安装并启动memcache服务和python的pylibmc,requests模块，然后脚本放到指定目录下，前端页面设置成脚本报警
