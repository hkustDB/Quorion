#!/bin/bash

# download_data.sh - Automated data download script for Quorion
# This script downloads and prepares all required datasets: Graph, LSQB, TPC-H, and JOB

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
QUORION_DIR="$(dirname "$SCRIPT_DIR")"
DATA_DIR="${QUORION_DIR}/Data"

source "${QUORION_DIR}/query/common.sh"
# Read Python path from config
config_files=("${QUORION_DIR}/query/config.properties")
PYTHON_BIN=$(prop ${config_files} "python3.bin")

print_info "Starting Quorion data download process..."
print_info "Quorion directory: ${QUORION_DIR}"
print_info "Data directory: ${DATA_DIR}"

LSQB_SCALE_DEFAULT="${LSQB_SCALE:-3}"
TPCH_SCALE_DEFAULT="${TPCH_SCALE:-10}"

LSQB_SCALE="${1:-${LSQB_SCALE_DEFAULT}}"
TPCH_SCALE="${2:-${TPCH_SCALE_DEFAULT}}"
PY_BIN="${PYTHON_BIN}"

# ============================================================================
# Step 1: Create directory structure
# ============================================================================
print_info "Step 1: Creating directory structure..."

mkdir -p "${DATA_DIR}"
cd "${DATA_DIR}"

mkdir -p graph
mkdir -p lsqb
mkdir -p tpch
mkdir -p job

print_info "Directory structure created successfully"
print_info "  - ${DATA_DIR}/graph"
print_info "  - ${DATA_DIR}/lsqb"
print_info "  - ${DATA_DIR}/tpch"
print_info "  - ${DATA_DIR}/job"

# ============================================================================
# Step 2: Download Graph data
# ============================================================================
print_info "Step 2: Downloading Graph data from SNAP..."

# Check if download_graph.sh exists
if [ -f "${SCRIPT_DIR}/download_graph.sh" ]; then
    print_info "Running download_graph.sh..."
    # Pass the target directory as argument
    bash "${SCRIPT_DIR}/download_graph.sh" "${DATA_DIR}/graph"
else
    print_warning "download_graph.sh not found, downloading manually..."
    
    cd "${DATA_DIR}/graph"
    
    # Download a sample graph from SNAP (com-Amazon network)
    GRAPH_URL="https://snap.stanford.edu/data/bigdata/communities/com-amazon.ungraph.txt.gz"
    GRAPH_FILE="com-amazon.ungraph.txt.gz"
    
    if [ ! -f "${GRAPH_FILE}" ]; then
        print_info "Downloading ${GRAPH_FILE}..."
        wget "${GRAPH_URL}" -O "${GRAPH_FILE}"
        gunzip -f "${GRAPH_FILE}"
        print_info "Graph data downloaded and extracted"
    else
        print_warning "Graph data already exists, skipping download"
    fi
fi

# ============================================================================
# Step 3: Download pre-generated LDBC SNB data (scale=1 or 3 from SURF)
# ============================================================================
LSQB_DIR="${DATA_DIR}/lsqb"

print_info "Creating data directory..."
mkdir -p "${LSQB_DIR}"
cd "${LSQB_DIR}"

if [ "${LSQB_SCALE}" -eq 1 ]; then
    DATASET_URL="https://github.com/hkustDB/Quorion/releases/download/lsqb_dataset/social-network-sf1-merged-fk.tar.zst"
    ARCHIVE_ZST="social-network-sf1-merged-fk.tar.zst"
elif [ "${LSQB_SCALE}" -eq 3 ]; then
    DATASET_URL="https://github.com/hkustDB/Quorion/releases/download/lsqb_dataset/social-network-sf3-merged-fk.tar.zst"
    ARCHIVE_ZST="social-network-sf3-merged-fk.tar.zst"
elif [ "${LSQB_SCALE}" -eq 30 ]; then
    DATASET_URL="https://github.com/hkustDB/Quorion/releases/download/lsqb_dataset/social-network-sf30-merged-fk.tar.zst"
    ARCHIVE_ZST="social-network-sf30-merged-fk.tar.zst"
else
    print_error "Unsupported LSQB scale: ${LSQB_SCALE}. Supported scales: 1, 3, 30."
    exit 1
fi

