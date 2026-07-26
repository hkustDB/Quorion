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

shopt -s nullglob
EXISTING_DATABASES=()
for DATABASE_PATH in "${QUERY_PATH}"/*_db; do
    if [ -f "${DATABASE_PATH}" ]; then
        EXISTING_DATABASES+=("${DATABASE_PATH}")
    fi
done
shopt -u nullglob

if [ "${#EXISTING_DATABASES[@]}" -gt 0 ]; then
    echo "Found existing DuckDB database(s) under ${QUERY_PATH}:"
    printf '  %s\n' "${EXISTING_DATABASES[@]}"
    echo "Skipping dataset download and DuckDB data loading."
else
    echo "Downloading dataset..."
    rm -rf "${ROOT_PATH}/Data"
    cd "${ROOT_PATH}"
    bash scripts/download_data.sh "$LSQB_SCALE" "$TPCH_SCALE"

    echo "Initializing DuckDB data paths..."
    bash scripts/update_paths.sh

    LOAD_SQL_FILES=("${ROOT_PATH}"/scripts/load_*_duckdb.sql)
    MISSING_DATA_FILES=false

    echo "Verifying downloaded data files..."
    for SQL_FILE in "${LOAD_SQL_FILES[@]}"; do
        while IFS= read -r DATA_FILE; do
            if [ ! -f "${DATA_FILE}" ]; then
                echo "Missing DuckDB input file: ${DATA_FILE}" >&2
                MISSING_DATA_FILES=true
            fi
        done < <(grep -hoE "'/[^']+'" "${SQL_FILE}" | tr -d "'" | sort -u)
    done

    if ${MISSING_DATA_FILES}; then
        echo "Dataset preparation did not produce all required DuckDB input files." >&2
        exit 1
    fi

    echo "Loading data into DuckDB..."
    CREATED_DATABASES=()
    for SQL_FILE in "${LOAD_SQL_FILES[@]}"; do
        SQL_FILENAME=$(basename "${SQL_FILE}")
        DATASET=${SQL_FILENAME#load_}
        DATASET=${DATASET%_duckdb.sql}
        DATABASE_PATH="${QUERY_PATH}/${DATASET}_db"

        echo "Loading ${DATASET}: ${DATABASE_PATH}"
        if ! "${QUERY_PATH}/duckdb" \
            -c ".open ${DATABASE_PATH}" \
            -c ".read ${SQL_FILE}"; then
            rm -f "${DATABASE_PATH}"
            if [ "${#CREATED_DATABASES[@]}" -gt 0 ]; then
                rm -f "${CREATED_DATABASES[@]}"
            fi
            echo "DuckDB loading failed; removed databases created by this run." >&2
            exit 1
        fi
        CREATED_DATABASES+=("${DATABASE_PATH}")
    done
fi

cd "${QUERY_PATH}"
bash auto_run_duckdb_batch.sh
