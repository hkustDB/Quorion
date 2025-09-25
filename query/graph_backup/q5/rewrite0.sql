create or replace TEMP view g4 as select Graph.src as v7, Graph.dst as v2, v16 from Graph, (SELECT dst, COUNT(*) AS v16 FROM Graph GROUP BY dst) AS c3 where Graph.src = c3.dst and v16<3;
create or replace TEMP view semiJoinView4229390104558775812 as select src as v2, dst as v4 from Graph AS g2 where (src) in (select (v2) from g4);
create or replace TEMP view g1 as select Graph.src as v1, Graph.dst as v2, v12 from Graph, (SELECT src, COUNT(*) AS v12 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v12<3;
create or replace TEMP view semiJoinView4012994158062874237 as select v2, v4 from semiJoinView4229390104558775812 where (v2) in (select (v2) from g1);
create or replace TEMP view g3 as select Graph.src as v4, Graph.dst as v6, v14 from Graph, (SELECT src, COUNT(*) AS v14 FROM Graph GROUP BY src) AS c2 where Graph.dst = c2.src;
create or replace TEMP view semiJoinView4804619768380685531 as select v2, v4 from semiJoinView4012994158062874237 where (v4) in (select (v4) from g3);
create or replace TEMP view g5 as select Graph.src as v4, Graph.dst as v10, v18 from Graph, (SELECT dst, COUNT(*) AS v18 FROM Graph GROUP BY dst) AS c4 where Graph.dst = c4.dst;
create or replace TEMP view semiJoinView722600415494784071 as select distinct v2, v4 from semiJoinView4804619768380685531 where (v4) in (select (v4) from g5);
select distinct v2, v4 from semiJoinView722600415494784071;