print_info "Downloading from: ${DATASET_URL}"

if [ ! -f "${ARCHIVE_ZST}" ]; then
    wget "${DATASET_URL}" -O "${ARCHIVE_ZST}"
else
    print_warning "Archive ${ARCHIVE_ZST} already exists, skipping download."
fi

# ...existing code...
print_info "Extracting data..."

if command -v zstd >/dev/null 2>&1; then
    print_info "Using: zstd -dc | tar -x"
    if ! zstd -dc -- "${ARCHIVE_ZST}" | tar -x; then
        print_error "Extraction failed! The archive ${ARCHIVE_ZST} appears corrupted."
        print_info "Removing corrupted file. Please run the script again to re-download."
        rm -f "${ARCHIVE_ZST}"
        exit 1
    fi
    rm -f "${ARCHIVE_ZST}"
else
    # Try python zstandard; auto-create a local venv if module missing
    if ! command -v "${PY_BIN}" >/dev/null 2>&1; then
        print_error "python3 not found and zstd CLI not available."
        exit 1
    fi

    if ! "${PY_BIN}" -c 'import zstandard' 2>/dev/null; then
        if "${PY_BIN}" -m venv -h >/dev/null 2>&1; then
            VENV_DIR="${LSQB_DIR}/.venv_zstd"
            print_info "Creating local venv at ${VENV_DIR} and installing zstandard..."
            "${PY_BIN}" -m venv "${VENV_DIR}"
            "${VENV_DIR}/bin/pip" install --quiet --upgrade pip
            "${VENV_DIR}/bin/pip" install --quiet zstandard
            PY_BIN="${VENV_DIR}/bin/python"
        else
            print_error "zstd CLI missing and Python zstandard not available; venv module not present."
            print_info "Install without root: python3 -m pip install --user zstandard"
            exit 1
        fi
    fi

    print_info "Using: ${PY_BIN} + zstandard (user-space)"
    TMP_TAR="$(mktemp -p . tmp.XXXXXXXX.tar)"
    "${PY_BIN}" - "$ARCHIVE_ZST" "$TMP_TAR" << 'PY'
import sys, zstandard as zstd
src, dst = sys.argv[1], sys.argv[2]
dctx = zstd.ZstdDecompressor()
with open(src, 'rb') as fin, open(dst, 'wb') as fout, dctx.stream_reader(fin) as r:
    while True:
        chunk = r.read(1 << 20)
        if not chunk:
            break
        fout.write(chunk)
PY
    tar -xf "${TMP_TAR}"
    rm -f "${TMP_TAR}" "${ARCHIVE_ZST}"
fi

# Flatten: move all CSV files under any subdir to LSQB_DIR root
print_info "Flattening CSV files into ${LSQB_DIR}..."
CSV_BEFORE=$(find . -maxdepth 1 -type f -name "*.csv" | wc -l)
# Move only files not already in root
find . -mindepth 2 -type f -name "*.csv" -print0 | xargs -0 -I{} mv -f "{}" .
CSV_AFTER=$(find . -maxdepth 1 -type f -name "*.csv" | wc -l)
print_info "CSV files at root: ${CSV_AFTER} (was ${CSV_BEFORE})"

# Cleanup: remove extracted directories and leftover non-CSV artifacts
print_info "Cleaning up extracted directories and archives..."
# Remove common extracted top-level dirs (keep potential local venv)
find . -mindepth 1 -maxdepth 1 -type d ! -name ".venv_zstd" -exec rm -rf {} +
# Remove any leftover tar/zst files
rm -f -- *.tar *.tar.zst *.zst 2>/dev/null || true

# Count CSV files
CSV_COUNT=$(find . -maxdepth 1 -type f -name "*.csv" | wc -l)

# ============================================================================
# Step 4: Download/Generate TPC-H data (scale=${TPCH_SCALE})
# ============================================================================
print_info "Step 4: Setting up TPC-H data (scale=${TPCH_SCALE})..."

cd "${DATA_DIR}/tpch"

print_info "Downloading TPC-H toolkit..."

TPCH_VERSION="3.0.1"
TPCH_URL="https://www.tpc.org/tpc_documents_current_versions/download_programs/tools-download-request5.asp?bm_type=TPC-H&bm_vers=${TPCH_VERSION}&mode=CURRENT-ONLY"

