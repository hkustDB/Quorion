#!/bin/bash

set -euo pipefail

CURRENT_SCRIPT=$(readlink -f $0)
CURRENT_PATH=$(dirname "${CURRENT_SCRIPT}")
ROOT_PATH=$(dirname "${CURRENT_PATH}")
QUERY_PATH="${ROOT_PATH}/query"

LSQB_SCALE=${1:-1}
TPCH_SCALE=${2:-1}

echo "Downloading DuckDB 1.5.4..."
cd "${QUERY_PATH}"
rm -rf "${QUERY_PATH}/duckdb_cli-*"
rm -f "${QUERY_PATH}/duckdb"
wget https://github.com/duckdb/duckdb/releases/download/v1.5.4/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-*.zip
rm -f duckdb_cli-*.zip

echo "" >> "${QUERY_PATH}/config.properties"
echo "duckdb.path=${QUERY_PATH}/duckdb" >> "${QUERY_PATH}/config.properties"
echo "" >> "${QUERY_PATH}/config.properties"
echo "parser.home=${ROOT_PATH}/SparkSQLPlus" >> "${QUERY_PATH}/config.properties"
echo "" >> "${QUERY_PATH}/config.properties"

database_is_ready() {
    local DATABASE_PATH=$1
    local DATASET=$2
    local REQUIRED_TABLES
    local REQUIRED_VIEWS
    local SCHEMA_NAMES=
    local VALIDATION_SQL
    local SCHEMA_COUNT
    local ROW_PRESENT
    local RELATION_NAME
    local LOWER_RELATION_NAME
    local TABLE_NAME
    local -a REQUIRED_TABLE_ARRAY=()
    local -a REQUIRED_VIEW_ARRAY=()
    local -a REQUIRED_RELATIONS=()

    case "${DATASET}" in
        graph)
            REQUIRED_TABLES="graph bitcoin dblp google"
            REQUIRED_VIEWS=
            ;;
        lsqb)
            REQUIRED_TABLES="Company University Continent Country City Tag TagClass Forum Comment Post Person Comment_hasTag_Tag Post_hasTag_Tag Forum_hasMember_Person Forum_hasTag_Tag Person_hasInterest_Tag Person_likes_Comment Person_likes_Post Person_studyAt_University Person_workAt_Company Person_knows_Person Person_knows_Person2"
            REQUIRED_VIEWS="Message Comment_replyOf_Message Message_hasCreator_Person Message_hasTag_Tag Message_isLocatedIn_Country Person_likes_Message"
            ;;
        tpch)
            REQUIRED_TABLES="nation region part supplier partsupp customer orders lineitem"
            REQUIRED_VIEWS="q2_inner orderswithyear lineitemwithyear revenue0 q15_inner q17_inner q18_inner q20_inner1 q20_inner2"
            ;;
        job)
            REQUIRED_TABLES="aka_name aka_title cast_info char_name comp_cast_type company_name company_type complete_cast info_type keyword kind_type link_type movie_companies movie_info_idx movie_keyword movie_link name role_type title movie_info person_info"
            REQUIRED_VIEWS=
            ;;
        *) return 1 ;;
    esac

    if [ ! -f "${DATABASE_PATH}" ]; then
        return 1
    fi

    if [ ! -r "${DATABASE_PATH}" ]; then
        return 2
    fi

    read -r -a REQUIRED_TABLE_ARRAY <<< "${REQUIRED_TABLES}"
    if [ -n "${REQUIRED_VIEWS}" ]; then
        read -r -a REQUIRED_VIEW_ARRAY <<< "${REQUIRED_VIEWS}"
    fi
    REQUIRED_RELATIONS=("${REQUIRED_TABLE_ARRAY[@]}" "${REQUIRED_VIEW_ARRAY[@]}")

    for RELATION_NAME in "${REQUIRED_RELATIONS[@]}"; do
        if [ -n "${SCHEMA_NAMES}" ]; then
            SCHEMA_NAMES+=","
        fi
        LOWER_RELATION_NAME=$(printf '%s' "${RELATION_NAME}" | tr '[:upper:]' '[:lower:]')
        SCHEMA_NAMES+="'${LOWER_RELATION_NAME}'"
    done

    if ! SCHEMA_COUNT=$(
        "${QUERY_PATH}/duckdb" \
            -c ".open ${DATABASE_PATH}" \
            -c ".mode list" \
            -c ".headers off" \
            -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'main' AND lower(table_name) IN (${SCHEMA_NAMES});" 2>/dev/null
    ); then
        return 2
    fi

    if ! [[ "${SCHEMA_COUNT}" =~ ^[0-9]+$ ]]; then
        return 2
    fi

    if [ "${SCHEMA_COUNT}" -ne "${#REQUIRED_RELATIONS[@]}" ]; then
        return 1
    fi

    VALIDATION_SQL="SELECT CASE WHEN TRUE"
    for TABLE_NAME in "${REQUIRED_TABLE_ARRAY[@]}"; do
        VALIDATION_SQL+=" AND EXISTS (SELECT 1 FROM \"${TABLE_NAME}\")"
    done
    VALIDATION_SQL+=" THEN 1 ELSE 0 END;"

    if ! ROW_PRESENT=$(
        "${QUERY_PATH}/duckdb" \
            -c ".open ${DATABASE_PATH}" \
            -c ".mode list" \
            -c ".headers off" \
            -c "${VALIDATION_SQL}" 2>/dev/null
    ); then
        return 2
    fi

    [ "${ROW_PRESENT}" = "1" ]
}

