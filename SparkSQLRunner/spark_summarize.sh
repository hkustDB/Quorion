LOG_DIR="/Quorion/SparkSQLRunner/log"

find "$LOG_DIR" -type f -name "*.log" | while read logfile; do
    csvfile="${logfile%.log}.csv"
    {
        echo "Query,Time"
        grep -E "Query [^ ]+ Time: [0-9]+ms" "$logfile" | \
        awk '{gsub(/ms$/,"",$4); printf "%s,%.3f\n", $2, $4/1000}' | \
        sort -t',' -k1,1V
    } > "$csvfile"
done