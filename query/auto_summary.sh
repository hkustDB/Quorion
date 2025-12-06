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

INPUT_NAME=$1
# Define separate paths for DuckDB and PG
DUCKDB_DIR_PATH="${SCRIPT_PATH}/${INPUT_NAME}_duckdb"
PG_DIR_PATH="${SCRIPT_PATH}/${INPUT_NAME}_pg"

OUTPUT_FILE="${SCRIPT_PATH}/summary_${INPUT_NAME}_statistics.csv"
SPARK_CSV="${SCRIPT_PATH}/../SparkSQLRunner/log/${INPUT_NAME}.csv"

echo "Generating SPARK_CSV statistics from ${SPARK_CSV}..."

# Read Spark results into associative arrays
declare -A spark_native
declare -A spark_yannakakis
declare -A spark_rewrite

if [[ -f "$SPARK_CSV" ]]; then
    while IFS=',' read -r query time; do
        time=${time//$'\r'/}
        [[ "$query" == "Query" ]] && continue
        if [[ "$query" =~ ^(.*)_y($|_) ]]; then
            base="${BASH_REMATCH[1]}"
            spark_yannakakis["$base"]="$time"
        elif [[ "$query" =~ ^(.*)_r[0-9]*($|_) ]]; then
            base="${BASH_REMATCH[1]}"
            spark_rewrite["$base"]="$time"
        else
            spark_native["$query"]="$time"
        fi
    done < "$SPARK_CSV"
fi

# Update header to include Spark columns
echo "Query,DuckDB native,DuckDB Yannakakis,DuckDB rewrite,PostgreSQL native,PostgreSQL Yannakakis,PostgreSQL rewrite,Spark native,Spark Yannakakis,Spark rewrite" > $OUTPUT_FILE

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
            # Use awk instead of bc for floating point comparison
            if [ $(awk -v t="$time" -v m="$min_time" 'BEGIN {print (t > 0 && t < m) ? 1 : 0}') -eq 1 ]; then
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

# Get list of all unique query names from both directories
# We look for subdirectories in both locations and take the basename
queries=$( { 
    [ -d "$DUCKDB_DIR_PATH" ] && find "$DUCKDB_DIR_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"; 
    [ -d "$PG_DIR_PATH" ] && find "$PG_DIR_PATH" -mindepth 1 -maxdepth 1 -type d -printf "%f\n"; 
} | sort -V | uniq )

for query_name in $queries;
do
    echo "Processing query: $query_name"
    
    # Construct paths for this specific query
    duckdb_query_dir="${DUCKDB_DIR_PATH}/${query_name}"
    pg_query_dir="${PG_DIR_PATH}/${query_name}"

    # --- DuckDB Processing ---
    if [ -d "$duckdb_query_dir" ]; then
        duckdb_query_log="${duckdb_query_dir}/log_query_duckdb.txt"
        duckdb_query_time=$(extract_avg_time "$duckdb_query_log")

        duckdb_rewriteya_files=$(find "$duckdb_query_dir" -name "log_rewriteYa*_duckdb.txt" 2>/dev/null)
        duckdb_rewriteya_min=$(find_min_time "$duckdb_rewriteya_files")
        
        duckdb_rewrite_files=$(find "$duckdb_query_dir" -name "log_rewrite*_duckdb.txt" ! -name "*Ya*" 2>/dev/null)
        duckdb_rewrite_min=$(find_min_time "$duckdb_rewrite_files")
    else
        duckdb_query_time="0"
        duckdb_rewriteya_min="0"
        duckdb_rewrite_min="0"
    fi
    
    # --- PostgreSQL Processing ---
    if [ -d "$pg_query_dir" ]; then
        pg_query_log="${pg_query_dir}/log_query_pg.txt"
        pg_query_time=$(extract_avg_time "$pg_query_log")

        pg_rewriteya_files=$(find "$pg_query_dir" -name "log_rewriteYa*_pg.txt" 2>/dev/null)
        pg_rewriteya_min=$(find_min_time "$pg_rewriteya_files")
        
        pg_rewrite_files=$(find "$pg_query_dir" -name "log_rewrite*_pg.txt" ! -name "*Ya*" 2>/dev/null)
        pg_rewrite_min=$(find_min_time "$pg_rewrite_files")
    else
        pg_query_time="0"
        pg_rewriteya_min="0"
        pg_rewrite_min="0"
    fi

    # Output to CSV
    spark_native_time="${spark_native[$query_name]:-0}"
    spark_yannakakis_time="${spark_yannakakis[$query_name]:-0}"
    spark_rewrite_time="${spark_rewrite[$query_name]:-0}"

    echo "$query_name,$duckdb_query_time,$duckdb_rewriteya_min,$duckdb_rewrite_min,$pg_query_time,$pg_rewriteya_min,$pg_rewrite_min,$spark_native_time,$spark_yannakakis_time,$spark_rewrite_time" >> $OUTPUT_FILE
done

echo "Summary statistics saved to $OUTPUT_FILE"