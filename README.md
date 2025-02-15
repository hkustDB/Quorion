# Quorion: Robust Query Optimizer with Theoretical Guarantees


### Requirements
- Java JDK or JRE(Java Runtime Environment). 
- Python version >= 3.9
- Python package requirements: docopt, requests, flask, openpyxl

### Steps
1. Execute main.py to launch the Python backend rewriter component.
```
$ python main.py
```
2. Execute the Java backend parser component, following repo `https://github.com/ChampionNan/SparkSQLPlus/tree/demo`
3. Open the webpage at `http://localhost:8848`.
4. Begin submitting queries for execution on the webpage.

### Structure
- Web-based Interface
- Java Parser Backend
- Python Optimizer \& Rewriter Backend

### Demonstration
#### Step 1
![Step1](1.png "Step 1")
#### Step 2
![Step2](2.png "Step 2")
#### Step 3
![Step3](3.png "Step 3")
#### Step 4
![Step4](4.png "Step 4")


