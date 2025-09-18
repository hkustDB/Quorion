create or replace TEMP view aq15_innerC as select max(total_revenue) as max_tr from revenue0;
CREATE OR REPLACE TEMP VIEW revenue0 AS
SELECT l_suppkey AS supplier_no, SUM(l_extendedprice * (1 - l_discount)) AS total_revenue
FROM lineitem
WHERE l_shipdate >= DATE '1995-02-01' AND l_shipdate < DATE '1995-05-01'
GROUP BY l_suppkey;
create or replace TEMP view s_new as select s_suppkey, s_name, s_address, s_phone from supplier;
create or replace TEMP view rev_new as select total_revenue, supplier_no from revenue0 where total_revenue in (select max_tr from aq15_innerC);
select distinct s_suppkey, s_name, s_address, s_phone, total_revenue from s_new, rev_new where s_suppkey = supplier_no;