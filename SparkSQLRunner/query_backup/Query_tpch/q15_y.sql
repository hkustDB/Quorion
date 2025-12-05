create or replace TEMP view aq15_innerC as select max(total_revenue) as max_tr from revenue0;
CREATE OR REPLACE TEMP VIEW revenue0 AS
SELECT l_suppkey AS supplier_no, SUM(l_extendedprice * (1 - l_discount)) AS total_revenue
FROM lineitem
WHERE l_shipdate >= DATE '1995-02-01' AND l_shipdate < DATE '1995-05-01'
GROUP BY l_suppkey;
create or replace TEMP view supplierAux13 as select s_suppkey as v1, s_name as v2, s_address as v3, s_phone as v5 from supplier;
create or replace TEMP view semiUp3377903699478884 as select supplier_no as v1, total_revenue as v9 from revenue0 AS revenue0 where (total_revenue) in (select max_tr from aq15_innerC AS aq15_innerC);
create or replace TEMP view semiUp6564381296622194419 as select v1, v9 from semiUp3377903699478884 where (v1) in (select v1 from supplierAux13);
create or replace TEMP view semiDown2027129292393532442 as select max_tr as v9 from aq15_innerC AS aq15_innerC where (max_tr) in (select v9 from semiUp6564381296622194419);
create or replace TEMP view semiDown2330546438356527676 as select v1, v2, v3, v5 from supplierAux13 where (v1) in (select v1 from semiUp6564381296622194419);
create or replace TEMP view semiDown655475494258709756 as select s_suppkey as v1, s_name as v2, s_address as v3, s_phone as v5 from supplier AS supplier where (s_name, s_suppkey, s_phone, s_address) in (select v2, v1, v5, v3 from semiDown2330546438356527676);
create or replace TEMP view joinView8593737681759130597 as select v1, v2, v3, v5 from semiDown2330546438356527676 join semiDown655475494258709756 using(v2, v1, v5, v3);
create or replace TEMP view joinView4496298048680707857 as select v1, v9 from semiUp6564381296622194419 join semiDown2027129292393532442 using(v9);
create or replace TEMP view joinView6687234065084173200 as select v1, v9, v2, v3, v5 from joinView4496298048680707857 join joinView8593737681759130597 using(v1);
select distinct v1, v2, v3, v5, v9 from joinView6687234065084173200;
