create or replace TEMP view hq20_inner2p as 
SELECT 0.5 * SUM(l_quantity) as v2_quantity_sum FROM lineitem, spartsuppT
WHERE l_partkey = ps_partkey
	AND l_suppkey = ps_suppkey
	AND l_shipdate >= DATE '1994-01-01'
	AND l_shipdate < DATE '1995-01-01';
create or replace TEMP view mq20_inner1N as SELECT p_partkey as v1_partkey FROM part WHERE p_name LIKE 'forest%';
SELECT distinct ps_suppkey
FROM spartsuppT, mq20_inner1N, hq20_inner2p
WHERE ps_partkey = v1_partkey
  AND ps_availqty > v2_quantity_sum