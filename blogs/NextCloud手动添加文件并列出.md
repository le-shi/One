NextCloud 自带的数据目录在列目录时都是通过数据库查询，如果需要手动在磁盘目录上添加文件并使用nextcloud列出就需要手动扫描。手动删除也是同样的道理，可以通过扫描命令进行更新文件索引，扫描速度取决于数据量的大小，数据量越大耗时越长

```bash
# 扫描所有账户的文件
sudo -u www php console.php files:scan --all
# 扫描指定路径的文件
sudo -u www php console.php files:scan --path path/to/files
# 扫描指定账户的文件
sudo -u www php console.php files:scan user_id
```
