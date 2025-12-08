#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname "${SCRIPT}")

source "${SCRIPT_PATH}/common.sh"

config_files=("${SCRIPT_PATH}/../query/config.properties")

function execute_sparksql {
  sparkJar="${SCRIPT_PATH}/target/spark-sql-test-1.0-SNAPSHOT-jar-with-dependencies.jar"
  spark_home=$(prop ${config_files} "spark.home")
  spark_submit="${spark_home}/bin/spark-submit"

  dataPath=$1
  queryPath=$2
  schema=$3
  tableSuffix=$4
  parallelism=$5

  # rm -rf "${SCRIPT_PATH}/log/"
  mkdir -p "${SCRIPT_PATH}/log/"

  log_file="${SCRIPT_PATH}/log/${schema}.log"

  rm -f "${log_file} ${result_file}"
  touch "${log_file}"

  repeat_count=$(prop ${config_files} "common.experiment.repeat")

  current_task=1
  while [[ ${current_task} -le ${repeat_count} ]]
  do
      timeout -s SIGKILL 8h ${spark_submit} --class SparkSQLRunner --master "local[${parallelism}]" --driver-memory 4G --executor-memory 4G --conf "spark.shuffle.service.removeShuffle=true" --conf "spark.local.dir=/home/data/spark_temp" ${sparkJar} ${dataPath} "${queryPath}" "${SCRIPT_PATH}/Schema/${schema}.sql" "${tableSuffix}" >> ${log_file} 2>&1

      current_task=$(($current_task+1))
  done
}

execute_sparksql $1 $2 $3 $4 $5