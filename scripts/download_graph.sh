#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname "${SCRIPT}")

# Use argument if provided, otherwise use script path
if [ -n "$1" ]; then
    data_path="$1"
else
    # Default to Quorion/Data/graph
    QUORION_DIR=$(dirname "${SCRIPT_PATH}")
    data_path="${QUORION_DIR}/Data/graph"
fi

mkdir -p "${data_path}"
cd "${data_path}"

echo "Downloading graph data to: ${data_path}"

# 1. bitcoin (from https://snap.stanford.edu/data/soc-sign-bitcoin-alpha.html)
rm -f bitcoin.txt
rm -f soc-sign-bitcoinalpha.csv
rm -f soc-sign-bitcoinalpha.csv.gz
echo "Downloading bitcoin graph..."
curl -O https://snap.stanford.edu/data/soc-sign-bitcoinalpha.csv.gz > /dev/null 2>&1
gzip -d soc-sign-bitcoinalpha.csv.gz
mv soc-sign-bitcoinalpha.csv bitcoin.txt

# 2. epinions (from https://snap.stanford.edu/data/soc-Epinions1.html)
rm -f epinions.txt
rm -f soc-Epinions1.txt
rm -f soc-Epinions1.txt.gz
echo "Downloading epinions graph..."
curl -O https://snap.stanford.edu/data/soc-Epinions1.txt.gz > /dev/null 2>&1
gzip -d soc-Epinions1.txt.gz
tail -n +5 soc-Epinions1.txt > epinions.txt
rm -f soc-Epinions1.txt

# 3. google (from https://snap.stanford.edu/data/web-Google.html)
rm -f google.txt
rm -f web-Google.txt
rm -f web-Google.txt.gz
echo "Downloading google graph..."
curl -O https://snap.stanford.edu/data/web-Google.txt.gz > /dev/null 2>&1
gzip -d web-Google.txt.gz
tail -n +5 web-Google.txt > google.txt
rm -f web-Google.txt

# 5. dblp (from https://snap.stanford.edu/data/com-DBLP.html)
rm -f dblp.txt
rm -f com-dblp.ungraph.txt
rm -f com-dblp.ungraph.txt.gz
echo "Downloading dblp graph..."
curl -O https://snap.stanford.edu/data/bigdata/communities/com-dblp.ungraph.txt.gz > /dev/null 2>&1
gzip -d com-dblp.ungraph.txt.gz
tail -n +5 com-dblp.ungraph.txt > dblp.txt
rm -f com-dblp.ungraph.txt

# No need to create subdirectory, already in correct location
echo "Graph data downloaded successfully to: ${data_path}"
echo "Files:"
ls -lh *.txt