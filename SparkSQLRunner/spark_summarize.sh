LOG_DIR="/Quorion/SparkSQLRunner/log"
GRAPH_LOGS="epinions bitcoin dblp google"
GRAPH_CSV="${LOG_DIR}/graph.csv"
TMP_GRAPH="$(mktemp)"

# Collect and merge graph logs
echo "Query,Time" > "$GRAPH_CSV"
for name in $GRAPH_LOGS; do
    for logfile in "$LOG_DIR"/${name}*.log; do
        [ -e "$logfile" ] || continue
        grep -E "Query [^ ]+ Time: [0-9]+ms" "$logfile" | \
        awk '{gsub(/ms$/,"",$4); printf "%s,%.3f\n", $2, $4/1000}' >> "$TMP_GRAPH"
    done
done

# Sort queries by number first, then by alphabetical suffix
awk -F',' '{
    query=$1;
    time=$2;
    match(query, /^[0-9]+/);
    num=substr(query, RSTART, RLENGTH);
    suffix=substr(query, RSTART + RLENGTH);
    printf "%s,%s,%s,%s\n", num, suffix, query, time;
}' "$TMP_GRAPH" | \
sort -t',' -k1,1n -k2,2 | \
awk -F',' '{printf "%s,%s\n", $3, $4}' >> "$GRAPH_CSV"

rm -f "$TMP_GRAPH"

# Process other logs separately
find "$LOG_DIR" -type f -name "*.log" | while read logfile; do
    base=$(basename "$logfile")
    case "$base" in
        epinions*.log|bitcoin*.log|dblp*.log|google*.log)
            # Already processed
            continue
            ;;
        *)
            csvfile="${logfile%.log}.csv"
            {
                echo "Query,Time"
                grep -E "Query [^ ]+ Time: [0-9]+ms" "$logfile" | \
                awk '{gsub(/ms$/,"",$4); printf "%s,%.3f\n", $2, $4/1000}' | \
                sort -V
            } > "$csvfile"
            ;;
    esac
done