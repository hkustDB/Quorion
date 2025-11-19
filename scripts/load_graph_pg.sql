DROP TABLE IF EXISTS graph;
CREATE TABLE graph (src integer, dst integer);
COPY graph FROM '/home/data/bchenba/Quorion/Data/graph/epinions.txt' WITH (FORMAT csv, DELIMITER E'\t');

DROP TABLE IF EXISTS bitcoin;
CREATE TABLE bitcoin (src integer, dst integer, weight integer, ts integer);
COPY bitcoin (src, dst, weight, ts) 
FROM '/home/data/bchenba/Quorion/Data/graph/bitcoin.txt' 
WITH (FORMAT csv, DELIMITER ',', HEADER false);

DROP TABLE IF EXISTS dblp;
CREATE TABLE dblp (src integer, dst integer);
COPY dblp FROM '/home/data/bchenba/Quorion/Data/graph/dblp.txt' WITH (FORMAT csv, DELIMITER E'\t');

DROP TABLE IF EXISTS google;
CREATE TABLE google (src integer, dst integer);
COPY google FROM '/home/data/bchenba/Quorion/Data/graph/google.txt' WITH (FORMAT csv, DELIMITER E'\t');