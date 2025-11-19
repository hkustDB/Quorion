DATA_PATH="${1:-../Data/tpch}"
QUERY_PATH="${2:-./Query_tpch}"

bash ExecuteQuery.sh "${DATA_PATH}" "${QUERY_PATH}" tpchSchema tbl 4