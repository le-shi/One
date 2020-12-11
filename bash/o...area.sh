#!/bin/bash

file=sum

line=$(head -n 1 ${file})

code=$(echo $line | awk -F ',' '{print $1}')
name=$(echo $line | awk -F ',' '{print $2}')
level=$(echo $line | awk -F ',' '{print $3}')
pcode=$(echo $line | awk -F ',' '{print $4}')

if [[ ${level} == 1 ]]
then
    son1=(`grep ",${code}" "${file}"`)
    echo -n "insert into dict_data_item (ITEM_ID,CATE_ENAME,ITEM_VALUE,ITEM_TEXT,ITEM_REMARK,ITEM_STATUS,ORDER_NUM,CREATE_USER,CREATE_TIME,UPDATE_USER,UPDATE_TIME,UPDATE_COUNT,DEL_STATUS,SUB_COUNT,TREE_LEVEL,FATHER_ID,FATHER_VALUE,FULL_ENAME,FULL_CNAME,ORG_ID,DEPT_ID,SYS_NAME) values("
    echo -n "$code,'areaAll',$code,'$name','',1,'','',1583676309804,'','','','',${#son1[@]},'',$pcode,$pcode,'/$code','/$name','','',''"
    echo ");"
    for i in ${son1[@]}
    do
        code1=$(echo $i | awk -F ',' '{print $1}')
        name1=$(echo $i | awk -F ',' '{print $2}')
        level1=$(echo $i | awk -F ',' '{print $3}')
        pcode1=$(echo $i | awk -F ',' '{print $4}')
            if [[ ${level1} == 2 ]]
            then
                son2=(`grep ",${code1}" "${file}"`)
                echo -n "insert into dict_data_item (ITEM_ID,CATE_ENAME,ITEM_VALUE,ITEM_TEXT,ITEM_REMARK,ITEM_STATUS,ORDER_NUM,CREATE_USER,CREATE_TIME,UPDATE_USER,UPDATE_TIME,UPDATE_COUNT,DEL_STATUS,SUB_COUNT,TREE_LEVEL,FATHER_ID,FATHER_VALUE,FULL_ENAME,FULL_CNAME,ORG_ID,DEPT_ID,SYS_NAME) values("
                echo -n "$code1,'areaAll',$code1,'$name1','',1,'','',1583676309804,'','','','',${#son2[@]},'',$pcode1,$pcode1,'/$code/$code1','/$name/$name1','','',''"
                echo ");"
                for i in ${son2[@]}
                do
                    code2=$(echo $i | awk -F ',' '{print $1}')
                    name2=$(echo $i | awk -F ',' '{print $2}')
                    level2=$(echo $i | awk -F ',' '{print $3}')
                    pcode2=$(echo $i | awk -F ',' '{print $4}')
                    if [[ ${level2} == 3 ]]
                    then
                        son3=(`grep ",${code2}" "${file}"`)
                        echo -n "insert into dict_data_item (ITEM_ID,CATE_ENAME,ITEM_VALUE,ITEM_TEXT,ITEM_REMARK,ITEM_STATUS,ORDER_NUM,CREATE_USER,CREATE_TIME,UPDATE_USER,UPDATE_TIME,UPDATE_COUNT,DEL_STATUS,SUB_COUNT,TREE_LEVEL,FATHER_ID,FATHER_VALUE,FULL_ENAME,FULL_CNAME,ORG_ID,DEPT_ID,SYS_NAME) values("
                        echo -n "$code2,'areaAll',$code2,'$name2','',1,'','',1583676309804,'','','','',${#son3[@]},'',$pcode2,$pcode2,'/$code/$code1/$code2','/$name/$name1/$name2','','',''"
                        echo ");"
                        for i in ${son3[@]}
                        do
                            code3=$(echo $i | awk -F ',' '{print $1}')
                            name3=$(echo $i | awk -F ',' '{print $2}')
                            level3=$(echo $i | awk -F ',' '{print $3}')
                            pcode3=$(echo $i | awk -F ',' '{print $4}')
                            if [[ ${level3} == 4 ]]
                            then
                                son4=(`grep ",${code3}" "${file}"`)
                                echo -n "insert into dict_data_item (ITEM_ID,CATE_ENAME,ITEM_VALUE,ITEM_TEXT,ITEM_REMARK,ITEM_STATUS,ORDER_NUM,CREATE_USER,CREATE_TIME,UPDATE_USER,UPDATE_TIME,UPDATE_COUNT,DEL_STATUS,SUB_COUNT,TREE_LEVEL,FATHER_ID,FATHER_VALUE,FULL_ENAME,FULL_CNAME,ORG_ID,DEPT_ID,SYS_NAME) values("
                                echo -n "$code3,'areaAll',$code3,'$name3','',1,'','',1583676309804,'','','','',${#son4[@]},'',$pcode3,$pcode3,'/$code/$code1/$code2/$code3','/$name/$name1/$name2/$name3','','',''"
                                echo ");"
                                for i in ${son4[@]}
                                do
                                    code4=$(echo $i | awk -F ',' '{print $1}')
                                    name4=$(echo $i | awk -F ',' '{print $2}')
                                    level4=$(echo $i | awk -F ',' '{print $3}')
                                    pcode4=$(echo $i | awk -F ',' '{print $4}')
                                    if [[ ${level4} == 5 ]]
                                    then
                                        son5=(`grep ",${code4}" "${file}"`)
                                        echo -n "insert into dict_data_item (ITEM_ID,CATE_ENAME,ITEM_VALUE,ITEM_TEXT,ITEM_REMARK,ITEM_STATUS,ORDER_NUM,CREATE_USER,CREATE_TIME,UPDATE_USER,UPDATE_TIME,UPDATE_COUNT,DEL_STATUS,SUB_COUNT,TREE_LEVEL,FATHER_ID,FATHER_VALUE,FULL_ENAME,FULL_CNAME,ORG_ID,DEPT_ID,SYS_NAME) values("
                                        echo -n "$code4,'areaAll',$code4,'$name4','',1,'','',1583676309804,'','','','',${#son5[@]},'',$pcode4,$pcode4,'/$code/$code1/$code2/$code3/$code4','/$name/$name1/$name2/$name3/$name4','','',''"
                                        echo ");"
                                    fi # level4
                                done
                            fi # level3
                        done
                    fi # level2
                done
            fi # level1
    done
fi # level
