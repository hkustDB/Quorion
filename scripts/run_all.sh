#!/bin/bash

CURRENT_SCRIPT=$(readlink -f $0)
CURRENT_PATH=$(dirname "${CURRENT_SCRIPT}")
ROOT_PATH=$(dirname "${CURRENT_PATH}")
QUERY_PATH="${ROOT_PATH}/query"
PG_PATH="${ROOT_PATH}/postgres"

echo "Downloading DuckDB..."
cd "${QUERY_PATH}"
rm -rf "${QUERY_PATH}/duckdb_cli-*"
wget https://github.com/duckdb/duckdb/releases/download/v1.0.0/duckdb_cli-linux-amd64.zip
unzip duckdb_cli-*.zip

echo "Downloading postgresql..."
mkdir -p "${PG_PATH}"
cd "${PG_PATH}"
rm -rf postgresql-16.2.tar.gz
rm -rf postgresql-16.2

wget https://ftp.postgresql.org/pub/source/v16.2/postgresql-16.2.tar.gz
tar -xvzf postgresql-16.2.tar.gz
cd "${PG_PATH}/postgresql-16.2"

./configure "--prefix=${PG_PATH}/postgresql"
make -j
make install
mkdir "${PG_PATH}/postgresql/data"

"${PG_PATH}/postgresql/bin/initdb" -D "${PG_PATH}/postgresql/data" -E UTF8 --locale=C -U postgres
"${PG_PATH}/postgresql/bin/pg_ctl" -D "${PG_PATH}/postgresql/data" -l logfile start
"${PG_PATH}/postgresql/bin/createdb" -U postgres test

echo "Installing postgresql extension..."
cd "${PG_PATH}/postgres/contrib/file_fdw"
make
make install
"${PG_PATH}/postgresql/bin/pg_ctl" -D "${PG_PATH}/postgresql/data" stop
"${PG_PATH}/postgresql/bin/pg_ctl" -D "${PG_PATH}/postgresql/data" start
"${PG_PATH}/postgresql/bin/psql" -U postgres -d test -c "CREATE EXTENSION file_fdw;"

echo "Downloading dataset..."
cd "${ROOT_PATH}"
bash scripts/download_data.sh 1 1

echo "Initializing database..."
cd "${ROOT_PATH}"
bash scripts/update_paths.sh

echo "" >> "${QUERY_PATH}/config.properties"
echo "duckdb.path=${QUERY_PATH}/duckdb" >> "${QUERY_PATH}/config.properties"
echo "" >> "${QUERY_PATH}/config.properties"
echo "pg.path=${PG_PATH}/postgresql/bin/psql" >> "${QUERY_PATH}/config.properties"
echo "" >> "${QUERY_PATH}/config.properties"
echo "parser.home=${ROOT_PATH}/SparkSQLPlus" >> "${QUERY_PATH}/config.properties"
echo "" >> "${QUERY_PATH}/config.properties"

bash scripts/load_data_duckdb.sh
bash scripts/load_data_pg.sh

echo "Generating rewritten queries..."
cd "${ROOT_PATH}"
rm -rf sparksql-plus-web-jar-with-dependencies.jar
git submodule init
git submodule update
cd SparkSQLPlus
mvn clean package
cp sqlplus-web/target/sparksql-plus-web-jar-with-dependencies.jar ../

cd "${ROOT_PATH}"
bash scripts/start_parser.sh
python main.py
./auto_rewrite.sh graph graph_duckdb D N
./auto_rewrite.sh graph graph_pg M N
./auto_rewrite.sh lsqb lsqb D N
./auto_rewrite.sh tpch tpch D N
./auto_rewrite.sh job job D N

cd "${QUERY_PATH}"
bash auto_run_duckdb_batch.sh
bash auto_run_pg_batch.sh
bash auto_run_duckdb.sh parallelism_lsqb 1
bash auto_run_duckdb.sh parallelism_lsqb 2
bash auto_run_duckdb.sh parallelism_lsqb 4
bash auto_run_duckdb.sh parallelism_lsqb 8
bash auto_run_duckdb.sh parallelism_lsqb 16
bash auto_run_duckdb.sh parallelism_lsqb 32
bash auto_run_duckdb.sh parallelism_lsqb 48
bash auto_run_duckdb.sh parallelism_sgpb 1
bash auto_run_duckdb.sh parallelism_sgpb 2
bash auto_run_duckdb.sh parallelism_sgpb 4
bash auto_run_duckdb.sh parallelism_sgpb 8
bash auto_run_duckdb.sh parallelism_sgpb 16
bash auto_run_duckdb.sh parallelism_sgpb 32
bash auto_run_duckdb.sh parallelism_sgpb 48

bash auto_summary.sh graph
bash auto_summary.sh lsqb
bash auto_summary.sh tpch
bash auto_summary_job.sh job

cd "${ROOT_PATH}/draw"
python3 draw_graph.py
python3 draw_job.py
python3 draw_selectivity.py
python3 draw_thread.py
