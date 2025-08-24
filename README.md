# Query running too slow? Rewrite it with Quorion!


## Part1: Rewritten Queries Generation
### Environment Requirements
- Java JDK 1.8
- Scala 2.12.10
- Maven 3.8.6
- Python version >= 3.9
- Python package requirements: docopt, requests, flask, openpyxl, pandas, matplotlib, numpy

0. Preprocessing[option]. 
- Statistics: For generating new statistics (`cost.csv`), we offer the DuckDB version scripts `query/preprocess.sh` and `query/gen_cost.sh`. Modify the configurations in them, and execute the following command. For web-ui, please move the generated statistics files to folder `graph/q1/`, `tpch/q2/`, `lsqb/q1/`, `job/1a/`, and `custom/q1/` respectively; for command-line operations, please move them to the specific corresponding query folders. 
- Plan: Here, we also provide the conversion of DuckDB plans. Please modify the DuckDB and Python paths in gen_plan.sh. Then execute the following command. After running the command, the original DuckDB plan will be generated as `db_plan.json`, and the newly generated plan will be `plan.json`, which is suitable for our parser. Here `${DB_FILE_PATH}` represents a persistent database in DuckDB. Please change the parameter to `timeout=0` in `requests.post` at `main.py:223` if you want to use the self-defined plan. 
```
$ ./gen_plan.sh ${DB_FILE_PATH} ${QUERY_DIRECTORY}
e.g.
./gen_plan.sh ~/test_db job
```
1. We provide two execution modes. The default mode is web-ui execution. If you need to switch, please modify the corresponding value `EXEC_MODE` at Line `767` in `main.py`.

#### Web-UI
2. Execute main.py to launch the Python backend rewriter component.
```
$ python main.py
```
3. Execute the Java backend parser component through command `java -jar sparksql-plus-web-jar-with-dependencies.jar` build from `SparkSQLPlus`, which is included as a submodule. [Option] You can also build `jar` file by yourself. 
4. Please use the following command to init and update it. 
```
$ git submodule init
$ git submodule update [--remote]
    or
$ git submodule update --init --recursive
```
5. Open the webpage at `http://localhost:8848`.
6. Begin submitting queries for execution on the webpage.

#### Command Line [Default]
2. Modify python path (`PYTHON_ENV`) in `auto_rewrite.sh`.
3. Execute the following command to get the rewrite querys. The rewrite time is shown in `rewrite_time.txt`
4. OPTIONS
- Mode: Set generate code mode D(DuckDB)/M(MySql) [default: D]
- Yannakakis/Yannakakis-Plus
: Set Y for Yannakakis; N for Yannakakis-Plus
 [default: N]
```
$ bash start_parser.sh
$ Parser started.
$ ./auto_rewrite.sh ${DDL_NAME} ${QUERY_DIR} [OPTIONS]
e.g ./auto_rewrite.sh lsqb lsqb M N
```
5. Modify configurations in `query/load_XXX.sql` (load table schemas) and `query/auto_run_XXX.sh` (auto-run script for different DBMSs). 
6. Execute the following command to execute the queries in different DBMSs.
```
$ ./auto_run_XXX.sh [OPTIONS]
```
7. If you want to run a single query, please change the code commented `# NOTE: single query keeps here` in function `init_global_vars` (Line `587` - Line `589` in `main.py`), and comment the code block labeled `# NOTE: auto-rewrite keeps here` (the code between the two blank lines, Line `610` - Line `629` in `main.py`).


## Part2: Reproducibility of the Experiments
### Step1: DBMS Requirement Preparation
#### DuckDB 1.0: 
0. Change directory to any directory that you want to install your DuckDB
1. Download *.zip or *.tar.gz file from https://github.com/duckdb/duckdb/releases/tag/v1.0.0 
2. Extract the content and generate duckdb executable file

#### PostgreSQL 16.2
0. Change directory to any directory that you want to install your PostgreSQL
1. Install PostgreSQL 16.2 according to the instructions on https://www.postgresql.org/download/
2. Create a database `test`. You may use another name for the database.
3. Make sure you can access the database by `psql -d {db_name} -U {your_name} -p {your_port}` (without a password)

#### Spark 3.5.1
0. Change directory to any directory that you want to install your Spark
1. Download Spark 3.5.1 from https://archive.apache.org/dist/spark/spark-3.5.1/
2. Extract the downloaded package
3. Set environment variables. Please ensure to modify them according to your file path.
```
export SPARK_HOME="/path/to/spark-3.5.1xxx"
export PATH="${SPARK_HOME}/bin":"${PATH}"
```