if [ ! -d "dbgen" ]; then
    # Try to download from GitHub mirror (easier than TPC.org)
    print_info "Cloning TPC-H dbgen from GitHub mirror..."
    git clone https://github.com/electrum/tpch-dbgen.git dbgen
    
    cd dbgen
    
    print_info "Building TPC-H dbgen..."
    make clean
    make
    
    print_info "Generating TPC-H data with scale factor ${TPCH_SCALE}..."
    print_warning "This may take 10-30 minutes depending on your system..."
    
    ./dbgen -s ${TPCH_SCALE} -v
    
    # Move generated .tbl files to parent directory
    mv *.tbl ../
    
    cd ..

    # FIX: Grant read permissions to everyone so the 'postgres' user can read them
    print_info "Setting permissions for TPC-H files..."
    chmod 644 *.tbl
    chmod 755 .
    
    print_info "TPC-H data generation completed"
    print_info "Generated files:"
    ls -lh *.tbl
else
    print_warning "TPC-H dbgen already exists"
    print_info "If you need to regenerate, delete the dbgen directory and run again"
fi

# ============================================================================
# Step 5: Download JOB data
# ============================================================================
print_info "Step 5: Downloading JOB (Join Order Benchmark) data..."

cd "${DATA_DIR}/job"

# Check if download_job.sh exists
if [ -f "${SCRIPT_DIR}/download_job.sh" ]; then
    print_info "Running download_job.sh..."
    bash "${SCRIPT_DIR}/download_job.sh"
else
    print_warning "download_job.sh not found, downloading manually..."
    
    # Download JOB data from DuckDB
    print_info "Downloading IMDB dataset (~3.7GB, this may take a while)..."
    
    # Create download script
    cat > download_imdb.sql << 'EOF'
INSTALL httpfs;
LOAD httpfs;

-- Download and import IMDB data
COPY (FROM 'https://blobs.duckdb.org/data/imdb.tar.gz') TO 'imdb.tar.gz';
EOF
    
    # Alternative: Direct download using wget/curl
    IMDB_URL="https://blobs.duckdb.org/data/imdb.tar.gz"
    
    if [ ! -f "imdb.tar.gz" ]; then
        print_info "Downloading IMDB dataset..."
        if command -v wget &> /dev/null; then
            wget "${IMDB_URL}" -O imdb.tar.gz
        elif command -v curl &> /dev/null; then
            curl -L "${IMDB_URL}" -o imdb.tar.gz
        else
            print_error "Neither wget nor curl found. Please install one of them."
            exit 1
        fi
    else
        print_warning "imdb.tar.gz already exists, skipping download"
    fi
    
    print_info "Extracting IMDB dataset..."
    tar -xzf imdb.tar.gz
    
    print_info "JOB data download completed"
fi

# ============================================================================
# Final Summary
# ============================================================================
print_info "=========================================="
print_info "Data download process completed!"
print_info "=========================================="
print_info ""
print_info "Downloaded datasets:"
print_info "  1. Graph data:  ${DATA_DIR}/graph"
print_info "  2. LSQB data:   ${DATA_DIR}/lsqb (scale=30)"
print_info "  3. TPC-H data:  ${DATA_DIR}/tpch (scale=10)"
print_info "  4. JOB data:    ${DATA_DIR}/job (scale=1)"
print_info ""
print_info "Data directory size:"
du -sh "${DATA_DIR}/graph" 2>/dev/null || echo "  Graph: N/A"
du -sh "${DATA_DIR}/lsqb" 2>/dev/null || echo "  LSQB: N/A"
du -sh "${DATA_DIR}/tpch" 2>/dev/null || echo "  TPC-H: N/A"
du -sh "${DATA_DIR}/job" 2>/dev/null || echo "  JOB: N/A"
print_info ""
print_info "Next steps:"
print_info "  1. Run: bash scripts/update_paths.sh"
print_info "  2. Configure: query/config.properties"
print_info "  3. Load data: bash scripts/load_data_duckdb.sh"
print_info "  4. Load data: bash scripts/load_data_pg.sh"
print_info ""
print_info "For more information, see README.md"

# Return to original directory
cd "${QUORION_DIR}"
