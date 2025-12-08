#!/bin/bash

# Accept input parameters
LSQB_SCALE=${1:-1}
TPCH_SCALE=${2:-1}

bash scripts/run_all_1.sh "$LSQB_SCALE" "$TPCH_SCALE"
bash scripts/run_all_2.sh