create or replace TEMP view aggView7228222146182861307 as select c_custkey as v1 from customer as customer where (c_mktsegment = 'BUILDING');
create or replace TEMP view aggJoin3251727330281207777 as select o_orderkey as v18, o_orderdate as v13, o_shippriority as v16 from orders as orders, aggView7228222146182861307 where orders.o_custkey=aggView7228222146182861307.v1 and (o_orderdate < DATE '1995-03-15');
create or replace TEMP view aggView2605213868881410542 as select v13, v16, v18, COUNT(*) as annot from aggJoin3251727330281207777 group by v13,v16,v18;
create or replace TEMP view aggView807885338981725687 as select l_orderkey as v18, SUM(l_extendedprice * (1 - l_discount)) as v35 from lineitem as lineitem where (l_shipdate > DATE '1995-03-15') group by l_orderkey;
create or replace TEMP view aggJoin6284009340407856481 as select v13, v16, v18, v35 * aggView2605213868881410542.annot as v35 from aggView2605213868881410542 join aggView807885338981725687 using(v18);
select v18,SUM(v35) as v35,v13,v16 from aggJoin6284009340407856481 group by v18, v13, v16;
