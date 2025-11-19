DATA_PATH="${1:-../Data/graph}"
QUERY_PATH="${2:-./Query_graph}"
SCHEMA="${3:-epinionsSchema}"

bash ExecuteQuery.sh "${DATA_PATH}" "${QUERY_PATH}" "${SCHEMA}" txt 4