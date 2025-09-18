create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v8<5;
create or replace TEMP view g2 as select Graph.src as v2, Graph.dst as v4, v12 from Graph, (SELECT src, COUNT(*) AS v12 FROM Graph GROUP BY src) AS c3 where Graph.src = c3.src;
create or replace TEMP view semiJoinView397841366028809016 as select v2, v4, v12 from g2 where (v2) in (select (v2) from g1);
create or replace TEMP view g3 as select Graph.src as v4, Graph.dst as v9, v10, v14 from Graph, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2, (SELECT dst, COUNT(*) AS v14 FROM Graph GROUP BY dst) AS c4 where Graph.dst = c2.src and Graph.dst = c4.dst;
create or replace TEMP view semiJoinView4112582185755133288 as select v4, v9, v10, v14 from g3 where (v4) in (select (v4) from semiJoinView397841366028809016);
create or replace TEMP view semiEnum1444511195982787588 as select v2, v14, v12, v4, v10, v9 from semiJoinView4112582185755133288 join semiJoinView397841366028809016 using(v4);
create or replace TEMP view semiEnum3749910171458784287 as select v2, v12, v14, v10, v8, v4, v7, v9 from semiEnum1444511195982787588 join g1 using(v2);
select v7, v2, v4, v9, v8, v10, v12, v14 from semiEnum3749910171458784287;