DATASETS=(graph lsqb tpch job)
MISSING_DATASETS=()
TEMP_FILES=()
ACTIVE_REPLACEMENT_TARGET=
ACTIVE_REPLACEMENT_BACKUP=
ACTIVE_REPLACEMENT_BACKUP_WAL=
ACTIVE_REPLACEMENT_TARGET_MOVED=false
ACTIVE_REPLACEMENT_WAL_MOVED=false
ACTIVE_REPLACEMENT_NEW_INSTALLED=false

clear_active_replacement() {
    ACTIVE_REPLACEMENT_TARGET=
    ACTIVE_REPLACEMENT_BACKUP=
    ACTIVE_REPLACEMENT_BACKUP_WAL=
    ACTIVE_REPLACEMENT_TARGET_MOVED=false
    ACTIVE_REPLACEMENT_WAL_MOVED=false
    ACTIVE_REPLACEMENT_NEW_INSTALLED=false
}

restore_active_replacement() {
    if [ -z "${ACTIVE_REPLACEMENT_TARGET}" ]; then
        return
    fi

    if ${ACTIVE_REPLACEMENT_NEW_INSTALLED}; then
        rm -f \
            "${ACTIVE_REPLACEMENT_TARGET}" \
            "${ACTIVE_REPLACEMENT_TARGET}.wal" || true
    fi

    if ${ACTIVE_REPLACEMENT_TARGET_MOVED} && [ -f "${ACTIVE_REPLACEMENT_BACKUP}" ]; then
        mv -f \
            "${ACTIVE_REPLACEMENT_BACKUP}" \
            "${ACTIVE_REPLACEMENT_TARGET}" || true
    fi

    if ${ACTIVE_REPLACEMENT_WAL_MOVED} && [ -f "${ACTIVE_REPLACEMENT_BACKUP_WAL}" ]; then
        mv -f \
            "${ACTIVE_REPLACEMENT_BACKUP_WAL}" \
            "${ACTIVE_REPLACEMENT_TARGET}.wal" || true
    fi

    clear_active_replacement
}

cleanup_temp_files() {
    restore_active_replacement

    if [ "${#TEMP_FILES[@]}" -gt 0 ]; then
        rm -f "${TEMP_FILES[@]}"
    fi
}
trap cleanup_temp_files EXIT

install_database() {
    local NEW_DATABASE=$1
    local TARGET_DATABASE=$2
    local DATASET=$3
    local BACKUP_DATABASE
    local BACKUP_WAL

    BACKUP_DATABASE=$(mktemp "${QUERY_PATH}/.${DATASET}_backup.XXXXXX")
    rm -f "${BACKUP_DATABASE}"
    BACKUP_WAL="${BACKUP_DATABASE}.wal"

    ACTIVE_REPLACEMENT_TARGET="${TARGET_DATABASE}"
    ACTIVE_REPLACEMENT_BACKUP="${BACKUP_DATABASE}"
    ACTIVE_REPLACEMENT_BACKUP_WAL="${BACKUP_WAL}"

    if [ -f "${TARGET_DATABASE}" ]; then
        if ! mv -f "${TARGET_DATABASE}" "${BACKUP_DATABASE}"; then
            clear_active_replacement
            return 1
        fi
        ACTIVE_REPLACEMENT_TARGET_MOVED=true
    fi

    if [ -f "${TARGET_DATABASE}.wal" ]; then
        if ! mv -f "${TARGET_DATABASE}.wal" "${BACKUP_WAL}"; then
            restore_active_replacement
            return 1
        fi
        ACTIVE_REPLACEMENT_WAL_MOVED=true
    fi

    if ! mv -f "${NEW_DATABASE}" "${TARGET_DATABASE}"; then
        restore_active_replacement
        return 1
    fi
    ACTIVE_REPLACEMENT_NEW_INSTALLED=true

    if ! database_is_ready "${TARGET_DATABASE}" "${DATASET}"; then
        restore_active_replacement
        return 1
    fi

    clear_active_replacement
    rm -f "${BACKUP_DATABASE}" "${BACKUP_WAL}"
}

