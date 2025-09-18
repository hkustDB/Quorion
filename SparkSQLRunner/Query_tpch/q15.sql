create or replace TEMP view aq15_innerC as select max(total_revenue) as max_tr from revenue0;
CREATE OR REPLACE TEMP VIEW revenue0 AS
SELECT l_suppkey AS supplier_no, SUM(l_extendedprice * (1 - l_discount)) AS total_revenue
FROM lineitem
WHERE l_shipdate >= DATE '1995-02-01' AND l_shipdate < DATE '1995-05-01'
GROUP BY l_suppkey;
select distinct s_suppkey, s_name, s_address, s_phone, total_revenue
from supplier, revenue0, aq15_innerC
where s_suppkey = supplier_no
  and total_revenue = aq15_innerC.max_tr