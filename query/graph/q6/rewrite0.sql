create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8, v10 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.src = c1.src and Graph.src = c2.src and v8<2;
create or replace TEMP view semiJoinView6455717055819617244 as select src as v2, dst as v4 from Graph AS g2 where (src) in (select (v2) from g1);
create or replace TEMP view semiJoinView3769987700147025788 as select distinct src as v4, dst as v6 from Graph AS g3 where (src) in (select (v4) from semiJoinView6455717055819617244);
create or replace TEMP view semiEnum7151980947516615143 as select distinct v2, v6 from semiJoinView3769987700147025788 join semiJoinView6455717055819617244 using(v4);
create or replace TEMP view semiEnum5717348996905463674 as select v8, v6, v7, v10 from semiEnum7151980947516615143 join g1 using(v2);
select distinct v7, v6, v8, v10 from semiEnum5717348996905463674;
