#!/bin/bash

trap 'echo "Interrupted"; kill 0; exit 130' INT

uNames=`uname -s`
osName=${uNames: 0: 4}
if [ "$osName" == "Darw" ] # Darwin
then
	COMMAND="ghead"
elif [ "$osName" == "Linu" ] # Linux
then
	COMMAND="head"
fi

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname "${SCRIPT}")

INPUT_DIR=$1
PARALLEL=${2:-2}
HALF_PARALLEL=$(((PARALLEL + 1) / 2))
INPUT_DIR_PATH="${SCRIPT_PATH}/${INPUT_DIR}"

function prop {
    config_files=$1
    for config_file in ${config_files[@]}; do
        # search the property key in config file if file exists
        if [[ -f ${config_file} ]]; then
            result=$(grep "^\s*$2=" $config_file | tail -n1 | cut -d '=' -f2)
            if [[ -n ${result} ]]; then
                break
            fi
        fi
    done

    if [[ -n ${result} ]]; then
        echo ${result}
    elif [[ $# -gt 2 ]]; then
        echo $3
    else
        err "ERROR: unable to load property $2 in ${config_files}"
        exit 1
    fi
}

config_files=("${SCRIPT_PATH}/config.properties")
repeat_count=$(prop ${config_files} "common.experiment.repeat")
timeout_time=$(prop ${config_files} 'common.experiment.timeout')
PG=$(prop ${config_files} "pg.path")
DB=$(prop ${config_files} "pg.db")
port=$(prop ${config_files} "pg.port")

echo "Config file: ${config_files}"
echo "Repeat count: ${repeat_count}"
echo "Timeout time: ${timeout_time}"
echo "PostgreSQL path: ${PG}"
echo "PostgreSQL DB: ${DB}"
echo "PostgreSQL port: ${port}"

# Suffix function
function FileSuffix() {
    local filename="$1"
    if [ -n "$filename" ]; then
        echo "${filename##*.}"
    fi
}

function IsSuffix() {
    local filename="$1"
    if [ "$(FileSuffix ${filename})" = "sql" ]
    then
        return 0
    else 
        return 1
    fi
}

dirs=$(find ${INPUT_DIR} -mindepth 1 -maxdepth 1 -type d | sort -V)
for dir in $dirs;
do
    if [ $dir != ${INPUT_DIR} ]; then
        CUR_PATH="${SCRIPT_PATH}/${dir}"
        for file in $(ls ${CUR_PATH})
        do
            IsSuffix ${file}
            ret=$?
            if [ $ret -eq 0 ]
            then
                filename="${file%.*}"
                LOG_FILE="${CUR_PATH}/log_${filename}_pg.txt"
                rm -f $LOG_FILE
                touch $LOG_FILE
                QUERY="${CUR_PATH}/${file}"
                RAN=$RANDOM
                if [ ${filename} = "query" ]
                then 
                    SUBMIT_QUERY="${CUR_PATH}/query_${RAN}.sql"
                    rm -f "${SUBMIT_QUERY}"
                    touch "${SUBMIT_QUERY}"
                    # extra settings for parallelism
                    echo "SET max_parallel_workers=${HALF_PARALLEL};" >> ${SUBMIT_QUERY}
                    echo "SET enable_nestloop=off;" >> ${SUBMIT_QUERY}

                    echo "COPY (" >> ${SUBMIT_QUERY}
                    cat ${QUERY} >> ${SUBMIT_QUERY}
                    echo ") TO '/dev/null' DELIMITER ',' CSV;" >> ${SUBMIT_QUERY}
                    echo "Start PG Task at ${QUERY}"
                    current_task=1
                    while [[ ${current_task} -le ${repeat_count} ]]
                    do
                        echo "Current Task: ${current_task}"
                        OUT_FILE="${CUR_PATH}/output.txt"
                        rm -f $OUT_FILE
                        touch $OUT_FILE
                        timeout -s SIGKILL "${timeout_time}" $PG "-d" "${DB}" "-p" "${port}" "-c" "\timing off" "-f" "${SUBMIT_QUERY}" "-c" "\timing on" "-f" "${SUBMIT_QUERY}" | grep "Time: " >> $OUT_FILE
                        status_code=$?
                        if [[ ${status_code} -eq 137 ]]; then
                            echo "0" >> $LOG_FILE
                            break
                        elif [[ ${status_code} -ne 0 ]]; then
                            echo "0" >> $LOG_FILE
                            break
                        else
                            awk 'BEGIN{sum=0;}{sum+=$2;} END{printf "Exec time(s): %f\n", sum;}' $OUT_FILE >> $LOG_FILE
                            cat $OUT_FILE >> $LOG_FILE
                        fi
                        current_task=$(($current_task+1))
                    done
                    awk '/Exec time/ {s+=$3; count++} END{if(count) printf "AVG %.6f\n", s/count}' "$LOG_FILE" >> "$LOG_FILE"
                    echo "End PG Task..."
                    rm -f $OUT_FILE
                    rm -f ${SUBMIT_QUERY}
                    rm -f ${SET_QUERY}
                else
                    SUBMIT_QUERY_1="${CUR_PATH}/${filename}_${RAN}_1.sql"
                    rm -f "${SUBMIT_QUERY_1}"
                    touch "${SUBMIT_QUERY_1}"
                    SUBMIT_QUERY_2="${CUR_PATH}/${filename}_${RAN}_2.sql"
                    rm -f "${SUBMIT_QUERY_2}"
                    touch "${SUBMIT_QUERY_2}"
                    # extra settings for parallelism
                    echo "SET max_parallel_workers=${HALF_PARALLEL};" >> ${SUBMIT_QUERY_1}
                    echo "SET enable_nestloop=off;" >> ${SUBMIT_QUERY_1}

                    echo "SET max_parallel_workers=${HALF_PARALLEL};" >> ${SUBMIT_QUERY_2}
                    echo "SET enable_nestloop = off;" >> ${SUBMIT_QUERY_2}

                    ${COMMAND} -n -1 ${QUERY} >> ${SUBMIT_QUERY_1}
                    echo "COPY (" >> ${SUBMIT_QUERY_2}
                    tail -n 1 ${QUERY} | sed 's/;//g' >> ${SUBMIT_QUERY_2}
                    echo ") TO '/dev/null' DELIMITER ',' CSV;" >> ${SUBMIT_QUERY_2}
                    echo "Start PG Task at ${QUERY}"
                    current_task=1
                    while [[ ${current_task} -le ${repeat_count} ]]
                    do
                        echo "Current Task: ${current_task}"
                        OUT_FILE="${CUR_PATH}/output.txt"
                        rm -f $OUT_FILE
                        touch $OUT_FILE
                        timeout -s SIGKILL "${timeout_time}" $PG "-d" "${DB}" "-p" "${port}" "-c" "\timing off" "-f" "${SUBMIT_QUERY_1}" "-f" "${SUBMIT_QUERY_2}" "-c" "\timing on" "-f" "${SUBMIT_QUERY_2}" | grep "Time: " >> $OUT_FILE
                        status_code=$?
                        if [[ ${status_code} -eq 137 ]]; then
                           echo "0" >> $LOG_FILE
                           break
                        elif [[ ${status_code} -ne 0 ]]; then
                            echo "0" >> $LOG_FILE
                            break
                        else
                            awk 'BEGIN{sum=0;}{sum+=$2;} END{printf "Exec time(s): %f\n", sum;}' $OUT_FILE >> $LOG_FILE
                        fi
                        current_task=$(($current_task+1))
                    done
                    awk '/Exec time/ {s+=$3; count++} END{if(count) printf "AVG %.6f\n", s/count}' "$LOG_FILE" >> "$LOG_FILE"
                    echo "End PG Task..."
                    rm -f $OUT_FILE
                    rm -f $SUBMIT_QUERY_1
                    rm -f $SUBMIT_QUERY_2
                    rm -f $SET_QUERY
                fi
            fi
        done
    fi
done