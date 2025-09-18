create or replace TEMP view bq17_innerD as select l_partkey as v1_partkey, 0.2 * AVG(l_quantity) as v1_quantity_avg from lineitem l2 group by l_partkey;
SELECT SUM(l_extendedprice) / 7.0 AS avg_yearly
FROM lineitem, part, bq17_innerD
WHERE p_partkey = l_partkey
  AND p_brand = 'Brand#23'
  AND p_container = 'MED BOX'
  AND l_partkey = v1_partkey
  AND l_quantity > v1_quantity_avg