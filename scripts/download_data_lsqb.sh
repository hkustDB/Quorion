#!/bin/bash

# download_data_lsqb.sh - Automated data download script for Quorion
# This script downloads and prepares LSQB dataset

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

print_info "Starting LSQB data download process..."
print_info "Quorion directory: ${QUORION_DIR}"
print_info "Data directory: ${DATA_DIR}"

# ============================================================================
# Step 3: Download pre-generated LDBC SNB data (scale=1 or 3 from SURF)
# ============================================================================
LSQB_DIR="${DATA_DIR}/lsqb"
SCALE="${1:-1}"  # allow overriding scale via first arg (1 or 3)

print_info "Creating data directory..."
mkdir -p "${LSQB_DIR}"

print_info "Downloading LDBC SNB data (csv_basic, scale=${SCALE}) from SURF..."
cd "${LSQB_DIR}"

BASE_URL="https://repository.surfsara.nl/datasets/cwi/lsqb/files/lsqb-merged"
ARCHIVE_ZST="social-network-sf${SCALE}-merged-fk.tar.zst"
DATASET_URL="${BASE_URL}/${ARCHIVE_ZST}"

print_info "Downloading from: ${DATASET_URL}"

# Skip download if archive already exists and is non-empty
if [[ -s "${ARCHIVE_ZST}" ]]; then
    print_info "Archive already present, skipping download: ${ARCHIVE_ZST}"
else
    # Prefer the SURF staging-aware helper if available
    DOWNLOADER="${QUORION_DIR}/scripts/download-data-set.sh"
    if [[ -x "${DOWNLOADER}" ]]; then
        "${DOWNLOADER}" "${DATASET_URL}"
    else
        print_warning "Staging helper not found at ${DOWNLOADER}. Falling back to wget."
        if command -v wget2 >/dev/null 2>&1; then
            wget2 --no-check-certificate -c "${DATASET_URL}" -O "${ARCHIVE_ZST}"
        else
            wget --no-check-certificate -c "${DATASET_URL}" -O "${ARCHIVE_ZST}"
        fi
    fi

    # Verify archive after download
    if [[ ! -s "${ARCHIVE_ZST}" ]]; then
        print_error "Archive ${ARCHIVE_ZST} not found or empty after download."
        exit 1
    fi
    print_info "Archive size: $(du -h "${ARCHIVE_ZST}" | cut -f1)"
fi

# Extract data
if [[ ! -f "${ARCHIVE_ZST}" ]]; then
    # If the downloader saved with original name, ensure it exists
    if [[ ! -f "${ARCHIVE_ZST}" ]]; then
        print_error "Archive ${ARCHIVE_ZST} not found after download."
        exit 1
    fi
fi

print_info "Extracting data..."
ARCHIVE_TAR="${ARCHIVE_ZST%.zst}"

if command -v zstd >/dev/null 2>&1; then
    print_info "Using: zstd -dc | tar -x"
    zstd -dc -- "${ARCHIVE_ZST}" | tar -x
    rm -f "${ARCHIVE_ZST}"
else
    # Try python zstandard; auto-create a local venv if module missing
    PY_BIN="${PYTHON_BIN}"
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
# Final Summary
# ============================================================================
print_info "=========================================="
print_info "LSQB data download completed!"
print_info "=========================================="
print_info ""
print_info "Downloaded dataset:"
print_info "  LSQB data: ${DATA_DIR}/lsqb (scale=1)"
print_info ""
print_info "Data directory size:"
du -sh "${DATA_DIR}/lsqb" 2>/dev/null || echo "  LSQB: N/A"
print_info ""
print_info "CSV files: ${CSV_COUNT}"
print_info ""
print_info "Sample files:"
ls *.csv 2>/dev/null | head -5
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
