#!/bin/bash

# generate_job_load.sh - Generate DuckDB and PostgreSQL SQL for loading job tables with all available indexed files

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUORION_DIR="$(dirname "$SCRIPT_DIR")"
OUTSQL_DUCKDB="${SCRIPT_DIR}/load_job_duckdb_generated.sql"
OUTSQL_PG="${SCRIPT_DIR}/load_job_pg_generated.sql"
DATAPATH="${QUORION_DIR}/Data/job/new"

# Read DuckDB path from config
source "${QUORION_DIR}/query/common.sh"
config_files=("${QUORION_DIR}/query/config.properties")
duckdb=$(prop ${config_files} "duckdb.path")

# Table schemas for DuckDB
declare -A schemas_duckdb
schemas_duckdb["aka_name"]="id integer, person_id integer, name varchar(512), imdb_index varchar(3), name_pcode_cf varchar(11), name_pcode_nf varchar(11), surname_pcode varchar(11), md5sum varchar(65)"
schemas_duckdb["aka_title"]="id integer NOT NULL, movie_id integer NOT NULL, title varchar(553) NOT NULL, imdb_index varchar(12), kind_id integer NOT NULL, production_year real, phonetic_code varchar(5), episode_of_id real, season_nr real, episode_nr real, note varchar(72), md5sum varchar(32)"
schemas_duckdb["cast_info"]="id integer, person_id integer, movie_id integer, person_role_id real, note text, nr_order real, role_id integer"
schemas_duckdb["char_name"]="id integer, name varchar(512), imdb_index varchar(2), imdb_id real, name_pcode_nf varchar(5), surname_pcode varchar(5), md5sum varchar(32)"
schemas_duckdb["comp_cast_type"]="id integer, kind varchar(32)"
schemas_duckdb["company_name"]="id integer, name varchar(512), country_code varchar(6), imdb_id real, name_pcode_nf varchar(5), name_pcode_sf varchar(5), md5sum varchar(32)"
schemas_duckdb["company_type"]="id integer, kind varchar(32)"
schemas_duckdb["complete_cast"]="id integer, movie_id integer, subject_id integer, status_id integer"
schemas_duckdb["info_type"]="id integer, info varchar(32)"
schemas_duckdb["keyword"]="id integer, keyword varchar(512), phonetic_code varchar(5)"
schemas_duckdb["kind_type"]="id integer, kind varchar(15)"
schemas_duckdb["link_type"]="id integer, link varchar(32)"
schemas_duckdb["movie_companies"]="id integer, movie_id integer, company_id integer, company_type_id integer, note text"
schemas_duckdb["movie_info_idx"]="id integer, movie_id integer, info_type_id integer, info text, note text"
schemas_duckdb["movie_keyword"]="id integer, movie_id integer, keyword_id integer"
schemas_duckdb["movie_link"]="id integer, movie_id integer, linked_movie_id integer, link_type_id integer"
schemas_duckdb["name"]="id integer, name varchar(512), imdb_index varchar(9), imdb_id real, gender varchar(1), name_pcode_cf varchar(5), name_pcode_nf varchar(5), surname_pcode varchar(5), md5sum varchar(32)"
schemas_duckdb["role_type"]="id integer, role varchar(32)"
schemas_duckdb["title"]="id integer, title varchar(512), imdb_index varchar(5), kind_id integer, production_year real, imdb_id real, phonetic_code varchar(5), episode_of_id real, season_nr real, episode_nr real, series_years varchar(49), md5sum varchar(32)"
schemas_duckdb["movie_info"]="id integer, movie_id integer, info_type_id integer, info text, note text"
schemas_duckdb["person_info"]="id integer, person_id integer, info_type_id integer, info text, note text"