### Step2: Dataset Download
#### Graph data
Run `bash download_graph.sh` to download a graph from [SNAP](https://snap.stanford.edu/). It is also possible to use other input data as long as the columns are separated by commas.

#### LSQB data
##### Choice 1: generate by yourself from official site
1. Clone lsqb dataset generate tool from https://github.com/ldbc/lsqb
2. Follow the instruction and generate the scale factor = 30 data result
##### Choice 2: download directly from the cloud storage (~13G)
1. Please download from [lsqb_30](https://hkustconnect-my.sharepoint.com/:f:/g/personal/bchenba_connect_ust_hk/EnqiyJpKU9pLiFhye6B1wc4B33IU2CqRfMoEM31hF9WrBg?e=eE542e). 

#### TPC-H data
##### Choice 1: generate by yourself from official site
1. Clone TPC-H dataset generation tool from https://www.tpc.org/tpc_documents_current_versions/current_specifications5.asp
2. Follow the instruction and generate the scale factor = 100 data result
##### Choice 2: download directly from the cloud storage (~108G)
1. Please download from [tpch_100](https://hkustconnect-my.sharepoint.com/:f:/g/personal/bchenba_connect_ust_hk/EsAuPFzXcb9GpfP143xOPmMBJjga6agVX05bF99ztqNxsQ?e=lOkorH)

#### JOB data
##### Choice 1: download from script (~3.7G, scale=1)
1. Run `bash download_job.sh` to download job data from [DuckDB Support](https://github.com/duckdb/duckdb/blob/main/benchmark/imdb/init/load.sql)
##### Choice 2: download directly from the cloud storage (take some time ~242G, scale=100)
1. Please download from [job_100](https://hkustconnect-my.sharepoint.com/:f:/g/personal/bchenba_connect_ust_hk/EsAuPFzXcb9GpfP143xOPmMBJjga6agVX05bF99ztqNxsQ?e=lOkorH)

### Step3: Database Initialization
#### DuckDB
1. Make sure you have already created the experiemente data in the previous steps
2. Locate to the duckdb installed location and execute `duckdb` to get into duckdb environment. 
3. Load data. 
- Graph data: execute `.open graph_db`. Change `PATH_TO_GRAPH_DATA` to your download graph data and execute queries in `query/load_graph.sql`
- LSQB data: execute `.open lsqb_db`. Change `PATH_TO_LSQB_DATA` to your download lsqb data and execute queries in `query/load_lsqb.sql`
- TPC-H data: execute `.open tpch_db`. Change `PATH_TO_TPCH_DATA` to your download tpch data and execute queries in `query/load_tpch.sql`
- JOB data: execute `.open job_db`. Change `PATH_TO_JOB_DATA` to your download job data and execute queries in `query/load_job.sql`

#### PostgreSQL
1. Make sure you have already created the experiemente data in the previous steps
2. Locate to the PostgreSQL installed location and execute `postgresql-16.2/bin/psql -p ${port} -d test`
3. Load data: execute queries in `query/load_graph.sql`, `query/load_lsqb.sql`, `query/load_tpch.sql`, `query/load_job.sql`


### Step4: Run experiments
1. Change the specifications in `query/auto_run_duckdb.sh`, `query/auto_run_pg.sh`, `query/auto_run_spark.sh`. The default timeout is 2 hours. You can change the timeout part at `SIGKILL 2h xxx` in `query/auto_run_*.sh` from `2h` to `kh` (k hours), `km` (k minutes) where k is the number in [1-9].
2. Execute `query/auto_run_duckdb.sh` to run duckdb experiements, `query/auto_run_pg.sh` to run postgresql experiements, `query/auto_run_spark.sh` to run sparksql experiements.

### Step5: plot



## Part3: Extra Information [Option]
#### Structure Overview
- Web-based Interface
- Java Parser Backend
- Python Optimizer \& Rewriter Backend

#### Files
- `./query/[graph|lsqb|tpch|job]`: plans for different DBMSs
- `./query/*.sh`: auto-run scripts
- `./query/*.sql`: load data scripts
- `./query/[src|Schema]`: files for auto-run SparkSQL
- `./*.py`: code for rewriter and optimizer
- `./sparksql-plus-web-jar-with-dependencies.jar`: parser jar file

### Demonstration
#### Step 1
![Step1](1.png "Step 1")
#### Step 2
![Step2](2.png "Step 2")
#### Step 3
![Step3](3.png "Step 3")
#### Step 4
![Step4](4.png "Step 4")

#### NOTE
- For queries like `SELECT DISTINCT ...`, please remove `DISTINCT` keyword before parsing. 
- Use `jps` command to get the parser pid which name is `jar`, and then kill it. 

