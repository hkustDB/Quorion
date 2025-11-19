# SparkSQL Runner
This is a guide for running SparkSQL.
## Usage
### Build
```shell
mvn clean package
```

### Config
* Rename `config.properties.tpl` to `config.properties` 
* Set `Spark.home` to your local spark home

### Prepare
* Put your tables in csv files. Use `","` as the column separator.
* Put your schema in `/Schema`, ends with `.sql`. Use `";"` to separate the statements.
* Put your query in a query folder, ends with `.sql`. Use `";"` to separate the statements.

### Run Single Query
```shell
# bash ExecuteQuery.sh ${DATA_PATH} ${QUERY_NAME} ${SCHEMA_NAME} ${TABLE_SUFFIX}
bash ExecuteQuery.sh "/path/to/Data/" "/path/to/Query/" "GraphSchema" "csv"
```
### Run Benchmark
```shell
./test_graph.sh
./test_lsqb.sh
./test_tpch.sh
./test_job.sh
```

### Results
* Check the results in `/log`