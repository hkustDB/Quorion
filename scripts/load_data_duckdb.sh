#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
QUERY_DIR="$PARENT_DIR/query"

source "$PARENT_DIR/query/common.sh"

config_files=("${QUERY_DIR}/config.properties")
repeat_count=$(prop ${config_files} "common.experiment.repeat")
timeout_time=$(prop ${config_files} 'common.experiment.timeout')
duckdb=$(prop ${config_files} "duckdb.path")

# Ensure query directory exists
mkdir -p "$QUERY_DIR"

echo "Loading data into DuckDB databases..."
echo "Script directory: $SCRIPT_DIR"
echo "Query directory: $QUERY_DIR"
echo ""

# Find all load_*_duckdb.sql files in the scripts directory
find "$SCRIPT_DIR" -name "load_*_duckdb.sql" -type f | while read -r sql_file; do
    filename=$(basename "$sql_file")
    
    # Skip files with "default" in the name
    if [[ "$filename" == *"default"* ]]; then
        echo "Skipping: $filename (contains 'default')"
        continue
    fi
    
    # Extract dataset name (e.g., load_tpch_duckdb.sql -> tpch)
    if [[ "$filename" =~ ^load_(.*)_duckdb\.sql$ ]]; then
        dataset_name="${BASH_REMATCH[1]}"
    else
        echo "Warning: Could not extract dataset name from $filename"
        continue
    fi
    
    # Define database file path
    db_file="$QUERY_DIR/${dataset_name}_db"
    
    echo "Processing: $filename"
    echo "  Dataset: $dataset_name"
    echo "  Database file: $db_file"
    echo "  SQL file: $sql_file"
    
    # Remove existing database file if it exists
    if [ -f "$db_file" ]; then
        echo "  Removing existing database: $db_file"
        rm "$db_file"
    fi
    
    # Create database and load data
    echo "  Creating database and loading data..."
    $duckdb -c ".open $db_file" -c ".read $sql_file"
    
    if [ $? -eq 0 ]; then
        echo "  ✅ Successfully created: $db_file"
    else
        echo "  ❌ Failed to create: $db_file"
    fi
    echo ""
done

echo "Database creation completed!"
echo ""
echo "Created databases in: $QUERY_DIR"
ls -la "$QUERY_DIR"/*_db 2>/dev/null || echo "No database files found"