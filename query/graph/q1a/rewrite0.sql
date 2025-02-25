create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v8<2;
create or replace TEMP view semiJoinView1261959558538632782 as select src as v2, dst as v4 from Graph AS g2 where (src) in (select (v2) from g1);
create or replace TEMP view g3 as select Graph.src as v4, Graph.dst as v6, v10 from Graph, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.dst = c2.src;
create or replace TEMP view semiJoinView7120623749897342383 as select v4, v6, v10 from g3 where (v4) in (select (v4) from semiJoinView1261959558538632782);
create or replace TEMP view semiEnum8518296778509446410 as select v6, v10, v2, v4 from semiJoinView7120623749897342383 join semiJoinView1261959558538632782 using(v4);
create or replace TEMP view semiEnum3821095681333997016 as select v6, v10, v7, v2, v8, v4 from semiEnum8518296778509446410 join g1 using(v2);
select v7, v2, v4, v6, v8, v10 from semiEnum3821095681333997016;
