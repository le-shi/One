
 [网上找的文档](<https://www.jianshu.com/p/7e4d99f6baaf>)

 [官网文档](<https://www.openldap.org/doc/admin26/quickstart.html>)

 [入门级介绍文档](<https://www.brennan.id.au/20-Shared_Address_Book_LDAP.html>)

总结一下LDAP树形数据库如下:
dn : 一条记录的详细位置
dc : 一条记录所属区域 (哪一颗树)
ou : 一条记录所属组织 (哪一个分支)
o : 一条记录所属组织 (哪一个分支的更上一层)
cn/uid : 一条记录的名字/ID (哪一个苹果名字)
LDAP目录树的最顶部就是根，也就是所谓的"基准DN"

---

| 名词 | 属性类型                 | 说明                                             |
| ---- | ------------------------ | ------------------------------------------------ |
| dn   | Distinguished Name       | 一条记录的详细位置                               |
| dc   | Domain Component         | 一条记录所属(区域/域/树)                         |
| ou   | Organisational Unit Name | 一条记录的所属组织单元(部门/分支)，ou属于o的下级 |
| o    | Organisational Name      | 一条记录的所属组织(公司)                         |
| cn   | Common Name              | 一条记录的名字                                   |
| uid  | User Identification      | 一条记录的ID                                     |
| sn   | surname                  | 一条记录的姓                                     |


---
域名: zbx.lab

```conf
# /usr/local/etc/openldap/slapd.ldif
# https://www.openldap.org/doc/admin26/slapdconf2.html

dn: olcDatabase=mdb,cn=config
objectClass: olcDatabaseConfig
objectClass: olcMdbConfig
olcDatabase: mdb
OlcDbMaxSize: 1073741824
olcSuffix: dc=zbx,dc=lab
olcRootDN: cn=Manager,dc=zbx,dc=lab
olcRootPW: secret
olcDbDirectory: /usr/local/var/openldap-data
olcDbIndex: objectClass eq
```


```bash
# 导入配置数据库

# 导入配置数据库之前创建目录
mkdir -pv /usr/local/etc/slapd.d
mkdir -pv /usr/local/var/openldap-data

su root -c /usr/local/sbin/slapadd -n 0 -F /usr/local/etc/slapd.d -l /usr/local/etc/openldap/slapd.ldif

# 上面命令返回 Closing DB... 表示[导入配置数据库]成功
```

```bash
# 启动 slapd 服务
/usr/local/libexec/slapd -F /usr/local/etc/slapd.d
# 验证: 下面这条命令返回两条 slapd 记录，表示 slapd 服务启动成功
ss -anplt | grep slapd

# 验证: 要检查服务器是否正在运行并配置正确，可以使用ldapsearch(1)对其运行搜索。默认情况下，ldapsearch的安装路径为/usr/local/bin/ldapsearch:
ldapsearch -x -b '' -s base '(objectclass=*)' namingContexts
# 注意，命令参数周围使用单引号，以防止shell解释特殊字符。这应该返回:
dn:
namingContexts: dc=zbx,dc=lab
```

```bash
# 向目录中添加初始条目

# 您可以使用 ldapadd(1) 向 LDAP 目录添加条目。ldapadd 期望以 LDIF 形式的文件作为输入。我们将分两个步骤:
# 1. 创建 LDIF 文件
# 2. 运行 ldapadd 将这些条目插入到目录中

## 开始操作 ##
# 1. 创建 LDIF 文件
# 请确保将 <MY-DOMAIN> 和 <COM> 替换为域名的适当域组件。<MY ORGANIZATION>应该被替换为您的组织的名称。在剪切和粘贴时，请确保删除任何开头和结尾的空格。

# 例子
dn: dc=<MY-DOMAIN>,dc=<COM>
objectclass: dcObject
objectclass: organization
o: <MY ORGANIZATION>
dc: <MY-DOMAIN>

dn: cn=Manager,dc=<MY-DOMAIN>,dc=<COM>
objectclass: organizationalRole
cn: Manager

# 修改后的，文件保存为 zbx.ldif
dn: dc=zbx,dc=lab
objectclass: dcObject
objectclass: organization
o: zbxsoft
dc: zbx

dn: cn=Manager,dc=zbx,dc=lab
objectclass: organizationalRole
cn: Manager


# 2. 运行 ldapadd 将这些条目插入到目录中
ldapadd -x -D "cn=Manager,dc=zbx,dc=lab" -W -f zbx.ldif

# 系统将提示您输入 slapd.conf 中 olcRootPW 键的值 "secret"

# 上面命令返回一下内容，表示添加条目成功
adding new entry "dc=zbx,dc=lab"

adding new entry "cn=Manager,dc=zbx,dc=lab"

# 验证: 我们已经准备好验证添加的条目是否在您的目录中。您可以使用任何LDAP客户机来完成此操作，但是我们的示例使用了ldapsearch(1)工具。这个命令将搜索并获得数据库中的所有条目。
ldapsearch -x -b 'dc=zbx,dc=lab' '(objectclass=*)'

# 现在，您可以使用ldapadd(1)或另一个LDAP客户机添加更多条目，尝试各种配置选项、后端安排等。
```