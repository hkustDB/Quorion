DATA_PATH="${1:-../Data/job}"
QUERY_PATH="${2:-./Query_job}"

bash ExecuteQuery.sh "${DATA_PATH}" "${QUERY_PATH}" jobSchema csv 4
