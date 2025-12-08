#!/bin/bash

# run_spark.sh - Automated script to run SparkSQL benchmarks
# This script builds the SparkSQLRunner, sets up data links, and executes benchmarks

set -e  # Exit on error

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_PATH="$(dirname "$SCRIPT_DIR")"
RUNNER_PATH="${ROOT_PATH}/SparkSQLRunner"
CONFIG_FILE="${ROOT_PATH}/query/config.properties"
DATA_SRC="${ROOT_PATH}/Data"
DATA_DST="${ROOT_PATH}/Data"
SCHEMA_DIR="${RUNNER_PATH}/Schema"
LOG_DIR="${RUNNER_PATH}/log"
SPARK_VERSION="3.5.1"
SPARK_DIR="${ROOT_PATH}/spark"
SPARK_HOME="${SPARK_DIR}/spark-${SPARK_VERSION}"
SPARK_DOWNLOAD_URL="https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop3.tgz"

# --- ADDED: Auto-install Spark ---
if [ ! -d "${SPARK_HOME}" ]; then
    echo "Spark not found. Downloading Spark ${SPARK_VERSION}..."
    mkdir -p "${SPARK_DIR}"
    cd "${SPARK_DIR}"
    wget "${SPARK_DOWNLOAD_URL}"
    tar -xvzf "spark-${SPARK_VERSION}-bin-hadoop3.tgz"
    
    # Rename extracted folder to match SPARK_HOME variable
    mv "spark-${SPARK_VERSION}-bin-hadoop3" "spark-${SPARK_VERSION}"
    rm "spark-${SPARK_VERSION}-bin-hadoop3.tgz"
    echo "Spark installed at ${SPARK_HOME}"
    echo "spark.home=${SPARK_HOME}" >> "$CONFIG_FILE"
else
    echo "Spark found at ${SPARK_HOME}"
    echo "spark.home=${SPARK_HOME}" >> "$CONFIG_FILE"
fi
# ---------------------------------

echo "Building SparkSQL Runner..."
cd "${RUNNER_PATH}"
mvn clean package

# Ensure directories exist
mkdir -p "${DATA_DST}"
mkdir -p "${SCHEMA_DIR}"
mkdir -p "${LOG_DIR}"

