#!/bin/bash
set -x

# 获取当前构建日志
a=`curl ${BUILD_URL}/consoleText`

# 截取上游job的名字和构建号，组装url
a_log=`echo "$a" | head -n 1`
a_log_name=`echo $a_log | awk -F '"' '{print $2}'`
a_log_id=`echo $a_log | awk -F 'build number ' '{print $2}'`
a_log_url=${JENKINS_URL}/job/${a_log_name}/${a_log_id}/api/json?pretty=true

# 获取上游job构建的信息：
# SCM触发: 提交人，提交号，变动的文件
# 手动触发

b=`curl ${a_log_url}`
# echo

# echo $b
# echo
# echo $b | jq .

# 通过不同触发类型，决定推送消息格式
b_change_type=`echo $b | jq ".actions[].causes[].shortDescription"` 2>/dev/null
if [[ ${b_change_type} == '"Started by an SCM change"' ]]
then
    b_change_action="SCM变更触发"
else
    b_change_action="手动触发"
fi

# 提交人 - 提交号 - 变动类型 - 变动的文件
b_change_preare=`echo $b | jq "._class" | sed 's/"//g'`
if [[ $(echo ${b_change_preare} | grep -c "org.jenkinsci.plugins.workflow.job.WorkflowRun") == 1 ]]
then
    # pipeline
    b_change_preare_set=changeSets[]
else
    # other
    b_change_preare_set=changeSet
fi

b_change_user=`echo $b | jq ".${b_change_preare_set}.items[].user" | sed 's/^"//g' | sed 's/"//g' | tr '\n' ',' | sed 's/,$//g'`
if [[ -n ${b_change_user} ]]
then
    b_change_revision=`echo $b | jq ".${b_change_preare_set}.items[].revision" | sed 's/^"//g' | sed 's/"//g' | tr '\n' ',' | sed 's/,$//g'`
    b_change_paths_edittype=`echo $b | jq ".${b_change_preare_set}.items[].paths[].editType" | sed 's/^"//g' | sed 's/"//g' | tr '\n' ',' | sed 's/,$//g'`
    b_change_paths_file=`echo $b | jq ".${b_change_preare_set}.items[].paths[].file" | sed 's/^"//g' | sed 's/"//g' | tr '\n' ',' | sed 's/,$//g'`
    b_change_name="""
提交人: ${b_change_user}
SVN版本: ${b_change_revision}
修改类型: ${b_change_paths_edittype}
文件: ${b_change_paths_file}"""
else
    b_change_name=""
fi

# 构建状态
b_change_status=`echo $b | jq ".result" | sed 's/"//g'`

suc_emoji=("[呲牙]" "[嘿哈]" "[大笑]" "[得意]" "[哇]" "[酷]" "[耶]" "[强]" "[庆祝]" "[烟花]" "[加油]" "[666]" "[胜利]" "[啤酒]" "[跳跳]")
suc_num=$((RANDOM%${#suc_emoji}+1))

fai_emoji=("[微笑]" "[失望]" "[衰]" "[囧]" "[疑问]" "[恐惧]" "[捂脸]" "[抠鼻]" "[炸弹]" "[天啊]" "[饥饿]" "[疯了]" "[糗大了]" "[吓]" "[咖啡]")
fai_num=$((RANDOM%${#fai_emoji}+1))


if [[ ${b_change_status} == "SUCCESS" ]]
then
    b_change_status="成功 ${suc_emoji[$suc_num]}"
else
    b_change_status="失败 ${fai_emoji[$fai_num]}"
fi

# 发送消息模板
# job名称 - 构建状态 - ${b_change_name}

python /home/infra/wx_msg.py """任务: ${a_log_name} - ${a_log_id}
结果: ${b_change_status}
详情: ${b_change_action} ${b_change_name}"""

