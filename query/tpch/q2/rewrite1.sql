create or replace TEMP view aggView6081259694404524119 as select o_orderkey as v10, o_orderpriority as v6 from orders as orders where (o_orderdate >= DATE '1993-07-01') and (o_orderdate < DATE '1993-10-01');
create or replace TEMP view aggJoin2923810140992231511 as select l_commitdate as v21, l_receiptdate as v22, v6 from lineitem as lineitem, aggView6081259694404524119 where lineitem.l_orderkey=aggView6081259694404524119.v10 and (l_commitdate < l_receiptdate);
select v6,COUNT(*) as v26 from aggJoin2923810140992231511 group by v6;
