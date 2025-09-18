create or replace TEMP view hq20_inner2p as 
SELECT 0.5 * SUM(l_quantity) as v2_quantity_sum FROM lineitem, spartsuppT
WHERE l_partkey = ps_partkey
	AND l_suppkey = ps_suppkey
	AND l_shipdate >= DATE '1994-01-01'
	AND l_shipdate < DATE '1995-01-01';
create or replace TEMP view mq20_inner1N as SELECT p_partkey as v1_partkey FROM part WHERE p_name LIKE 'forest%';
create or replace TEMP view bag757137 as select mq20_inner1N.v1_partkey as v1, spartsuppT.ps_suppkey as v2, spartsuppT.ps_availqty as v3, spartsuppT.ps_supplycost as v4, spartsuppT.ps_comment as v5 from mq20_inner1N as mq20_inner1N, spartsuppT as spartsuppT where mq20_inner1N.v1_partkey=spartsuppT.ps_partkey;
create or replace TEMP view bag757137Aux54 as select v2, v3 from bag757137;
create or replace TEMP view minView7690588047090578398 as select v2_quantity_sum as mfR8885372654007618366 from hq20_inner2p;
create or replace TEMP view joinView8596146146756564698 as select distinct v2 from bag757137Aux54, minView7690588047090578398 where v3>mfR8885372654007618366;
select distinct v2 from joinView8596146146756564698;
