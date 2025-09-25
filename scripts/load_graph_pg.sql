DROP TABLE IF EXISTS graph;
CREATE TABLE graph (src integer, dst integer);
COPY graph FROM '/PATH_TO_GRAPH_DATA/epinions.txt' WITH (FORMAT csv, DELIMITER E'\t');

DROP TABLE IF EXISTS bitcoin;
CREATE TABLE bitcoin (src integer, dst integer, weight integer);
COPY bitcoin (src, dst, weight) 
FROM '/PATH_TO_GRAPH_DATA/bitcoin.txt' 
WITH (FORMAT csv, DELIMITER ',', HEADER false);

DROP TABLE IF EXISTS dblp;
CREATE TABLE dblp (src integer, dst integer);
COPY dblp FROM '/PATH_TO_GRAPH_DATA/dblp.txt' WITH (FORMAT csv, DELIMITER E'\t');

DROP TABLE IF EXISTS google;
CREATE TABLE google (src integer, dst integer);
COPY google FROM '/PATH_TO_GRAPH_DATA/google.txt' WITH (FORMAT csv, DELIMITER E'\t');