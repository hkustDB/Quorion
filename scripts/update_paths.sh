#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define paths - script is in scripts/, data is in Data/
PARENT_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="$PARENT_DIR/Data"

# Check if directories exist
if [ ! -d "$SCRIPT_DIR" ]; then
    echo "Error: scripts directory not found at $SCRIPT_DIR"
    exit 1
fi

if [ ! -d "$DATA_DIR" ]; then
    echo "Error: Data directory not found at $DATA_DIR"
    exit 1
fi

# Function to determine the correct data subdirectory based on the SQL file
# Function to determine the correct data subdirectory based on the SQL file
get_data_subdir() {
    local sql_file="$1"
    local filename=$(basename "$sql_file")
    
    # Use pattern matching with [[ ]] instead of case
    if [[ "$filename" =~ ^load_(.*)_(duckdb|pg)\.sql$ ]]; then
        # Extract the dataset name using BASH_REMATCH
        echo "${BASH_REMATCH[1]}"
    elif [[ "$filename" =~ ^load_(.*)\.sql$ ]]; then
        # Handle files like load_graph.sql -> graph
        echo "${BASH_REMATCH[1]}"
    else
        echo "unknown"
    fi
}

# Function to get the database type (duckdb or pg)
get_db_type() {
    local sql_file="$1"
    local filename=$(basename "$sql_file")
    
    if [[ "$filename" == *_duckdb.sql ]]; then
        echo "duckdb"
    elif [[ "$filename" == *_pg.sql ]]; then
        echo "pg"
    else
        echo "generic"
    fi
}

# Function to get the appropriate path placeholder based on dataset and db type
get_path_placeholder() {
    local dataset="$1"
    local db_type="$2"
    
    case "$dataset" in
        job)
            echo "/PATH_TO_JOB_DATA"
            ;;
        tpch)
            echo "/PATH_TO_TPCH_DATA"
            ;;
        graph)
            echo "/PATH_TO_GRAPH_DATA"
            ;;
        lsqb)
            echo "/PATH_TO_LSQB_DATA"
            ;;
        *)
            # For other datasets, use tr to convert to uppercase
            local dataset_upper=$(echo "$dataset" | tr '[:lower:]' '[:upper:]')
            echo "/PATH_TO_${dataset_upper}_DATA"
            ;;
    esac
}

# Find all load_*.sql files in query directory and subdirectories
processed_count=0
duckdb_count=0
pg_count=0

echo "Starting to update load_*.sql files in $SCRIPT_DIR ..."

find "$SCRIPT_DIR" -name "load_*.sql" -type f | while read -r sql_file; do
    filename=$(basename "$sql_file")
    
    # Skip files with "default" in the name
    if [[ "$filename" == *"default"* ]]; then
        echo "Skipping: $sql_file (contains 'default')"
        continue
    fi
    echo "Processing: $sql_file"
    
    # Determine the appropriate data subdirectory and database type
    data_subdir=$(get_data_subdir "$sql_file")
    echo "  Detected subdir: $data_subdir"
    db_type=$(get_db_type "$sql_file")
    target_data_dir="$DATA_DIR/$data_subdir"
    
    # Check if the target data directory exists
    if [ ! -d "$target_data_dir" ]; then
        echo "  ⚠ Warning: Data subdirectory not found: $target_data_dir"
        echo "  Creating directory: $target_data_dir"
        mkdir -p "$target_data_dir"
    fi
    
    # Replace ONLY the specific path pattern for this dataset
    case "$data_subdir" in
        job)
            sed "s|/PATH_TO_JOB_DATA|$target_data_dir|g" "$sql_file" > "$sql_file.new" && mv "$sql_file.new" "$sql_file"
            ;;
        tpch)
            sed "s|/PATH_TO_TPCH_DATA|$target_data_dir|g" "$sql_file" > "$sql_file.new" && mv "$sql_file.new" "$sql_file"
            ;;
        graph)
            sed "s|/PATH_TO_GRAPH_DATA|$target_data_dir|g" "$sql_file" > "$sql_file.new" && mv "$sql_file.new" "$sql_file"
            ;;
        lsqb)
            sed "s|/PATH_TO_LSQB_DATA|$target_data_dir|g" "$sql_file" > "$sql_file.new" && mv "$sql_file.new" "$sql_file"
            ;;
        *)
            path_placeholder=$(get_path_placeholder "$data_subdir" "$db_type")
            sed "s|$path_placeholder|$target_data_dir|g" "$sql_file" > "$sql_file.new" && mv "$sql_file.new" "$sql_file"
            ;;
    esac
    
    # Remove the temporary file created by sed
    rm "$sql_file.tmp" 2>/dev/null || true
    
    echo "  ✓ Updated paths to use: $target_data_dir ($db_type version)"
    
    # Count by database type
    case "$db_type" in
        duckdb) duckdb_count=$((duckdb_count + 1)) ;;
        pg) pg_count=$((pg_count + 1)) ;;
    esac
    
    processed_count=$((processed_count + 1))
done

echo ""
echo "Successfully updated all load_*.sql files"
echo "Data directories used under: $DATA_DIR"

# Show summary of processed files
echo ""
echo "Summary:"
echo "Total files processed: $processed_count"
echo "DuckDB files: $duckdb_count"
echo "PostgreSQL files: $pg_count"
echo "Generic files: $((processed_count - duckdb_count - pg_count))"

# Show the expected directory structure
echo ""
echo "Expected data directory structure:"
echo "$DATA_DIR/"
echo "├── job/          (for load_job_[duckdb|pg].sql files)"
echo "├── tpch/         (for load_tpch_[duckdb|pg].sql files)"
echo "├── graph/        (for load_graph_[duckdb|pg].sql files)"
echo "├── lsqb/         (for load_lsqb_[duckdb|pg].sql files)"
echo "└── [dataset]/    (for other load_[dataset]_[duckdb|pg].sql files)"

# Show examples of supported file patterns
echo ""
echo "Supported file naming patterns:"
echo "├── load_job_duckdb.sql    → Data/job/"
echo "├── load_job_pg.sql        → Data/job/"
echo "├── load_tpch_duckdb.sql   → Data/tpch/"
echo "├── load_tpch_pg.sql       → Data/tpch/"
echo "├── load_graph_duckdb.sql  → Data/graph/"
echo "├── load_graph_pg.sql      → Data/graph/"
echo "├── load_lsqb_duckdb.sql   → Data/lsqb/"
echo "└── load_lsqb_pg.sql       → Data/lsqb/"