create or replace TEMP view g3 as select Graph.src as v4, Graph.dst as v6, v10 from Graph, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.dst = c2.src;
create or replace TEMP view semiUp1974927929609350375 as select src as v2, dst as v4 from Graph AS g2 where (dst) in (select (v4) from g3);
create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1 where Graph.src = c1.src and v8<2;
create or replace TEMP view semiUp8795506472109821627 as select v7, v2, v8 from g1 where (v2) in (select (v2) from semiUp1974927929609350375);
create or replace TEMP view semiDown8013339747867631112 as select v2, v4 from semiUp1974927929609350375 where (v2) in (select (v2) from semiUp8795506472109821627);
create or replace TEMP view semiDown1592989299567299233 as select v4, v6, v10 from g3 where (v4) in (select (v4) from semiDown8013339747867631112);
create or replace TEMP view joinView8976457790901894091 as select v2, v4, v6, v10 from semiDown8013339747867631112 join semiDown1592989299567299233 using(v4);
create or replace TEMP view joinView8362147694811402640 as select v7, v2, v8, v4, v6, v10 from semiUp8795506472109821627 join joinView8976457790901894091 using(v2);
select v7, v2, v4, v6, v8, v10 from joinView8362147694811402640;
