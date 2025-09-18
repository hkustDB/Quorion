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

INPUT_DIR=$1
INPUT_DIR_PATH="${SCRIPT_PATH}/${INPUT_DIR}"
OUTPUT_FILE="${SCRIPT_PATH}/summary_${INPUT_DIR}_statistics.csv"

# Create output file with header
echo "Query,DuckDB native,DuckDB Yannakakis,DuckDB rewrite,PostgreSQL native,PG_RewrPostgreSQL Yannakakisite_Min,PostgreSQL rewrite" > $OUTPUT_FILE

# Function to extract AVG time from log file
extract_avg_time() {
    local log_file="$1"
    if [[ -f "$log_file" ]]; then
        # Get the last line that contains "AVG" and extract the numeric value
        local avg_line=$(grep "AVG" "$log_file" | tail -1)
        if [[ -n "$avg_line" ]]; then
            # Extract numeric value after "AVG"
            echo "$avg_line" | awk '{print $2}'
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Function to find minimum time from a set of log files
find_min_time() {
    local files="$1"
    local min_time="999999"
    
    if [[ -n "$files" ]]; then
        for file in $files; do
            time=$(extract_avg_time "$file")
            if (( $(echo "$time > 0 && $time < $min_time" | bc -l) )); then
                min_time="$time"
            fi
        done
        if [[ "$min_time" == "999999" ]]; then
            echo "0"
        else
            echo "$min_time"
        fi
    else
        echo "0"
    fi
}

dirs=$(find ${INPUT_DIR} -mindepth 1 -maxdepth 1 -type d | sort -V)

for dir in $dirs;
do
    if [ "$dir" != "${INPUT_DIR}" ]; then
        query_name=$(basename "$dir")
        echo "Processing query: $query_name"
        
        # DuckDB files
        duckdb_query_log="${dir}/log_query_duckdb.txt"
        duckdb_query_time=$(extract_avg_time "$duckdb_query_log")

        # DuckDB rewriteYa files
        duckdb_rewriteya_files=$(find "$dir" -name "log_rewriteYa*_duckdb.txt" 2>/dev/null)
        duckdb_rewriteya_min=$(find_min_time "$duckdb_rewriteya_files")
        
        # DuckDB rewrite files (excluding Ya files)
        duckdb_rewrite_files=$(find "$dir" -name "log_rewrite*_duckdb.txt" ! -name "*Ya*" 2>/dev/null)
        duckdb_rewrite_min=$(find_min_time "$duckdb_rewrite_files")
        
        # PostgreSQL files
        pg_query_log="${dir}/log_query_pg.txt"
        pg_query_time=$(extract_avg_time "$pg_query_log")

        # PostgreSQL rewriteYa files
        pg_rewriteya_files=$(find "$dir" -name "log_rewriteYa*_pg.txt" 2>/dev/null)
        pg_rewriteya_min=$(find_min_time "$pg_rewriteya_files")
        
        # PostgreSQL rewrite files (excluding Ya files)
        pg_rewrite_files=$(find "$dir" -name "log_rewrite*_pg.txt" ! -name "*Ya*" 2>/dev/null)
        pg_rewrite_min=$(find_min_time "$pg_rewrite_files")
        
        # Output to CSV
        echo "$query_name,$duckdb_query_time,$duckdb_rewriteya_min,$duckdb_rewrite_min,$pg_query_time,$pg_rewriteya_min,$pg_rewrite_min" >> $OUTPUT_FILE
        
        echo "  DuckDB Query: $duckdb_query_time"
        echo "  DuckDB Rewrite Min: $duckdb_rewrite_min"
        echo "  DuckDB RewriteYa Min: $duckdb_rewriteya_min"
        echo "  PG Query: $pg_query_time"
        echo "  PG Rewrite Min: $pg_rewrite_min"
        echo "  PG RewriteYa Min: $pg_rewriteya_min"
        echo "---"
    fi
done

echo "Summary statistics saved to $OUTPUT_FILE"