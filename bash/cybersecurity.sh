# 1.1 In addition to the system management users, we should assign ordinary users, auditors and security personnel accounts.
users=("普通" "审计员" "安全员")
userList="root"

checkPasswd() {
	strLen=`echo $1 | grep -E --color '^(.{10,}).*$'`
	strSmallLetter=`echo $1 | grep -E --color '^(.*[a-z]+).*$'`
	strCapitalLetter=`echo $1 | grep -E --color '^(.*[A-Z]).*$'`
	strSpecialCharacter=`echo $1 | grep -E --color '^(.*\W).*$'`
	strUnderline=`echo $1 | grep -E --color '^(.*[_]).*$'`
	strNumber=`echo $1 | grep -E --color '^(.*[0-9]).*$'`
	classNum=0
	if [ -n "${strLen}" ]; then
		if [ -n "${strSmallLetter}" ]; then
			let "classNum += 1"
		fi
		if [ -n "${strCapitalLetter}" ]; then
			let "classNum += 1"
		fi
		if [ -n "${strSpecialCharacter}" ] || [ -n "${strUnderline}" ]; then
			let "classNum += 1"
		fi
		if [ -n "${strNumber}" ]; then
			let "classNum += 1"
		fi
		if [ "${classNum}" -ge 3 ]; then
			echo 1
		else
			echo 0
		fi
	else
		echo 0
	fi
}

echo "根据《信息安全技术网络安全等级保护基本要求（GB/T 22239-2019）》加固建议: 用户需要至少创建普通用户、审计员和安全员账户三个用户"
for((i = 0; i < 3; i++))
do
	read -p "请输入要创建的${users[i]}用户：" name
	useradd ${name}
	until [[ $? -eq 0 ]]
	do
		echo "无效的${users[i]}用户名, 无法执行useradd命令"
        	read -p "请重新输入要创建的${users[i]}用户: " name
		useradd ${name}
	done

	status=0
	echo -e "请输入${users[i]}用户的密码:\n    根据《信息安全技术网络安全等级保护基本要求（GB/T 22239-2019）》加固建议：\n\t1.密码长度不小于10位，\n\t2.至少包含三类字符（大写、小写字母、特殊符号、数字至少包含三种）"
	until [ ${status} -eq 1 ]
	do
		read -s passwd
		status=`checkPasswd ${passwd}`
		if [ ${status} -eq 0 ]; then
			echo "您的密码复杂度太低,请重新输入:"
		else
			echo "请再次确认您的密码:"
			read -s re_passwd
			if [ "${passwd}" != "${re_passwd}" ]; then
				echo "您两次输入的密码不一致，请您重新输入:"
				status=0
			fi
		fi
	done

	echo "${name}:${passwd}" | chpasswd
	userList=${userList},${name}
done

# 1.2 Ensure that the home directory permissions of each user are set to 750 or more strictly.
chmod 750 /home/*

# 2. Set PASS_MAX_DAYS and PASS_MIN_DAYS for the root account.
chage --maxdays 90 root
chage --mindays 7 root

# 3. Lock or delete shutdown or halt accounts.
usermod -L shutdown
usermod -L halt

# 4. Ensure that access to the su command is restricted.
echo "根据《信息安全技术网络安全等级保护基本要求（GB/T 22239-2019）》加固建议: 该普通用户、审计员和安全员获得执行su命令的权限"
wheelStr="wheel:x:10"
wheelRowNum=($(cat /etc/group | awk -F ':' '{if($1 == "wheel")print NR}'))

if [ -n "$wheelRowNum" ]; then
   sed -i "${wheelRowNum} c ${wheelStr}:${userList}" /etc/group
fi

# 5. Prohibit direct remote login using root account.
echo "根据《信息安全技术网络安全等级保护基本要求（GB/T 22239-2019）》加固建议: 禁止root用户直接登陆，请使用已创建的普通用户、审计员或者安全员账号登陆"
permitRootLoginRowNum=($(cat /etc/ssh/sshd_config | awk '{if($1 == "PermitRootLogin")print NR}'))
targetString="PermitRootLogin no"
sed -i "${permitRootLoginRowNum} c ${targetString}" /etc/ssh/sshd_config
systemctl restart sshd

echo "镜像加固完毕，欢迎使用 Alibaba Cloud Linux 2"
