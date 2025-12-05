
create or replace TEMP view aggJoin4796377750650424153 as select s_suppkey as v2 from supplier as supplier, nation where n_name= 'GERMANY' and supplier.s_nationkey=nation.n_nationkey;
select ps_partkey as v1, SUM(ps_availqty*ps_supplycost) from spartsuppT as spartsuppT, aggJoin4796377750650424153 where spartsuppT.ps_suppkey=aggJoin4796377750650424153.v2 group by ps_partkey;
