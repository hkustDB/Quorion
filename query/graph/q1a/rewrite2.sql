create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v8<2;
create or replace TEMP view semiJoinView2416939999236253711 as select src as v2, dst as v4 from Graph AS g2 where (src) in (select (v2) from g1);
create or replace TEMP view g3 as select Graph.src as v4, Graph.dst as v6, v10 from Graph, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.dst = c2.src;
create or replace TEMP view semiJoinView8566711930946408482 as select v2, v4 from semiJoinView2416939999236253711 where (v4) in (select (v4) from g3);
create or replace TEMP view semiEnum8450268277554207602 as select v6, v10, v2, v4 from semiJoinView8566711930946408482 join g3 using(v4);
create or replace TEMP view semiEnum109167625753376187 as select v6, v10, v7, v2, v8, v4 from semiEnum8450268277554207602 join g1 using(v2);
select v7, v2, v4, v6, v8, v10 from semiEnum109167625753376187;
