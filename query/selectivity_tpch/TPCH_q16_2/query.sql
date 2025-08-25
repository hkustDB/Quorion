SELECT p_brand, p_type, p_size, COUNT(ps_suppkey) AS supplier_cnt
FROM  partsupp, part
WHERE  p_partkey = ps_partkey
AND  (p_size between 39 and 50) GROUP BY p_brand, p_type, p_size