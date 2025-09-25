DROP TABLE IF EXISTS nation;
CREATE TABLE nation (
    n_nationkey INTEGER NOT NULL,
    n_name CHAR(25) NOT NULL,
    n_regionkey INTEGER NOT NULL,
    n_comment VARCHAR(152)
);
COPY nation FROM '/PATH_TO_TPCH_DATA/nation.tbl' WITH (FORMAT csv, DELIMITER '|');

DROP TABLE IF EXISTS region;
CREATE TABLE region (
    r_regionkey INTEGER NOT NULL,
    r_name CHAR(25) NOT NULL,
    r_comment VARCHAR(152)
);
COPY region FROM '/PATH_TO_TPCH_DATA/region.tbl' WITH (FORMAT csv, DELIMITER '|');

DROP TABLE IF EXISTS part;
CREATE TABLE part (
    p_partkey INTEGER NOT NULL,
    p_name VARCHAR(55) NOT NULL,
    p_mfgr CHAR(25) NOT NULL,
    p_brand CHAR(10) NOT NULL,
    p_type VARCHAR(25) NOT NULL,
    p_size INTEGER NOT NULL,
    p_container CHAR(10) NOT NULL,
    p_retailprice DECIMAL(15,2) NOT NULL,
    p_comment VARCHAR(23) NOT NULL
);
COPY part FROM '/PATH_TO_TPCH_DATA/part.tbl' WITH (FORMAT csv, DELIMITER '|');

DROP TABLE IF EXISTS supplier;
CREATE TABLE supplier (
    s_suppkey INTEGER NOT NULL,
    s_name CHAR(25) NOT NULL,
    s_address VARCHAR(40) NOT NULL,
    s_nationkey INTEGER NOT NULL,
    s_phone CHAR(15) NOT NULL,
    s_acctbal DECIMAL(15,2) NOT NULL,
    s_comment VARCHAR(101) NOT NULL
);
COPY supplier FROM '/PATH_TO_TPCH_DATA/supplier.tbl' WITH (FORMAT csv, DELIMITER '|');

DROP TABLE IF EXISTS partsupp;
CREATE TABLE partsupp (
    ps_partkey INTEGER NOT NULL,
    ps_suppkey INTEGER NOT NULL,
    ps_availqty INTEGER NOT NULL,
    ps_supplycost DECIMAL(15,2) NOT NULL,
    ps_comment VARCHAR(199) NOT NULL
);
COPY partsupp FROM '/PATH_TO_TPCH_DATA/partsupp.tbl' WITH (FORMAT csv, DELIMITER '|');

DROP TABLE IF EXISTS customer;
CREATE TABLE customer (
    c_custkey INTEGER NOT NULL,
    c_name VARCHAR(25) NOT NULL,
    c_address VARCHAR(40) NOT NULL,
    c_nationkey INTEGER NOT NULL,
    c_phone CHAR(15) NOT NULL,
    c_acctbal DECIMAL(15,2) NOT NULL,
    c_mktsegment CHAR(10) NOT NULL,
    c_comment VARCHAR(117) NOT NULL
);
COPY customer FROM '/PATH_TO_TPCH_DATA/customer.tbl' WITH (FORMAT csv, DELIMITER '|');

DROP TABLE IF EXISTS orders;
CREATE TABLE orders (
    o_orderkey BIGINT NOT NULL,
    o_custkey INT NOT NULL,
    o_orderstatus VARCHAR NOT NULL,
    o_totalprice DECIMAL(15,2) NOT NULL,
    o_orderdate DATE NOT NULL,
    o_orderpriority VARCHAR NOT NULL,
    o_clerk VARCHAR NOT NULL,
    o_shippriority INT NOT NULL,
    o_comment VARCHAR NOT NULL,
    dummy VARCHAR
);
COPY orders FROM '/PATH_TO_TPCH_DATA/orders.tbl' WITH (FORMAT csv, DELIMITER '|');

DROP TABLE IF EXISTS lineitem;
CREATE TABLE lineitem (
    l_orderkey BIGINT NOT NULL,
    l_partkey INT NOT NULL,
    l_suppkey INT NOT NULL,
    l_linenumber INT NOT NULL,
    l_quantity DECIMAL(15,2) NOT NULL,
    l_extendedprice DECIMAL(15,2) NOT NULL,
    l_discount DECIMAL(15,2) NOT NULL,
    l_tax DECIMAL(15,2) NOT NULL,
    l_returnflag VARCHAR NOT NULL,
    l_linestatus VARCHAR NOT NULL,
    l_shipdate DATE NOT NULL,
    l_commitdate DATE NOT NULL,
    l_receiptdate DATE NOT NULL,
    l_shipinstruct VARCHAR NOT NULL,
    l_shipmode VARCHAR NOT NULL,
    l_comment VARCHAR NOT NULL,
    dummy VARCHAR
);
COPY lineitem FROM '/PATH_TO_TPCH_DATA/lineitem.tbl' WITH (FORMAT csv, DELIMITER '|');

-- Views
CREATE OR REPLACE VIEW q2_inner AS
SELECT ps_partkey AS v1_partkey, MIN(ps_supplycost) AS v1_supplycost_min
FROM partsupp
JOIN supplier ON s_suppkey = ps_suppkey
JOIN nation   ON s_nationkey = n_nationkey
JOIN region   ON n_regionkey = r_regionkey
WHERE r_name = 'EUROPE'
GROUP BY ps_partkey;

CREATE OR REPLACE VIEW orderswithyear AS
SELECT orders.*, EXTRACT(YEAR FROM o_orderdate) AS o_year
FROM orders;

CREATE OR REPLACE VIEW lineitemwithyear AS
SELECT lineitem.*, EXTRACT(YEAR FROM l_shipdate) AS l_year
FROM lineitem;

CREATE OR REPLACE VIEW revenue0 (supplier_no, total_revenue) AS
SELECT l_suppkey, SUM(l_extendedprice * (1 - l_discount))
FROM lineitem
WHERE l_shipdate >= DATE '1995-02-01'
  AND l_shipdate < DATE '1995-05-01'
GROUP BY l_suppkey;

CREATE OR REPLACE VIEW q15_inner AS
SELECT MAX(total_revenue) AS max_tr FROM revenue0;

CREATE OR REPLACE VIEW q17_inner AS
SELECT l_partkey AS v1_partkey, 0.2 * AVG(l_quantity) AS v1_quantity_avg
FROM lineitem l2
GROUP BY l_partkey;

CREATE OR REPLACE VIEW q18_inner AS
SELECT l_orderkey AS v1_orderkey
FROM lineitem l2
GROUP BY l_orderkey
HAVING SUM(l_quantity) > 312;

CREATE OR REPLACE VIEW q20_inner1 AS
SELECT p_partkey AS v1_partkey
FROM part
WHERE p_name LIKE 'forest%';

CREATE OR REPLACE VIEW q20_inner2 AS
SELECT 0.5 * SUM(l_quantity) AS v2_quantity_sum
FROM lineitem
JOIN partsupp ON l_partkey = ps_partkey AND l_suppkey = ps_suppkey
WHERE l_shipdate >= DATE '1994-01-01'
  AND l_shipdate < DATE '1995-01-01';