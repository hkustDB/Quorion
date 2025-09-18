#!/bin/bash

# Get the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Define paths
QUERY_DIR="$SCRIPT_DIR/query"
DATA_DIR="$SCRIPT_DIR/Data"

# Check if directories exist
if [ ! -d "$QUERY_DIR" ]; then
    echo "Error: query directory not found at $QUERY_DIR"
    exit 1
fi

if [ ! -d "$DATA_DIR" ]; then
    echo "Error: Data directory not found at $DATA_DIR"
    exit 1
fi

# Function to determine the correct data subdirectory based on the SQL file
get_data_subdir() {
    local sql_file="$1"
    local filename=$(basename "$sql_file")
    
    case "$filename" in
        load_job.sql)
            echo "job"
            ;;
        load_tpch.sql)
            echo "tpch"
            ;;
        load_graph.sql)
            echo "graph"
            ;;
        load_lsqb.sql)
            echo "lsqb"
            ;;
        load_*.sql)
            # Extract the dataset name from filename (e.g., load_dataset.sql -> dataset)
            echo "${filename#load_}" | sed 's/.sql$//'
            ;;
        *)
            echo "unknown"
            ;;
    esac
}

# Find all load_*.sql files in query directory and subdirectories
processed_count=0
find "$QUERY_DIR" -name "load_*.sql" -type f | while read -r sql_file; do
    echo "Processing: $sql_file"
    
    # Determine the appropriate data subdirectory
    data_subdir=$(get_data_subdir "$sql_file")
    target_data_dir="$DATA_DIR/$data_subdir"
    
    # Check if the target data directory exists
    if [ ! -d "$target_data_dir" ]; then
        echo "  ⚠ Warning: Data subdirectory not found: $target_data_dir"
        echo "  Using base data directory: $DATA_DIR"
        target_data_dir="$DATA_DIR"
    fi
    
    # Create a backup of the original file
    cp "$sql_file" "$sql_file.backup"
    
    # Replace various path patterns with the appropriate data directory
    sed -i.tmp "s|/PATH_TO_JOB_DATA|$target_data_dir|g" "$sql_file"
    sed -i.tmp "s|/PATH_TO_TPCH_DATA|$target_data_dir|g" "$sql_file"
    sed -i.tmp "s|/PATH_TO_GRAPH_DATA|$target_data_dir|g" "$sql_file"
    sed -i.tmp "s|/PATH_TO_LSQB_DATA|$target_data_dir|g" "$sql_file"
    
    # Remove the temporary file created by sed
    rm "$sql_file.tmp" 2>/dev/null || true
    
    echo "  ✓ Updated paths to use: $target_data_dir"
    processed_count=$((processed_count + 1))
done

echo ""
echo "Successfully updated all load_*.sql files"
echo "Original files backed up with .backup extension"
echo "Data directories used under: $DATA_DIR"

# Show summary of processed files
echo ""
echo "Summary:"
find "$QUERY_DIR" -name "load_*.sql" -type f | wc -l | xargs echo "Total files processed:"

# Show the expected directory structure
echo ""
echo "Expected data directory structure:"
echo "$DATA_DIR/"
echo "├── job/          (for load_job.sql files)"
echo "├── tpch/         (for load_tpch.sql files)"
echo "├── graph/        (for load_graph.sql files)"
echo "├── lsqb/         (for load_lsqb.sql files)"
echo "└── [dataset]/    (for other load_[dataset].sql files)"