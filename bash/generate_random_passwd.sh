#!/bin/bash


# 初始化索引值
i=1
# 自定义密码长度，可以传参第一个参数是长度，默认12位
length=${1:-12}
# 随机选择列表
seq=(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z @ % - = _ + , . ! ^ \& \[ \] \' \~ \( \) \< \>)
# 计算列表长度
num_seq=${#seq[@]}

if (( $length < 2 || true ))
then
  echo "请输入大于1的数字"
  exit 1
fi

# 随机生成密码，长度是 $length
function gen_pass(){
  while [ "$i" -le "$length" ]
  do
    seqrand[$i]=${seq[$((RANDOM%num_seq))]}
    let "i=i+1"
  done

  echo ${seqrand[@]} | sed 's/ //g'
}

# 运行方法
gen_pass
