#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$PARENT_DIR/query/config.properties"

source "$PARENT_DIR/query/common.sh"

# Read parser configuration
PARSER_HOME=$(prop "$CONFIG_FILE" "parser.home")
PARSER_DATA_PATH=$PARSER_HOME
PARSER_MODE=$(prop "$CONFIG_FILE" "parser.mode")
PARSER_HDFS_HOST=$(prop "$CONFIG_FILE" "parser.hdfs.host")
PARSER_HDFS_PORT=$(prop "$CONFIG_FILE" "parser.hdfs.port")
PARSER_HDFS_PATH=$PARSER_HOME
PARSER_HDFS_USER=$(prop "$CONFIG_FILE" "parser.hdfs.user")


# Calculate JAR path
PARSER_JAR_PATH="$PARSER_HOME/../sparksql-plus-web-jar-with-dependencies.jar"

java -jar sparksql-plus-web-jar-with-dependencies.jar
# java -Dsqlplus.home="$PARSER_HOME" \
#            -Dexperiment.data.path="$PARSER_DATA_PATH" \
#            -Dexperiment.mode="$PARSER_MODE" \
#            -Dexperiment.hdfs.host="$PARSER_HDFS_HOST" \
#            -Dexperiment.hdfs.port="$PARSER_HDFS_PORT" \
#            -Dexperiment.hdfs.path="$PARSER_HDFS_PATH" \
#            -Dexperiment.hdfs.user="$PARSER_HDFS_USER" \
#            -jar sparksql-plus-web-jar-with-dependencies.jar