#!/bin/bash

#配置信息
backup_path="."
backup_date=$(date +%Y-%m-%d)
backup_datetime=$(date +%Y-%m-%d\ %H:%M:%S)
backup_prefix="$backup_path/$backup_date/"

#过期配置
enable_delete_expire="true"
expire_days=7


#输入连接信息
mysql_user="root"
mysql_password="123456"
mysql_host="127.0.0.1"
mysql_port="3306"

# 备份目标数据库
backup_db_arr=("xxx" "ccc") 

echo "backup date $backup_date"
echo "backup prefix $backup_prefix"
echo "start backup mysql at $backup_datetime..."
echo "backup mysql info: user:$mysql_user, host:$mysql_host, port:$mysql_port"

# 打印需要备份的数据库名
echo "Backup databases:" "${backup_db_arr[@]}"

# 备份函数
backup_database() {
    local backup_file_time=$(date +%Y%m%d%H%M%S)
    local db_name=$1
    local backup_file_name=$db_name-$backup_file_time.sql
    local finally_backup_dir="$backup_prefix$db_name"
    local finally_backup_file_path="$finally_backup_dir/$backup_file_name"
    echo "backup"
    mkdir -p "$finally_backup_dir"
    echo "mysqldump -u"$mysql_user" -p"$mysql_password" -h"$mysql_host" -P"$mysql_port" -F -B --default-character-set=utf8 "$db_name" > "$finally_backup_file_path""
    mysqldump -u"$mysql_user" -p"$mysql_password" -h"$mysql_host" -P"$mysql_port" -F -B --default-character-set=utf8 "$db_name" > "$finally_backup_file_path"
    if [ $? -eq 0 ]; then
        echo "Database $db_name backup successful. File: $finally_backup_file_path"
    else
        echo "Database $db_name backup failed."
    fi
}

# 循环遍历数据库数组并备份
for db in "${backup_db_arr[@]}"; do
    echo "Starting backup for database: $db"
    backup_database "$db"
done

# 删除过期数据
if [ "$enable_delete_expire" = "true" ] && [ -n "$backup_path" ]; then
    find "$backup_path"/ -type f -mtime +"$expire_days" -exec rm -rf {} \;
    echo "delete invalid database backup information! $backup_dir"
fi

echo "All databases backup completed."
