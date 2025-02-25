# Quorion: Robust Query Optimizer with Theoretical Guarantees


### Requirements
- Java JDK or JRE(Java Runtime Environment). 
- Python version >= 3.9
- Python package requirements: docopt, requests, flask, openpyxl

### Steps
0. Preprocessing[option]. For generating new statistics (`cost.csv`), we offer the DuckDB version scripts `preprocess.sh` and `gen_cost.sh`. Modify the configurations in them, and execute the following command. For web-ui, please move the generated statistics files to folder `graph/q1a/`, `tpch/q2/`, `lsqb/q1/`, and `job/1a/` respectively; for command-line operations, please move them to the specific corresponding query folders.
1. We provide two execution modes. The default mode is web-ui execution. If you need to switch, please modify the corresponding value `EXEC_MODE` at Line 777 in `main.py`.

#### Web-UI
2. Execute main.py to launch the Python backend rewriter component.
```
$ python main.py
```
3. Execute the Java backend parser component, following repo `https://github.com/ChampionNan/SparkSQLPlus/tree/demo`
4. Open the webpage at `http://localhost:8848`.
5. Begin submitting queries for execution on the webpage.

#### Command Line
2. Modify path for `python` in `auto_rewrite.sh`.
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
5. Modify configurations in `load_XXX.sql` (load table schemas) and `auto_run_XXX.sh` (auto-run script for different DBMSs). 
6. Execute the following command to execute the queries in different DBMSs.
```
$ ./auto_run_XXX.sh [OPTIONS]
```
7. If you want to run a single query, please select the code block labeled `# NOTE: code debug keep here` (Line 618 - Line 620 in `main.py`), and comment the code block labeled `# NOTE: auto-rewrite keep here` (the code between the two blank lines, Line 622 - Line 642 in `main.py`).

### Structure
#### Overview
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

