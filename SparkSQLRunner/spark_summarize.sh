LOG_DIR="/Quorion/SparkSQLRunner/log"
GRAPH_LOGS="epinions bitcoin dblp google"
GRAPH_CSV="${LOG_DIR}/graph.csv"
TMP_GRAPH="$(mktemp)"

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
sort -t',' -k1,1V "$TMP_GRAPH" | uniq >> "$GRAPH_CSV"
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