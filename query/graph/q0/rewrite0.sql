create or replace view g1 as select Graph.src as v7, Graph.dst as v2, v8 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v8<2;
create or replace view semiJoinView5236685962755733774 as select src as v2, dst as v4 from Graph AS g2 where (src) in (select (v2) from g1);
create or replace view g3 as select Graph.src as v4, Graph.dst as v6, v10 from Graph, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.dst = c2.src;
create or replace view semiJoinView141139103510509388 as select v2, v4 from semiJoinView5236685962755733774 where (v4) in (select (v4) from g3);
create or replace view semiEnum1520294693894372834 as select v2, v10, v4, v6 from semiJoinView141139103510509388 join g3 using(v4);
create or replace view semiEnum6053571187121356614 as select v2, v10, v4, v8, v6, v7 from semiEnum1520294693894372834 join g1 using(v2);
select v7, v2, v4, v6, v8, v10 from semiEnum6053571187121356614;