for DATASET in "${DATASETS[@]}"; do
    DATABASE_PATH="${QUERY_PATH}/${DATASET}_db"

    if database_is_ready "${DATABASE_PATH}" "${DATASET}"; then
        echo "Using existing ${DATASET} database: ${DATABASE_PATH}"
    else
        DATABASE_STATUS=$?
        if [ "${DATABASE_STATUS}" -eq 2 ]; then
            echo "Unable to inspect existing ${DATASET} database; it will not be modified: ${DATABASE_PATH}" >&2
            exit 1
        fi

        if [ -f "${DATABASE_PATH}" ]; then
            echo "Existing ${DATASET} database is incomplete and will be rebuilt: ${DATABASE_PATH}"
        else
            echo "Missing ${DATASET} database: ${DATABASE_PATH}"
        fi
        MISSING_DATASETS+=("${DATASET}")
    fi
done

if [ "${#MISSING_DATASETS[@]}" -eq 0 ]; then
    echo "All DuckDB databases are ready."
    echo "Skipping dataset download and DuckDB data loading."
else
    echo "Preparing data for missing or incomplete database(s): ${MISSING_DATASETS[*]}"
    cd "${ROOT_PATH}"
    bash scripts/download_data.sh \
        "$LSQB_SCALE" \
        "$TPCH_SCALE" \
        "${MISSING_DATASETS[@]}"

    echo "Loading data into DuckDB..."
    for DATASET in "${MISSING_DATASETS[@]}"; do
        SQL_TEMPLATE="${ROOT_PATH}/scripts/load_${DATASET}_default.sql"
        DATA_PATH="${ROOT_PATH}/Data/${DATASET}"
        DATABASE_PATH="${QUERY_PATH}/${DATASET}_db"
        TEMP_SQL=$(mktemp)
        TEMP_DATABASE=$(mktemp "${QUERY_PATH}/.${DATASET}_db.XXXXXX")
        rm -f "${TEMP_DATABASE}"
        TEMP_FILES+=("${TEMP_SQL}" "${TEMP_DATABASE}" "${TEMP_DATABASE}.wal")

        case "${DATASET}" in
            graph) DATA_PLACEHOLDER=/PATH_TO_GRAPH_DATA ;;
            lsqb) DATA_PLACEHOLDER=/PATH_TO_LSQB_DATA ;;
            tpch) DATA_PLACEHOLDER=/PATH_TO_TPCH_DATA ;;
            job) DATA_PLACEHOLDER=/PATH_TO_JOB_DATA ;;
        esac

        sed "s|${DATA_PLACEHOLDER}|${DATA_PATH}|g" \
            "${SQL_TEMPLATE}" > "${TEMP_SQL}"

        MISSING_DATA_FILES=false
        while IFS= read -r DATA_FILE; do
            if [ ! -s "${DATA_FILE}" ]; then
                echo "Missing or empty DuckDB input file: ${DATA_FILE}" >&2
                MISSING_DATA_FILES=true
            fi
        done < <(grep -hoE "'/[^']+'" "${TEMP_SQL}" | tr -d "'" | sort -u)

        if ${MISSING_DATA_FILES}; then
            echo "Dataset preparation for ${DATASET} is incomplete." >&2
            exit 1
        fi

        echo "Loading ${DATASET}: ${DATABASE_PATH}"
        if ! "${QUERY_PATH}/duckdb" \
            -c ".open ${TEMP_DATABASE}" \
            -c ".read ${TEMP_SQL}"; then
            echo "DuckDB loading failed for ${DATASET}; existing databases were preserved." >&2
            exit 1
        fi

        if ! "${QUERY_PATH}/duckdb" \
            -c ".open ${TEMP_DATABASE}" \
            -c "CHECKPOINT;"; then
            echo "DuckDB checkpoint failed for ${DATASET}; existing databases were preserved." >&2
            exit 1
        fi

        if [ -f "${TEMP_DATABASE}.wal" ]; then
            echo "DuckDB left an uncheckpointed WAL for ${DATASET}; existing databases were preserved." >&2
            exit 1
        fi

        if ! database_is_ready "${TEMP_DATABASE}" "${DATASET}"; then
            echo "DuckDB validation failed for ${DATASET}; existing databases were preserved." >&2
            exit 1
        fi

        if ! install_database "${TEMP_DATABASE}" "${DATABASE_PATH}" "${DATASET}"; then
            echo "Could not install the rebuilt ${DATASET} database; the previous database was restored." >&2
            exit 1
        fi

        rm -f "${TEMP_SQL}"
        echo "Ready: ${DATABASE_PATH}"
    done
fi

for DATASET in "${DATASETS[@]}"; do
    DATABASE_PATH="${QUERY_PATH}/${DATASET}_db"
    if ! database_is_ready "${DATABASE_PATH}" "${DATASET}"; then
        echo "DuckDB database is unavailable or incomplete: ${DATABASE_PATH}" >&2
        exit 1
    fi
done

cd "${QUERY_PATH}"
bash auto_run_duckdb_batch.sh

echo "Generating summary statistics..."
cd "${QUERY_PATH}"
# rm -f summary_*.csv
bash auto_summary.sh graph
bash auto_summary.sh lsqb
bash auto_summary.sh tpch
bash auto_summary_job.sh job
