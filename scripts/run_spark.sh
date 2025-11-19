#!/bin/bash
# filepath: /home/data/bchenba/Quorion/scripts/run_spark.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_PATH="$(dirname "$SCRIPT_DIR")"
RUNNER_PATH="${ROOT_PATH}/SparkSQLRunner"
DATA_SRC="${ROOT_PATH}/Data"
DATA_DST="${RUNNER_PATH}/Data"
SCHEMA_DIR="${RUNNER_PATH}/Schema"
LOG_DIR="${RUNNER_PATH}/log"

echo "========================================="
echo "SparkSQL Runner - Automated Benchmark"
echo "========================================="

# Ensure directories exist
mkdir -p "${DATA_DST}"
mkdir -p "${SCHEMA_DIR}"
mkdir -p "${LOG_DIR}"

# Build SparkSQL Runner
echo "Building SparkSQL Runner..."
cd "${RUNNER_PATH}"
mvn clean package

# Configure
echo "Configuring SparkSQL Runner..."
if [ ! -f "${RUNNER_PATH}/config.properties" ]; then
    cp "${RUNNER_PATH}/config.properties.tpl" "${RUNNER_PATH}/config.properties"
fi

# Function to create soft links
create_links() {
    local dataset=$1
    local prefix=${2:-""}
    local suffix=${3:-""}
    
    echo "Creating soft links for ${dataset}..."
    for file in "${DATA_SRC}/${dataset}"/*.csv; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            if [ -n "$prefix" ] || [ -n "$suffix" ]; then
                # Add prefix/suffix for JOB dataset
                name="${filename%.csv}"
                linkname="${prefix}${name}${suffix}.csv"
            else
                linkname="$filename"
            fi
            ln -sf "$file" "${DATA_DST}/${linkname}"
            echo "  Linked: $filename -> ${linkname}"
        fi
    done
}

# Function to create JOB links with fixed mappings
create_job_links() {
    echo "Creating soft links for JOB dataset with fixed mappings..."
    
    # Declare associative array for JOB table mappings
    declare -A JOB_MAPPINGS=(
        ["job_aka_name.csv"]="aaka_nameb.csv"
        ["job_aka_title.csv"]="caka_titled.csv"
        ["job_cast_info.csv"]="ecast_infof.csv"
        ["job_char_name.csv"]="gchar_nameh.csv"
        ["job_comp_cast_type.csv"]="icomp_cast_typet.csv"
        ["job_company_name.csv"]="lcompany_namem.csv"
        ["job_company_type.csv"]="ocompany_typen.csv"
        ["job_complete_cast.csv"]="pcomplete_castq.csv"
        ["job_info_type.csv"]="rinfo_types.csv"
        ["job_keyword.csv"]="keyword.csv"
        ["job_kind_type.csv"]="zkind_typea.csv"
        ["job_link_type.csv"]="ylink_typeb.csv"
        ["job_movie_companies.csv"]="xmovie_companiesc.csv"
        ["job_movie_info.csv"]="emovie_infoa.csv"
        ["job_movie_info_idx.csv"]="tmovie_info_idxd.csv"
        ["job_movie_keyword.csv"]="smovie_keywordp.csv"
        ["job_movie_link.csv"]="lmovie_linkq.csv"
        ["job_name.csv"]="name.csv"
        ["job_person_info.csv"]="lperson_infos.csv"
        ["job_role_type.csv"]="irole_typeo.csv"
        ["job_title.csv"]="title.csv"
    )
    
    for file in "${DATA_SRC}/job"/*.csv; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            
            # Check if mapping exists
            if [ -n "${JOB_MAPPINGS[$filename]}" ]; then
                linkname="${JOB_MAPPINGS[$filename]}"
                ln -sf "$file" "${DATA_DST}/${linkname}"
                echo "  Linked: $filename -> ${linkname}"
            else
                echo "  Warning: No mapping found for $filename, skipping..."
            fi
        fi
    done
}

# Function to remove soft links
remove_links() {
    echo "Cleaning up soft links..."
    find "${DATA_DST}" -type l -delete
    echo "  Soft links removed."
}

# Function to run benchmark
run_benchmark() {
    local benchmark=$1
    local schema=$2
    local test_script=$3
    
    echo ""
    echo "========================================="
    echo "Running ${benchmark} benchmark..."
    echo "========================================="
    
    cd "${RUNNER_PATH}"
    bash "${test_script}"
    
    echo "${benchmark} benchmark completed."
}

# Run Graph benchmark
create_links "graph"
run_benchmark "Graph" "GraphSchema" "test_graph.sh"
remove_links

# Run LSQB benchmark
create_links "lsqb"
run_benchmark "LSQB" "LSQBSchema" "test_lsqb.sh"
remove_links

# Run TPC-H benchmark
create_links "tpch"
run_benchmark "TPC-H" "TPCHSchema" "test_tpch.sh"
remove_links

# Run JOB benchmark with fixed mappings
create_job_links
run_benchmark "JOB" "JOBSchema" "test_job.sh"
remove_links

echo ""
echo "========================================="
echo "All SparkSQL benchmarks completed!"
echo "Results are in: ${LOG_DIR}"
echo "========================================="