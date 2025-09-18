#!/bin/bash

# 定义大文件夹的名称
JOB_FOLDER="job"
SCHEMA="jobSchema"
NUM=4

# 检查大文件夹是否存在
if [ ! -d "$JOB_FOLDER" ]; then
  echo "错误：文件夹 '$JOB_FOLDER' 不存在。"
  exit 1
fi

# 遍历大文件夹下的所有 .sql 文件
for SQL_FILE in "$JOB_FOLDER"/*.sql; do
  if [ -f "$SQL_FILE" ]; then
    # 获取文件名
    FILE_NAME=$(basename "$SQL_FILE")
    # 生成并输出命令
    echo "bash ExecuteQuery.sh $FILE_NAME $SCHEMA $NUM"
  fi
done