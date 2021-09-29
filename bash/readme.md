# 记

+ 分组一

```bash
$0 shell本身的文件名
$n 命令行参数的第n个参数值
$* 命令行参数的位置, "$*"使用时作为一个字符串, $*使用时作为各个独立的参数, 这里的*表示第*个参数
$@ 命令行参数的位置, "$@"和$@等价,没有区别
$# 命令行参数的个数
$? 上一条命令的返回值(0表示正确,其他任何值表示有错误)
$$ 当前shell的PID(脚本运行的PID)
$! 最后运行的后台进程的PID
$- 查看Set命令设定的Flag(set -ex)
$_ 传递参数和全路径
```

+ 分组二

```bash
!! 上条命令
!$ 上条命令的最后一个参数
```

+ 分组三

```bash
`` 命令替换
$() 等同``
$ 变量替换
${} 等同$, 可以精确的界定变量名称的范围

先赋值一个变量为一个路径，如下：
file=/dir1/dir2/dir3/my.file.txt

命令    解释    结果
${file#*/}    拿掉第一条 / 及其左边的字符串    dir1/dir2/dir3/my.file.txt
[root@localhost ~]# echo ${file#*/}
dir1/dir2/dir3/my.file.txt

${file##*/}    拿掉最后一条 / 及其左边的字符串    my.file.txt
[root@localhost ~]# echo ${file##*/}
my.file.txt

${file#*.}    拿掉第一个 . 及其左边的字符串    file.txt
[root@localhost ~]# echo ${file#*.}
file.txt

${file##*.}    拿掉最后一个 . 及其左边的字符串    txt
[root@localhost ~]# echo ${file##*.}
txt

${file%/*}    拿掉最后一条 / 及其右边的字符串    /dir1/dir2/dir3
[root@localhost ~]# echo ${file%/*}
/dir1/dir2/dir3

${file%%/*}    拿掉第一条 / 及其右边的字符串    (空值)
[root@localhost ~]# echo ${file%%/*}
(空值)

${file%.*}    拿掉最后一个 . 及其右边的字符串    /dir1/dir2/dir3/my.file
[root@localhost ~]# echo ${file%.*}
/dir1/dir2/dir3/my.file

${file%%.*}    拿掉第一个 . 及其右边的字符串    /dir1/dir2/dir3/my￼
[root@localhost ~]# echo ${file%%.*}
/dir1/dir2/dir3/my
记忆方法如下：
# 是去掉左边(在键盘上 # 在 $ 之左边)
% 是去掉右边(在键盘上 % 在 $ 之右边)
单一符号是最小匹配;两个符号是最大匹配
*是用来匹配不要的字符，也就是想要去掉的那部分
还有指定字符分隔号，与*配合，决定取哪部分

${var:0:3} 提取最左边的 3 个字节 
${var:3:3} 提取第 3 个字节右边的连续 3 个字节
${var/foo/bar} 将第一个 foo 替换为 bar
${var//foo/bar} 将全部 foo 替换为 bar
${#var} 获取变量长度
${var-foo} 如果 $var 没设定, 则使用 foo 作传回值, 空值及非空值不作处理
${var:-foo} 如果 $var 没设定或为空值, 则使用 foo 作传回值, 非空值不作处理
${var+foo} 如果 $var 设为空值或非空值, 则使用 foo 作传回值, 没设定时不作处理
${var:+foo} 如果 $var 非空值, 则使用 foo 作传回值, 没设定及空值不作处理
${var=foo} 如果 $var 没设定, 则回传 foo ,并将 $var 赋值为 foo, 空值及非空值不作处理
${var:=foo} 如果 $var 没设定或为空值, 则回传 foo ,并将 $var 赋值为 foo, 空值及非空值不作处理
${var?foo} 如果 $var 没设定, 则将 foo 输出至STDERR, 空值及非空值不作处理
${var:?foo} 如果 $var 没设定或为空值, 则将 foo 输出至STDERR, 非空值时不作处理
# 一定要分清楚 unset 与 null 及 non-null 这三种赋值状态. 一般而言, : 与 null 有关, 若不带 : 的话, null 不受影响, 若带 : 则连 null 也受影响
```

+ 分组四

```bash
text="a b c def"   # 定义字符串
text=(a b c def)   # 定义字符数组

${text[@]} 返回数组全部元素
${text[*]} 返回数组全部元素
${text[0]} 返回数组第一个元素
${#text[@]} 返回数组元素总数
${#text[*]} 返回数组元素总数
${#text[1]} 返回数组第2个元素的长度 下标从0开始
text[2]=B 将数组第3个元素重新定义
```

+ 分组五

```bash
() 命令组, 命令替换, 初始化数组
(()) 整数扩展, 运算符(符合C语言运算规则), 重定义变量值, 算术运算比较
[] bash内部命令, 比较运算符, 字符范围, 显示数组元素的编号
[[]] bash关键字, 字符串模式匹配, 条件判断结构, 表达式看作单独元素并返回退出状态码
{} 大括号拓展, 代码块, 替换结构
```

+ 分组六

```bash
install_docker.sh: docker的二进制安装，开机启动
install_docker-compose.sh: docker-compose的二进制安装
system_optimize.sh: 系统参数优化
```

+ 分组七

```bash
# Linux中缺省的变量
$PATH 环境变量路径
$TMOUT ssh闲置超时时间
$RANDOM 产生随机数
$OLDPWD 记录着cd前的目录，新打开的shell此变量为空，执行 cd /path/to 命令后，执行命令的目录成为OLDPWD变量的值，命令 cd - 返回的目录是根据这个变量的值决定的
$BASH 当前 shell 的可执行路径，适用于 bash
$ZSH 当前 shell 的可执行路径，适用于 zsh
$SHELL 当前连接的 shell 类型
$SHELLOPTS 当前连接的 shell 参数
$HOME 当前用户的家目录，执行 cd 命令后，这里不需要参数，切换到的目录是家目录，也就是变量 HOME 的值
$HISTCMD 下一个history记录的序号
$HISTFILE history用来记录已执行命令的文件，变量置空时可以擦除history记录(抹除痕迹时很有用)
$HOSTNAME 主机名
$HOSTTYPE 机器的架构和位数
$LANG 终端字符集
$LOGNAME 当前登录的用户名
$MAIL 本地mail存储的路径
$OSTYPE 系统的类型
$PPID 当前登录shell的PID
$SSH_TTY 当前ssh连接所属的终端，服务器本地终端时，此变量为空
$SSH_CLIENT ssh客户端的IP、端口和ssh服务端的端口，服务器本地终端时，此变量为空
$SSH_CONNECTION ssh客户端的IP、端口和ssh服务端本地的IP、端口，服务器本地终端时，此变量为空
```

+ 分组八

```bash
>&n 使用系统调用 dup (2) 复制文件描述符 n 并把结果用作标准输出；
<&n 标准输入复制自文件描述符 n；
<&- 关闭标准输入（键盘）；
>&- 关闭标准输出；
n<&- 表示将 n 号输入关闭；
n>&- 表示将 n 号输出关闭；

exec 1>outfilename 打开文件outfilename作为 stdout。
exec 2>errfilename 打开文件errfilename作为 stderr。
exec 0<&- 关闭 标准输入。
exec 1>&- 关闭 标准输出。
exec 2>&- 关闭 标准错误输出。

标准输入重定向（STDIN，文件描述符为0）：默认从键盘输入，也可从其他文件或命令中输入。
标准输出重定向（STDOUT，文件描述符为1）：默认输出到屏幕。
标准错误输出重定向（STDERR，文件描述符为2）：默认输出到屏幕。
```
