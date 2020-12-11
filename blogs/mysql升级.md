- 5.7.30 -> 8.0.20
> [准备安装进行升级](https://dev.mysql.com/doc/refman/8.0/en/upgrade-prerequisites.html)
> [升级MySQL服务器容器](https://dev.mysql.com/doc/refman/8.0/en/docker-mysql-getting-started.html#docker-upgrading)

1. 升级检查
    1. 数据库检查升级
    ```bash
    mysqlcheck -u root -p --all-databases --check-upgrade
    ```
    1. 查询数据库内有没有不合格的信息
    ```sql
    # 查询存储引擎不是INNODB或ndb的(MyISAM)
    SELECT TABLE_SCHEMA, TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE ENGINE NOT IN ('innodb', 'ndbcluster')
    AND CREATE_OPTIONS LIKE '%partitioned%';

    # MySQL 5.7 mysql系统数据库中的表不得 与MySQL 8.0数据字典使用的表同名
    SELECT TABLE_SCHEMA, TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE LOWER(TABLE_SCHEMA) = 'mysql'
    and LOWER(TABLE_NAME) IN
    (
    'catalogs',
    'character_sets',
    'check_constraints',
    'collations',
    'column_statistics',
    'column_type_elements',
    'columns',
    'dd_properties',
    'events',
    'foreign_key_column_usage',
    'foreign_keys',
    'index_column_usage',
    'index_partitions',
    'index_stats',
    'indexes',
    'parameter_type_elements',
    'parameters',
    'resource_groups',
    'routines',
    'schemata',
    'st_spatial_reference_systems',
    'table_partition_values',
    'table_partitions',
    'table_stats',
    'tables',
    'tablespace_files',
    'tablespaces',
    'triggers',
    'view_routine_usage',
    'view_table_usage'
    );

    # 不得有外键约束名称超过64个字符的表
    SELECT TABLE_SCHEMA, TABLE_NAME
    FROM INFORMATION_SCHEMA.TABLES
    WHERE TABLE_NAME IN
    (SELECT LEFT(SUBSTR(ID,INSTR(ID,'/')+1),
                INSTR(SUBSTR(ID,INSTR(ID,'/')+1),'_ibfk_')-1)
    FROM INFORMATION_SCHEMA.INNODB_SYS_FOREIGN
    WHERE LENGTH(SUBSTR(ID,INSTR(ID,'/')+1))>64);

    # 升级到MySQL 8.0.13或更高版本之前，共享InnoDB表空间中不得存在任何表分区，共享 表空间应包括系统表空间和常规表空间
    SELECT DISTINCT NAME, SPACE, SPACE_TYPE FROM INFORMATION_SCHEMA.INNODB_SYS_TABLES
    WHERE NAME LIKE '%#P#%' AND SPACE_TYPE NOT LIKE 'Single';

    # 如果打算lower_case_table_names 在升级时将设置更改 为1，请在升级之前确保方案和表名均为小写。否则，由于架构或表名字母大小写不匹配，可能会发生故障。您可以使用以下查询来检查包含大写字符的模式和表名称
    SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME != LOWER(TABLE_NAME) AND TABLE_TYPE = 'BASE TABLE';
    SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME != LOWER(SCHEMA_NAME);
    ```
2. 准备升级
    1. 检查完成后,准备升级
    2. my.cnf配置文件需要注意
        - 新增配置:
          - 限制mysql的导入导出: `secure-file-priv=/var/lib/mysql`
        - 删除配置: 
          - `!includedir /etc/mysql/mysql.conf.d/`

3. 开始升级
    1. 将mysql的镜像版本号由5.7.x改成8.0.20
    2. 启动,通过日志查看升级过程
    3. 升级完成后,重启mysql服务
    4. 继续工作