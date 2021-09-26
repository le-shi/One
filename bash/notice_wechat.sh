#!/bin/bash
#企业ID，登录后台--> 我的企业-->底部企业ID
CropID='ccf12d32a1293984e1'
#应用秘钥，应用管理，往下拉看到“自建”后，点击作为报警的应用，下方可以看到Secret的值
Secret='iMBfiIdmaOcEzU1eIVeiaT-onnIbeyieRGXi_Ocp3FHw'
#拼接获取token的连接
GURL="https://qyapi.weixin.qq.com/cgi-bin/gettoken?corpid=$CropID&corpsecret=$Secret"
#获取token值
Gtoken=$(curl -s -G $GURL | awk -F '"' '{print $10}')
#推送消息的连接
PURL="https://qyapi.weixin.qq.com/cgi-bin/message/send?access_token=$Gtoken"
#定义函数发送消息
function body() {
    # 自建应用的AgentId
    local int AppID=1000025
    # 接收告警消息的人员Id(成员详情里的"账号", 特殊变量 @all 代表"可见范围"的所有人), 需要在自建应用的"可见范围"设置需要接受告警消息的人
    local UserID=@all
    # 接收告警消息的部门Id(在"组织架构", 选中部门名称后，点击名称右侧的三个点, 在弹出的二级菜单显示 "部门ID: 1"), 需要在自建应用的"可见范围"设置需要接受告警消息的部门
    local PartyID=24
    # 要发送的消息内容
    local Msg=${@}
    
    # 定义要发送的body
    echo -e '{
        "touser": "'${UserID}'",
        "toparty": "'${PartyID}'",
        "totag": "TagID1 | TagID2",
        "msgtype": "text",
        "agentid": '${AppID}',
        "text": {
                "content": "'${Msg}'"
        },
        "safe": 0,
        "enable_id_trans": 0,
        "enable_duplicate_check": 0
    }'
}

#推送消息,--data的方式post数据，双引号里是参数
curl -s --data "$(body ${@})" $PURL 2>&1 >/dev/null
 
 