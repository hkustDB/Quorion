#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
QUERY_DIR="$PARENT_DIR/query"

source "$PARENT_DIR/query/common.sh"

# Read configuration from config.properties
config_files=("${QUERY_DIR}/config.properties")
pg_path=$(prop ${config_files} "pg.path")
pg_db=$(prop ${config_files} "pg.db")
pg_port=$(prop ${config_files} "pg.port")

# Ensure query directory exists
mkdir -p "$QUERY_DIR"

echo "Loading data into PostgreSQL database..."
echo "Script directory: $SCRIPT_DIR"
echo "Query directory: $QUERY_DIR"
echo "PostgreSQL path: $pg_path"
echo "Database: $pg_db"
echo "Port: $pg_port"
echo ""

# Find all load_*_pg.sql files in the scripts directory
find "$SCRIPT_DIR" -name "load_*_pg.sql" -type f | while read -r sql_file; do
    filename=$(basename "$sql_file")
    
    # Skip files with "default" in the name
    if [[ "$filename" == *"default"* ]]; then
        echo "Skipping: $filename (contains 'default')"
        continue
    fi
    
    # Extract dataset name (e.g., load_tpch_pg.sql -> tpch)
    if [[ "$filename" =~ ^load_(.*)_pg\.sql$ ]]; then
        dataset_name="${BASH_REMATCH[1]}"
    else
        echo "Warning: Could not extract dataset name from $filename"
        continue
    fi
    
    echo "Processing: $filename"
    echo "  Dataset: $dataset_name"
    echo "  SQL file: $sql_file"
    echo "  Target database: $pg_db"
    
    # Execute SQL file in PostgreSQL
    echo "  Loading data into PostgreSQL..."
    $pg_path "-d" "${pg_db}" "-p" "${pg_port}" "-f" "${sql_file}"
    
    if [ $? -eq 0 ]; then
        echo "  ✅ Successfully loaded $dataset_name data into $pg_db"
    else
        echo "  ❌ Failed to load $dataset_name data into $pg_db"
    fi
    
    echo ""
done

echo "PostgreSQL data loading completed!"
echo ""
echo "All data loaded into database: $pg_db"