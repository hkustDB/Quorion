#!/bin/bash

SCRIPT=$(readlink -f $0)
SCRIPT_PATH=$(dirname "${SCRIPT}")

data_path="${SCRIPT_PATH}"
cd "${data_path}"

# 1. bitcoin (from https://snap.stanford.edu/data/soc-sign-bitcoin-alpha.html)
rm -f bitcoin.txt
rm -f soc-sign-bitcoinalpha.csv
rm -f soc-sign-bitcoinalpha.csv.gz
curl -O https://snap.stanford.edu/data/soc-sign-bitcoinalpha.csv.gz > /dev/null 2>&1
gzip -d soc-sign-bitcoinalpha.csv.gz
mv soc-sign-bitcoinalpha.csv bitcoin.txt

# 2. epinions (from https://snap.stanford.edu/data/soc-Epinions1.html)
rm -f epinions.txt
rm -f soc-Epinions1.txt
rm -f soc-Epinions1.txt.gz
curl -O https://snap.stanford.edu/data/soc-Epinions1.txt.gz > /dev/null 2>&1
gzip -d soc-Epinions1.txt.gz
tail -n +5 soc-Epinions1.txt > epinions.txt
rm -f soc-Epinions1.txt

# 3. google (from https://snap.stanford.edu/data/web-Google.html)
rm -f google.txt
rm -f web-Google.txt
rm -f web-Google.txt.gz
curl -O https://snap.stanford.edu/data/web-Google.txt.gz > /dev/null 2>&1
gzip -d web-Google.txt.gz
tail -n +5 web-Google.txt > google.txt
rm -f web-Google.txt

# 4. wiki (from https://snap.stanford.edu/data/wiki-topcats.html)
rm -f wiki.txt
rm -f wiki-topcats.txt
rm -f wiki-topcats.txt.gz
curl -O https://snap.stanford.edu/data/wiki-topcats.txt.gz > /dev/null 2>&1
gzip -d wiki-topcats.txt.gz
mv wiki-topcats.txt wiki.txt

# 5. dblp (from https://snap.stanford.edu/data/com-DBLP.html)
rm -f dblp.txt
rm -f com-dblp.ungraph.txt
rm -f com-dblp.ungraph.txt.gz
curl -O https://snap.stanford.edu/data/bigdata/communities/com-dblp.ungraph.txt.gz > /dev/null 2>&1
gzip -d com-dblp.ungraph.txt.gz
tail -n +5 com-dblp.ungraph.txt > dblp.txt
rm -f com-dblp.ungraph.txt

mkdir -p graph_data
mv bitcoin.txt graph_data/
mv epinions.txt graph_data/
mv google.txt graph_data/
mv wiki.txt graph_data/
mv dblp.txt graph_data/