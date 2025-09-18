create or replace TEMP view sorderswithyearT as select orders.*, year(o_orderdate) AS o_year from orders;
SELECT n_name, o_year, SUM(l_extendedprice * (1 - l_discount)) as sum_total, SUM(ps_supplycost * l_quantity) AS cost
FROM part, supplier, lineitem, spartsuppT, sorderswithyearT, nation
WHERE s_suppkey = l_suppkey
	AND ps_suppkey = l_suppkey
	AND ps_partkey = l_partkey
	AND p_partkey = l_partkey
	AND o_orderkey = l_orderkey
	AND s_nationkey = n_nationkey
	AND p_name LIKE '%green%'
GROUP BY n_name, o_year