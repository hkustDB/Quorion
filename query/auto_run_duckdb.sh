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

INPUT_DIR=$2
INPUT_DIR_PATH="${SCRIPT_PATH}/${INPUT_DIR}"

# graph, tpch, lsqb, job
DATABASE=$1
SCHEMA_FILE=$1

function prop {
    local config_files=$1
    local result=""
    local property_found=false

    for config_file in ${config_files[@]}; do
        # search the property key in config file if file exists
        if [[ -f ${config_file} ]]; then
            if grep -q "^[[:space:]]*$2=" "$config_file"; then
                result=$(grep "^[[:space:]]*$2=" "$config_file" | tail -n1 | cut -d '=' -f2-)
                property_found=true
                break
            fi
        fi
    done

    if [[ "${property_found}" == "true" ]]; then
        echo "${result}"
    elif [[ $# -gt 2 ]]; then
        echo "$3"
    else
        echo "ERROR: unable to load property $2 in ${config_files}" >&2
        exit 1
    fi
}

config_files=("${SCRIPT_PATH}/config.properties")
repeat_count=$(prop ${config_files} "common.experiment.repeat")
timeout_time=$(prop ${config_files} 'common.experiment.timeout')
duckdb=$(prop ${config_files} "duckdb.path")
NUM_THREADS=${3:-$(prop ${config_files} "duckdb.threads" 64)}
CPU_LIST=${4:-$(prop ${config_files} "duckdb.cpu_list" "0-15,24-71")}
EXCLUDED_QUERIES=$(prop ${config_files} "duckdb.excluded_queries" "")
RESUME_COMPLETED=$(prop ${config_files} "duckdb.resume_completed" "false")
RUN_SIGNATURE="threads=${NUM_THREADS};cpu_list=${CPU_LIST:-disabled};repeat=${repeat_count};timeout=${timeout_time}"

DUCKDB_COMMAND=("${duckdb}")
if [[ -n "${CPU_LIST}" ]]; then
    if [[ "${osName}" != "Linu" ]]; then
        echo "ERROR: taskset CPU affinity requires Linux. Set duckdb.cpu_list= to disable it." >&2
        exit 1
    fi
    if ! command -v taskset >/dev/null 2>&1; then
        echo "ERROR: taskset is required when duckdb.cpu_list is configured." >&2
        exit 1
    fi
    DUCKDB_COMMAND=(taskset --cpu-list "${CPU_LIST}" "${duckdb}")
fi

echo "Config file: ${config_files}"
echo "Repeat count: ${repeat_count}"
echo "Timeout time: ${timeout_time}"
echo "DuckDB path: ${duckdb}"
echo "DuckDB threads: ${NUM_THREADS}"
echo "DuckDB CPU list: ${CPU_LIST:-disabled}"
echo "Excluded benchmarks/queries: ${EXCLUDED_QUERIES:-none}"
echo "Resume completed queries: ${RESUME_COMPLETED}"

function NormalizeExcludedTarget() {
    local target="${1#./}"
    local target_prefix
    local target_suffix=

    target="${target#query/}"
    target="${target%/}"

    if [[ "${target}" == */* ]]; then
        target_prefix="${target%%/*}"
        target_suffix="${target#*/}"
    else
        target_prefix="${target}"
    fi

    target_prefix="${target_prefix%_duckdb}"

    if [[ -n "${target_suffix}" ]]; then
        printf '%s/%s\n' "${target_prefix}" "${target_suffix}"
    else
        printf '%s\n' "${target_prefix}"
    fi
}

function IsExcluded() {
    local candidate
    candidate=$(NormalizeExcludedTarget "$1")

    local excluded
    local -a exclusion_list
    IFS=',' read -r -a exclusion_list <<< "${EXCLUDED_QUERIES}"

    for excluded in "${exclusion_list[@]}"; do
        excluded="${excluded#"${excluded%%[![:space:]]*}"}"
        excluded="${excluded%"${excluded##*[![:space:]]}"}"
        excluded="${excluded#./}"
        excluded="${excluded#query/}"
        excluded="${excluded%/}"
        excluded=$(NormalizeExcludedTarget "${excluded}")

        if [[ -n "${excluded}" && "${candidate}" == "${excluded}" ]]; then
            return 0
        fi
    done

    return 1
}

if IsExcluded "${INPUT_DIR}"; then
    echo "Skipping excluded benchmark directory: ${INPUT_DIR}"
    exit 0
fi

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
        QUERY_GROUP="${DATABASE}/$(basename "${dir}")"

        if IsExcluded "${QUERY_GROUP}"; then
            echo "Skipping excluded query group: ${QUERY_GROUP}"
            continue
        fi

        for file in $(ls ${CUR_PATH})
        do
            IsSuffix ${file}
            ret=$?
            if [ $ret -eq 0 ]
            then
                if [[ "${file}" =~ ^query_[0-9]+\.sql$ || "${file}" =~ ^.*_[0-9]+_[12]\.sql$ ]]; then
                    echo "Skipping temporary SQL file: ${QUERY_GROUP}/${file}"
                    continue
                fi

                QUERY_ID="${QUERY_GROUP}/${file}"
                if IsExcluded "${QUERY_ID}"; then
                    echo "Skipping excluded SQL file: ${QUERY_ID}"
                    continue
                fi

                filename="${file%.*}"
                LOG_FILE="${CUR_PATH}/log_${filename}_duckdb.txt"
                LOG_META_FILE="${LOG_FILE}.meta"

                if [[ "${RESUME_COMPLETED}" == "true" && -f "${LOG_FILE}" && -f "${LOG_META_FILE}" ]]; then
                    LAST_LOG_LINE=$(tail -n 1 "${LOG_FILE}")
                    COMPLETED_RUNS=$(grep -c '^Exec time(s):' "${LOG_FILE}" || true)
                    SAVED_RUN_SIGNATURE=$(<"${LOG_META_FILE}")
                    if [[ "${SAVED_RUN_SIGNATURE}" == "${RUN_SIGNATURE}" &&
                          "${LAST_LOG_LINE}" == AVG\ * &&
                          "${COMPLETED_RUNS}" -eq "${repeat_count}" ]] &&
                       ! grep -qx '0' "${LOG_FILE}"; then
                        echo "Skipping completed SQL file: ${QUERY_ID}"
                        continue
                    fi
                fi

                rm -f "${LOG_FILE}" "${LOG_META_FILE}"
                touch "${LOG_FILE}"
                printf '%s\n' "${RUN_SIGNATURE}" > "${LOG_META_FILE}"
                QUERY="${CUR_PATH}/${file}"
                RAN=$RANDOM
                if [ ${filename} = "query" ]
                then 
                    SUBMIT_QUERY="${CUR_PATH}/query_${RAN}.sql"
                    rm -f "${SUBMIT_QUERY}"
                    touch "${SUBMIT_QUERY}"
                    echo "COPY (" >> ${SUBMIT_QUERY}
                    cat ${QUERY} >> ${SUBMIT_QUERY}
                    echo ") TO '/dev/null' (DELIMITER ',');" >> ${SUBMIT_QUERY}
                    echo "Start DuckDB Task at ${QUERY}"
                    current_task=1
                    while [[ ${current_task} -le ${repeat_count} ]]
                    do
                        echo "Current Task: ${current_task}"
                        OUT_FILE="${CUR_PATH}/output.txt"
                        rm -f $OUT_FILE
                        touch $OUT_FILE
                        timeout -s SIGKILL "${timeout_time}" "${DUCKDB_COMMAND[@]}" -c ".open ${SCHEMA_FILE}_db" -c "SET threads TO ${NUM_THREADS};" -c ".timer off" -c ".read ${SUBMIT_QUERY}" -c ".timer on" -c ".read ${SUBMIT_QUERY}" | grep "Run Time (s): real" >> $OUT_FILE
                        pipeline_status=("${PIPESTATUS[@]}")
                        status_code=${pipeline_status[0]}
                        grep_status=${pipeline_status[1]}
                        if [[ ${status_code} -eq 124 || ${status_code} -eq 137 ]]; then
                            echo "0" >> $LOG_FILE
                            break
                        elif [[ ${status_code} -ne 0 || ${grep_status} -ne 0 ]]; then
                            echo "0" >> $LOG_FILE
                            break
                        else
                            awk 'BEGIN{sum=0;}{sum+=$5;} END{printf "Exec time(s): %f\n", sum;}' $OUT_FILE >> $LOG_FILE
                        fi
                        current_task=$(($current_task+1))
                    done
                    awk '{s+=$3} END{if(NR) print "AVG", s/NR}' "$LOG_FILE" >> "$LOG_FILE"
                    echo "End DuckDB Task..."
                    rm -f $OUT_FILE
                    rm -f ${SUBMIT_QUERY}
                else
                    SUBMIT_QUERY_1="${CUR_PATH}/${filename}_${RAN}_1.sql"
                    rm -f "${SUBMIT_QUERY_1}"
                    SUBMIT_QUERY_2="${CUR_PATH}/${filename}_${RAN}_2.sql"
                    rm -f "${SUBMIT_QUERY_2}"

                    LAST_SQL_LINE=$(
                        awk '$0 !~ /^[[:space:]]*$/ { last = NR } END { print last + 0 }' \
                            "${QUERY}"
                    )
                    if [[ "${LAST_SQL_LINE}" -eq 0 ]]; then
                        echo "ERROR: SQL file has no statement: ${QUERY}" >&2
                        rm -f "${SUBMIT_QUERY_1}" "${SUBMIT_QUERY_2}"
                        continue
                    fi

                    awk -v last="${LAST_SQL_LINE}" 'NR < last { print }' \
                        "${QUERY}" > "${SUBMIT_QUERY_1}"

                    {
                        printf 'COPY (\n'
                        awk -v last="${LAST_SQL_LINE}" '
                            NR == last {
                                statement = $0
                                sub(/[[:space:]]+$/, "", statement)
                                sub(/;$/, "", statement)
                                sub(/[[:space:]]+$/, "", statement)
                                print statement
                                exit
                            }
                        ' "${QUERY}"
                        printf "%s\n" ") TO '/dev/null' (DELIMITER ',');"
                    } > "${SUBMIT_QUERY_2}"

                    echo "Start DuckDB Task at ${QUERY}"
                    current_task=1
                    while [[ ${current_task} -le ${repeat_count} ]]
                    do
                        echo "Current Task: ${current_task}"
                        OUT_FILE="${CUR_PATH}/output.txt"
                        rm -f $OUT_FILE
                        touch $OUT_FILE
                        timeout -s SIGKILL "${timeout_time}" "${DUCKDB_COMMAND[@]}" -c ".open ${SCHEMA_FILE}_db" -c "SET threads TO ${NUM_THREADS};" -c ".timer off" -c ".read ${SUBMIT_QUERY_1}" -c ".read ${SUBMIT_QUERY_2}" -c ".timer on" -c ".read ${SUBMIT_QUERY_2}" | grep "Run Time (s): real" >> $OUT_FILE
                        pipeline_status=("${PIPESTATUS[@]}")
                        status_code=${pipeline_status[0]}
                        grep_status=${pipeline_status[1]}
                        if [[ ${status_code} -eq 124 || ${status_code} -eq 137 ]]; then
                            echo "0" >> $LOG_FILE
                            break
                        elif [[ ${status_code} -ne 0 || ${grep_status} -ne 0 ]]; then
                            echo "0" >> $LOG_FILE
                            break
                        else
                            awk 'BEGIN{sum=0;}{sum+=$5;} END{printf "Exec time(s): %f\n", sum;}' $OUT_FILE >> $LOG_FILE
                        fi
                        current_task=$(($current_task+1))
                    done
                    awk '{s+=$3} END{if(NR) printf "AVG %.6f\n", s/NR}' "$LOG_FILE" >> "$LOG_FILE"
                    echo "End DuckDB Task..."
                    rm -f $OUT_FILE
                    rm -f $SUBMIT_QUERY_1
                    rm -f $SUBMIT_QUERY_2
                fi
            fi
        done
    fi
done
