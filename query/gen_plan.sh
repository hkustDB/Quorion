#!/bin/bash

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

INPUT_DIR=$2
INPUT_DIR_PATH="${SCRIPT_PATH}/${INPUT_DIR}"

# graph, tpch, lsqb
DATABASE=$1
SCHEMA_FILE=$1

# TODO: DuckDB and Python3 paths. Modify them. 
duckdb="/opt/homebrew/bin/duckdb"
python3="/usr/bin/python3"

NUM_THREADS=${3:-72}

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

for dir in $(find ${INPUT_DIR} -type d);
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
                LOG_FILE="${CUR_PATH}/log_${filename}.txt"
                rm -f $LOG_FILE
                touch $LOG_FILE
                QUERY="${CUR_PATH}/${file}"
                RAN=$RANDOM
                
                if [ ${filename} = "query" ]
                then 
                    SUBMIT_QUERY="${CUR_PATH}/query_${RAN}.sql"
                    rm -f "${SUBMIT_QUERY}"
                    touch "${SUBMIT_QUERY}"
                    echo "EXPLAIN (FORMAT json) " >> ${SUBMIT_QUERY}
                    cat ${QUERY} >> ${SUBMIT_QUERY}
                    echo "Start DuckDB Explain Task at ${QUERY}"
                    # cat ${SUBMIT_QUERY}
                    
                    PLAN_FILE="${CUR_PATH}/db_plan.json"
                    rm -f $PLAN_FILE
                    touch $PLAN_FILE
                    
                    timeout -s SIGKILL 5m $duckdb -c ".open ${DATABASE}" -c ".read ${SUBMIT_QUERY}" | tail -n +7 > $PLAN_FILE
                    status_code=$?
                    
                    if [[ ${status_code} -eq 137 ]]; then
                        echo "duckdb explain task timed out." >> $LOG_FILE
                    elif [[ ${status_code} -ne 0 ]]; then
                        echo "duckdb explain task failed." >> $LOG_FILE
                    else
                        echo "Explain plan saved to db_plan.json" >> $LOG_FILE
                    fi
                    echo "======================" >> $LOG_FILE

                    $python3 "${SCRIPT_PATH}/trans_plan.py" ${CUR_PATH}

                    echo "End DuckDB Explain Task..."
                    rm -f ${SUBMIT_QUERY}
                fi
            fi
        done
    fi
done