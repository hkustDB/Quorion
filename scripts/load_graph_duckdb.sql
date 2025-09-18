drop table if exists graph;
CREATE TABLE graph (src int, dst int);
COPY graph FROM '../graph_data/epinions.txt' (DELIMITER '\t');

drop table if exists bitcoin;
CREATE TABLE bitcoin AS SELECT column0::INT AS src, column1::INT AS dst, column2::INT AS weight FROM read_csv_auto('../graph_data/bitcoin.txt', delim=',', header=False);

drop table if exists dblp;
CREATE TABLE dblp (src int, dst int);
COPY dblp FROM '../graph_data/dblp.txt' (DELIMITER '\t');

drop table if exists google;
CREATE TABLE google (src int, dst int);
COPY google FROM '../graph_data/google.txt' (DELIMITER '\t');