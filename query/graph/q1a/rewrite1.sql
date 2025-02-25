create or replace TEMP view g3 as select Graph.src as v4, Graph.dst as v6, v10 from Graph, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.dst = c2.src;
create or replace TEMP view semiJoinView6754316569998934387 as select src as v2, dst as v4 from Graph AS g2 where (dst) in (select (v4) from g3);
create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v8<2;
create or replace TEMP view semiJoinView7569464101263072380 as select v7, v2, v8 from g1 where (v2) in (select (v2) from semiJoinView6754316569998934387);
create or replace TEMP view semiEnum5595102503040697549 as select v7, v2, v8, v4 from semiJoinView7569464101263072380 join semiJoinView6754316569998934387 using(v2);
create or replace TEMP view semiEnum2070469674013884064 as select v6, v10, v7, v2, v8, v4 from semiEnum5595102503040697549 join g3 using(v4);
select v7, v2, v4, v6, v8, v10 from semiEnum2070469674013884064;