# Table schemas for PostgreSQL
declare -A schemas_pg
schemas_pg["aka_name"]="id integer PRIMARY KEY, person_id integer, name varchar(512), imdb_index varchar(3), name_pcode_cf varchar(11), name_pcode_nf varchar(11), surname_pcode varchar(11), md5sum varchar(65)"
schemas_pg["aka_title"]="id integer PRIMARY KEY, movie_id integer NOT NULL, title varchar(553) NOT NULL, imdb_index varchar(12), kind_id integer NOT NULL, production_year real, phonetic_code varchar(5), episode_of_id real, season_nr real, episode_nr real, note varchar(72), md5sum varchar(32)"
schemas_pg["cast_info"]="id integer PRIMARY KEY, person_id integer, movie_id integer, person_role_id real, note text, nr_order real, role_id integer"
schemas_pg["char_name"]="id integer PRIMARY KEY, name varchar(512), imdb_index varchar(2), imdb_id real, name_pcode_nf varchar(5), surname_pcode varchar(5), md5sum varchar(32)"
schemas_pg["comp_cast_type"]="id integer PRIMARY KEY, kind varchar(32)"
schemas_pg["company_name"]="id integer PRIMARY KEY, name varchar(512), country_code varchar(6), imdb_id real, name_pcode_nf varchar(5), name_pcode_sf varchar(5), md5sum varchar(32)"
schemas_pg["company_type"]="id integer PRIMARY KEY, kind varchar(32)"
schemas_pg["complete_cast"]="id integer PRIMARY KEY, movie_id integer, subject_id integer, status_id integer"
schemas_pg["info_type"]="id integer PRIMARY KEY, info varchar(32)"
schemas_pg["keyword"]="id integer PRIMARY KEY, keyword varchar(512), phonetic_code varchar(5)"
schemas_pg["kind_type"]="id integer PRIMARY KEY, kind varchar(15)"
schemas_pg["link_type"]="id integer PRIMARY KEY, link varchar(32)"
schemas_pg["movie_companies"]="id integer PRIMARY KEY, movie_id integer, company_id integer, company_type_id integer, note text"
schemas_pg["movie_info_idx"]="id integer PRIMARY KEY, movie_id integer, info_type_id integer, info text, note text"
schemas_pg["movie_keyword"]="id integer PRIMARY KEY, movie_id integer, keyword_id integer"
schemas_pg["movie_link"]="id integer PRIMARY KEY, movie_id integer, linked_movie_id integer, link_type_id integer"
schemas_pg["name"]="id integer PRIMARY KEY, name varchar(512), imdb_index varchar(9), imdb_id real, gender varchar(1), name_pcode_cf varchar(5), name_pcode_nf varchar(5), surname_pcode varchar(5), md5sum varchar(32)"
schemas_pg["role_type"]="id integer PRIMARY KEY, role varchar(32)"
schemas_pg["title"]="id integer PRIMARY KEY, title varchar(512), imdb_index varchar(5), kind_id integer, production_year real, imdb_id real, phonetic_code varchar(5), episode_of_id real, season_nr real, episode_nr real, series_years varchar(49), md5sum varchar(32)"
schemas_pg["movie_info"]="id integer PRIMARY KEY, movie_id integer, info_type_id integer, info text, note text"
schemas_pg["person_info"]="id integer PRIMARY KEY, person_id integer, info_type_id integer, info text, note text"

# List of tables to process
tables=(
    aka_name aka_title cast_info char_name comp_cast_type company_name company_type
    complete_cast info_type keyword kind_type link_type movie_companies movie_info_idx
    movie_keyword movie_link name role_type title movie_info person_info
)

# --- Convert Parquet to CSV using DuckDB ---
echo "Checking for DuckDB at: $duckdb"
if ! [ -x "$duckdb" ]; then
    echo "ERROR: DuckDB executable not found at $duckdb"
    echo "Please install DuckDB and set duckdb.path in config.properties."
    exit 1
fi

echo "Converting Parquet files to CSV in $DATAPATH using DuckDB..."
find "$DATAPATH" -type f -name "*.parquet" | while read -r parquet_file; do
    csv_file="${parquet_file%.parquet}.csv"
    if [ ! -f "$csv_file" ]; then
        echo "  Converting $parquet_file to $csv_file ..."
        "$duckdb" -c "COPY (SELECT * FROM read_parquet('$parquet_file')) TO '$csv_file' (HEADER, DELIMITER ',');"
        if [ $? -ne 0 ]; then
            echo "  ❌ Failed to convert $parquet_file using DuckDB."
        fi
    else
        echo "  ✓ CSV already exists: $csv_file"
    fi
done
echo "Parquet to CSV conversion completed."
echo ""

# Generate DuckDB SQL
rm -f "$OUTSQL_DUCKDB"

for table in "${tables[@]}"; do
    echo "CREATE TABLE IF NOT EXISTS $table (" >> "$OUTSQL_DUCKDB"
    echo "    ${schemas_duckdb[$table]}," >> "$OUTSQL_DUCKDB"
    echo "    PRIMARY KEY (id)" >> "$OUTSQL_DUCKDB"
    echo ");" >> "$OUTSQL_DUCKDB"
    
    for parquet in "$DATAPATH"/${table}_*.parquet; do
        if [ -f "$parquet" ]; then
            filename=$(basename "$parquet")
            if [[ "$filename" =~ ^${table}_[0-9-]+\.parquet$ ]]; then
                echo "insert into $table SELECT * FROM read_parquet('$parquet');" >> "$OUTSQL_DUCKDB"
            fi
        fi
    done
    
    echo "" >> "$OUTSQL_DUCKDB"
done

echo "DuckDB SQL file generated: $OUTSQL_DUCKDB"
echo "To load into DuckDB, run:"
echo "  duckdb job.duckdb < $OUTSQL_DUCKDB"
echo ""

# Generate PostgreSQL SQL
rm -f "$OUTSQL_PG"

for table in "${tables[@]}"; do
    echo "CREATE TABLE IF NOT EXISTS $table (" >> "$OUTSQL_PG"
    echo "    ${schemas_pg[$table]}" >> "$OUTSQL_PG"
    echo ");" >> "$OUTSQL_PG"
    
    for csvfile in "$DATAPATH"/${table}_*.csv; do
        if [ -f "$csvfile" ]; then
            filename=$(basename "$csvfile")
            if [[ "$filename" =~ ^${table}_[0-9-]+\.csv$ ]]; then
                echo "COPY $table FROM '$csvfile' WITH (FORMAT csv, HEADER true);" >> "$OUTSQL_PG"
            fi
        fi
    done
    
    echo "" >> "$OUTSQL_PG"
    echo "" >> "$OUTSQL_PG"
done

echo "PostgreSQL SQL file generated: $OUTSQL_PG"
echo "To load into PostgreSQL, run:"
echo "  psql -U postgres -d test -f $OUTSQL_PG"