create or replace TEMP view g3 as select Graph.src as v4, Graph.dst as v6, v10 from Graph, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.dst = c2.src;
create or replace TEMP view g3Aux66 as select v4, v6 from g3;
create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v8<3;
create or replace TEMP view semiJoinView3219579963731839243 as select src as v2, dst as v4 from Graph AS g2 where (src) in (select (v2) from g1);
create or replace TEMP view semiJoinView7181090189580670636 as select distinct v4, v6 from g3Aux66 where (v4) in (select (v4) from semiJoinView3219579963731839243);
select distinct v4, v6 from semiJoinView7181090189580670636;
