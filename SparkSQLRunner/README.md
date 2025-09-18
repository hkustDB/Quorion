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
* Put your tables in `/Data`, ends with `.csv`. Use `","` as the column separator.
* Put your schema in `/Schema`, ends with `.sql`. Use `";"` to separate the statements.
* Put your query in `/Query`, ends with `.sql`. Use `";"` to separate the statements.

### Example
`/Data/Graph.csv`, `/Schema/GraphSchema.sql`, `/Query/Q1.sql`

### Run Single Query
```shell
bash ExecuteQuery.sh Q1 GraphSchema
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