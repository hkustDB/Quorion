#!/bin/bash

CURRENT_SCRIPT=$(readlink -f $0)
CURRENT_PATH=$(dirname "${CURRENT_SCRIPT}")
ROOT_PATH=$(dirname "${CURRENT_PATH}")
QUERY_PATH="${ROOT_PATH}/query"
PG_PATH="${ROOT_PATH}/postgres"

# Source common functions to read config
source "${QUERY_PATH}/common.sh"

# Read Python path from config
config_files=("${QUERY_PATH}/config.properties")
PYTHON_BIN=$(prop ${config_files} "python3.bin")

echo "Downloading DuckDB..."
cd "${QUERY_PATH}"
rm -rf "${QUERY_PATH}/duckdb_cli-*"
rm -f "${QUERY_PATH}/duckdb"
wget https://github.com/duckdb/duckdb/releases/download/v1.0.0/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-*.zip
rm -f duckdb_cli-*.zip

echo "Downloading postgresql..."
mkdir -p "${PG_PATH}"
cd "${PG_PATH}"
rm -f postgresql-16.2.tar.gz
rm -rf postgresql-16.2
rm -rf postgresql

wget https://ftp.postgresql.org/pub/source/v16.2/postgresql-16.2.tar.gz
tar -xvzf postgresql-16.2.tar.gz
rm -f postgresql-16.2.tar.gz
cd "${PG_PATH}/postgresql-16.2"

./configure "--prefix=${PG_PATH}/postgresql"
make -j
make install
mkdir "${PG_PATH}/postgresql/data"

"${PG_PATH}/postgresql/bin/initdb" -D "${PG_PATH}/postgresql/data" -E UTF8 --locale=C -U postgres
"${PG_PATH}/postgresql/bin/pg_ctl" -D "${PG_PATH}/postgresql/data" -l logfile start
"${PG_PATH}/postgresql/bin/createdb" -U postgres test

echo "Installing postgresql extension..."
cd "${PG_PATH}/postgresql/contrib/file_fdw"
make
make install
"${PG_PATH}/postgresql/bin/pg_ctl" -D "${PG_PATH}/postgresql/data" stop
"${PG_PATH}/postgresql/bin/pg_ctl" -D "${PG_PATH}/postgresql/data" start
"${PG_PATH}/postgresql/bin/psql" -U postgres -d test -c "CREATE EXTENSION file_fdw;"

echo "Downloading dataset..."
rm -rf "${ROOT_PATH}/Data"
cd "${ROOT_PATH}"
bash scripts/download_data.sh 1 1
