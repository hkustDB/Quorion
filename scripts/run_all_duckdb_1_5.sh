#!/bin/bash

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

echo "Downloading dataset..."
rm -rf "${ROOT_PATH}/Data"
cd "${ROOT_PATH}"
bash scripts/download_data.sh "$LSQB_SCALE" "$TPCH_SCALE"

echo "Initializing DuckDB..."
bash scripts/update_paths.sh

echo "" >> "${QUERY_PATH}/config.properties"
echo "duckdb.path=${QUERY_PATH}/duckdb" >> "${QUERY_PATH}/config.properties"
echo "" >> "${QUERY_PATH}/config.properties"
echo "parser.home=${ROOT_PATH}/SparkSQLPlus" >> "${QUERY_PATH}/config.properties"
echo "" >> "${QUERY_PATH}/config.properties"

bash scripts/load_data_duckdb.sh

cd "${QUERY_PATH}"
bash auto_run_duckdb_batch.sh
