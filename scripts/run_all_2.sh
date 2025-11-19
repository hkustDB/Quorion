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

cd "${ROOT_PATH}"
bash scripts/run_spark.sh

bash auto_summary.sh graph
bash auto_summary.sh lsqb
bash auto_summary.sh tpch
bash auto_summary_job.sh job

cd "${ROOT_PATH}/draw"
${PYTHON_BIN} draw_graph.py
${PYTHON_BIN} draw_job.py
${PYTHON_BIN} draw_selectivity.py
${PYTHON_BIN} draw_thread.py
