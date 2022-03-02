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
~ 表示家目录，它不是一个变量，一般是直接使用: cd ~; echo ~
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

+ 分组九

```bash
# shell脚本中的set指令
set -xue
set -o pipefail

-a 标示已修改的变量，以供输出至环境变量。
-b 使被中止的后台程序立刻回报执行状态。
-C 转向所产生的文件无法覆盖已存在的文件。
-d Shell预设会用杂凑表记忆使用过的指令，以加速指令的执行。使用-d参数可取消。
-e 若指令传回值不等于0，则立即退出shell。
-f 取消使用通配符。
-h 自动记录函数的所在位置。
-H Shell 可利用"!"加<指令编号>的方式来执行history中记录的指令。
-k 指令所给的参数都会被视为此指令的环境变量。
-l 记录for循环的变量名称。
-m 使用监视模式。
-n 只读取指令，而不实际执行。
-p 启动优先顺序模式。
-P 启动-P参数后，执行指令时，会以实际的文件或目录来取代符号连接。
-t 执行完随后的指令，即退出shell。
-u 当执行时使用到未定义过的变量，则显示错误信息。
-v 显示shell所读取的输入值。
-x 执行指令后，会先显示该指令及所下的参数。
+<参数> 取消某个set曾启动的参数。和 -<参数> 作用相反
-o option 特殊属性有很多，大部分与上面的可选参数功能相同

# 其他用法 - 初始化位置参数，脚本中加入以下内容，在执行脚本时并没有输入参数，但是使用 set 指令后会对位置参数进行赋值。
# 用于命令行 | 脚本中
set one two three
echo $3 $2 $1
# 其他用法 - 显示shell变量，如果不带任何参数的使用 set 命令，set 指令就会显示一列已设置的 shell 变量，包括用户定义的变量和关键字变量。
# 用于命令行 | 脚本中
set
```

+ 分组十

```bash
# 循环/遍历
## while 循环是 Shell 脚本中最简单的一种循环，当条件满足时，while 重复地执行一组语句，当条件不满足时，就退出 while 循环
while condition; do statements; done
## unti 循环和 while 循环恰好相反，当判断条件不成立时才进行循环，一旦判断条件成立，就终止循环
until condition; do statements; done
## 除了 while 循环和 until 循环，Shell 脚本还提供了 for 循环，它更加灵活易用，更加简洁明了
## - Python语言风格
for variable in value_list; do statements; done
## - C语言风格
for ((exp1; exp2; exp3)); do statements; done
## select in 循环用来增强交互性，它可以显示出带编号的菜单，用户输入不同的编号就可以选择不同的菜单，并执行不同的功能.select in 是 Shell 独有的一种循环，非常适合终端（Terminal）这样的交互场景，C语言、C++、Java、Python、C# 等其它编程语言中是没有的
select variable in value_list; do statements; done
# 判断
if [[ condition ]]; then statements; else statements; fi
if [[ condition ]]; then statements; fi
case expression in; pattern1) statement1;; pattern2) statement2 ;; pattern3) statement3  ;; *)  statementn;; esac
```

+ 分组X

```bash
# Something...
```