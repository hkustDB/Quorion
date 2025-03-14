SELECT  p_brand, p_type, p_size, COUNT(ps_suppkey) AS supplier_cnt
FROM    partsupp, part
WHERE   p_partkey = ps_partkey
  AND   p_brand <> 'Brand#45'
  AND   (p_type NOT LIKE 'MEDIUM POLISHED%')
  AND   (p_size IN (49, 14, 23, 45, 19, 3, 36, 9))
GROUP BY p_brand, p_type, p_size