# Function to create soft links
create_links() {
    local dataset=$1
    
    echo "Creating soft links for ${dataset}..."
    
    # Process all supported file extensions
    for ext in csv tbl txt; do
        for file in "${DATA_SRC}/${dataset}"/*.${ext}; do
            # Check if file exists (glob may not match anything)
            [ -f "$file" ] || continue
            
            filename=$(basename "$file")
            ln -sf "$file" "${DATA_DST}/${filename}"
            echo "  Linked: $filename"
        done
    done
}

create_lsqb_links() {
    echo "Creating soft links for LSQB dataset with fixed mappings..."
    
    # Declare associative array for LSQB table mappings (without extensions)
    declare -A LSQB_MAPPINGS=(
        ["Company"]="aCompanyB"
        ["Person_likes_Comment"]="APerson_likes_CommentC"
        ["Tag"]="aTagB"
        ["Country"]="cCountryD"
        ["Person_workAt_Company"]="cPerson_workAt_CompanyD"
        ["TagClass"]="cTagClassD"
        # ["Continent"]="Continent"
        ["Comment"]="dCommentd"
        ["Comment_hasTag_Tag"]="eComment_hasTag_TagF"
        ["University"]="eUniversityF"
        ["Post_hasTag_Tag"]="gPost_hasTag_TagH"
        ["Post"]="hPosth"
        ["Forum_hasTag_Tag"]="iForum_hasTag_TagJ"
        ["Person_hasInterest_Tag"]="kPerson_hasInterest_TagM"
        ["Person"]="lPersonl"
        ["Forum_hasMember_Person"]="mForum_hasMember_PersonN"
        ["Person_studyAt_University"]="MPerson_studyAt_UniversityN"
        ["Person_likes_Post"]="oPerson_likes_PostP"
        ["Forum"]="QForumQ"
        ["Person_knows_Person"]="qPerson_knows_PersonR"
    )
    
    # Process all supported file extensions
    for ext in csv tbl txt; do
        for file in "${DATA_SRC}/lsqb"/*.${ext}; do
            # Check if file exists
            [ -f "$file" ] || continue
            
            filename=$(basename "$file")
            basename_noext="${filename%.*}"  # Remove extension
            file_ext="${filename##*.}"  # Get extension
            
            # Check if mapping exists
            if [ -n "${LSQB_MAPPINGS[$basename_noext]}" ]; then
                linkname="${LSQB_MAPPINGS[$basename_noext]}.${file_ext}"
                ln -sf "$file" "${DATA_DST}/lsqb/${linkname}"
                echo "  Linked: $filename -> ${linkname}"
            else
                echo "  Warning: No mapping found for $filename, skipping..."
            fi
        done
    done
}

# Function to create JOB links with fixed mappings in separate data path
create_job_links() {
    echo "Creating soft links for JOB dataset with fixed mappings..."
    
    # Declare associative array for JOB table mappings (without extensions)
    declare -A JOB_MAPPINGS=(
        ["job_aka_name"]="aaka_nameb"
        ["job_aka_title"]="caka_titled"
        ["job_cast_info"]="ecast_infof"
        ["job_char_name"]="gchar_nameh"
        ["job_comp_cast_type"]="icomp_cast_typet"
        ["job_company_name"]="lcompany_namem"
        ["job_company_type"]="ocompany_typen"
        ["job_complete_cast"]="pcomplete_castq"
        ["job_info_type"]="rinfo_types"
        ["job_keyword"]="keyword"
        ["job_kind_type"]="zkind_typea"
        ["job_link_type"]="ylink_typeb"
        ["job_movie_companies"]="xmovie_companiesc"
        ["job_movie_info"]="emovie_infoa"
        ["job_movie_info_idx"]="tmovie_info_idxd"
        ["job_movie_keyword"]="smovie_keywordp"
        ["job_movie_link"]="lmovie_linkq"
        ["job_name"]="name"
        ["job_person_info"]="lperson_infos"
        ["job_role_type"]="irole_typeo"
        ["job_title"]="title"
    )
    
    # Process all supported file extensions
    for ext in csv tbl txt; do
        for file in "${DATA_SRC}/job"/*.${ext}; do
            # Check if file exists
            [ -f "$file" ] || continue
            
            filename=$(basename "$file")
            basename_noext="${filename%.*}"  # Remove extension
            file_ext="${filename##*.}"  # Get extension
            
            # Check if mapping exists
            if [ -n "${JOB_MAPPINGS[$basename_noext]}" ]; then
                linkname="${JOB_MAPPINGS[$basename_noext]}.${file_ext}"
                ln -sf "$file" "${DATA_DST}/job/${linkname}"
                echo "  Linked: $filename -> ${linkname}"
            else
                echo "  Warning: No mapping found for $filename, skipping..."
            fi
        done
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
    local data_path=$4
    local query_path=$5
    
    echo ""
    echo "========================================="
    echo "Running ${benchmark} benchmark..."
    echo "Data Path: ${data_path}"
    echo "Query Path: ${query_path}"
    echo "========================================="
    
    cd "${RUNNER_PATH}"
    if [ -f "${test_script}" ]; then
        bash "${test_script}" "${data_path}" "${query_path}" "${schema}"
        echo "${benchmark} benchmark completed."
    else
        echo "Warning: Test script not found: ${test_script}"
    fi
}

# Run Graph benchmark
run_benchmark "graph" "epinionsSchema" "test_graph.sh" "${DATA_DST}/graph" "${RUNNER_PATH}/Query_graph"
run_benchmark "graph" "bitcoinSchema" "test_graph.sh" "${DATA_DST}/graph" "${RUNNER_PATH}/Query_graph_bitcoin"
run_benchmark "graph" "dblpSchema" "test_graph.sh" "${DATA_DST}/graph" "${RUNNER_PATH}/Query_graph_dblp"
run_benchmark "graph" "googleSchema" "test_graph.sh" "${DATA_DST}/graph" "${RUNNER_PATH}/Query_graph_google"

# Run LSQB benchmark
create_lsqb_links
run_benchmark "lsqb" "lsqbSchema" "test_lsqb.sh" "${DATA_DST}/lsqb" "${RUNNER_PATH}/Query_lsqb"
#remove_links

# Run TPC-H benchmark
run_benchmark "tpch" "tpchSchema" "test_tpch.sh" "${DATA_DST}/tpch" "${RUNNER_PATH}/Query_tpch"

# Run JOB benchmark with fixed mappings
create_job_links
run_benchmark "job" "jobSchema" "test_job.sh" "${DATA_DST}/job" "${RUNNER_PATH}/Query_job"
#remove_links


echo ""
echo "========================================="
echo "All SparkSQL benchmarks completed!"
echo "Results are in: ${LOG_DIR}"
echo "========================================="

# Extract query execution times from all log files
echo ""
echo "========================================="
echo "Extracting query execution times..."
echo "========================================="

SUMMARY_DIR="${LOG_DIR}/summary"
mkdir -p "${SUMMARY_DIR}"

# Function to extract query times from a log file
extract_query_times() {
    local log_file=$1
    local output_csv=$2
    local schema_name=$(basename "$log_file" .log)
    
    echo "Processing: $schema_name"
    
    # Create CSV header
    echo "Query,Time_ms,Time_s" > "$output_csv"
    
    # Extract query times using grep and awk
    if grep -q "Query .* Time:" "$log_file"; then
        grep "Query .* Time:" "$log_file" | awk '{
            # Extract query name (between "Query " and " Time:")
            query = $2
            # Extract time value (before "ms")
            gsub(/ms$/, "", $NF)
            time_ms = $NF
            time_s = time_ms / 1000.0
            printf "%s,%s,%.3f\n", query, time_ms, time_s
        }' >> "$output_csv"
        
        # Count results
        result_count=$(tail -n +2 "$output_csv" | wc -l)
        echo "  Extracted $result_count queries"
        
        # Calculate and display statistics
        if [ $result_count -gt 0 ]; then
            awk -F',' 'NR>1 {
                sum+=$2; 
                if(NR==2 || $2<min) min=$2; 
                if(NR==2 || $2>max) max=$2; 
                count++
            } 
            END {
                if(count>0) 
                    printf "  Min: %d ms, Max: %d ms, Avg: %.1f ms, Total: %d ms\n", min, max, sum/count, sum
            }' "$output_csv"
        fi
    else
        echo "  No query times found"
    fi
}

# Process all log files
for log_file in "${LOG_DIR}"/*.log; do
    [ -f "$log_file" ] || continue
    
    schema_name=$(basename "$log_file" .log)
    output_csv="${SUMMARY_DIR}/${schema_name}_times.csv"
    
    extract_query_times "$log_file" "$output_csv"
done

# Create combined summary CSV
COMBINED_CSV="${SUMMARY_DIR}/all_query_times.csv"
echo "Schema,Query,Time_ms,Time_s" > "$COMBINED_CSV"

for csv_file in "${SUMMARY_DIR}"/*_times.csv; do
    [ -f "$csv_file" ] || continue
    schema_name=$(basename "$csv_file" _times.csv)
    
    # Append data with schema name prefix
    tail -n +2 "$csv_file" | awk -v schema="$schema_name" -F',' '{
        printf "%s,%s,%s,%s\n", schema, $1, $2, $3
    }' >> "$COMBINED_CSV"
done

echo ""
echo "========================================="
echo "Summary completed!"
echo "========================================="
echo "Individual summaries: ${SUMMARY_DIR}/*_times.csv"
echo "Combined summary: ${COMBINED_CSV}"

# Display overall statistics
total_queries=$(tail -n +2 "$COMBINED_CSV" | wc -l)
echo ""
echo "Overall Statistics:"
echo "  Total queries: $total_queries"

if [ $total_queries -gt 0 ]; then
    tail -n +2 "$COMBINED_CSV" | awk -F',' '{
        sum+=$3; 
        if(NR==1 || $3<min) min=$3; 
        if(NR==1 || $3>max) max=$3; 
        count++
    } 
    END {
        if(count>0) 
            printf "  Min: %d ms, Max: %d ms, Avg: %.1f ms, Total: %d ms (%.1f s)\n", min, max, sum/count, sum, sum/1000
    }'
fi

echo ""

bash "${RUNNER_PATH}/spark_summarize.sh"