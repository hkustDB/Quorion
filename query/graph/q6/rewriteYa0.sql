create or replace TEMP view g1 as select Graph.src as v7, Graph.dst as v2, v8, v10 from Graph, (SELECT src, COUNT(*) AS v8 FROM Graph GROUP BY src) AS c1, (SELECT src, COUNT(*) AS v10 FROM Graph GROUP BY src) AS c2 where Graph.src = c1.src and Graph.src = c2.src and v8<2;
create or replace TEMP view semiUp35929722489652416 as select src as v2, dst as v4 from Graph AS g2 where (src) in (select (v2) from g1);
create or replace TEMP view semiUp2638079363265377776 as select src as v4, dst as v6 from Graph AS g3 where (src) in (select (v4) from semiUp35929722489652416);
create or replace TEMP view semiDown6279294213293106105 as select v2, v4 from semiUp35929722489652416 where (v4) in (select (v4) from semiUp2638079363265377776);
create or replace TEMP view semiDown8582494326459718208 as select v7, v2, v8, v10 from g1 where (v2) in (select (v2) from semiDown6279294213293106105);
create or replace TEMP view joinView7496631532026641525 as select v4, v7, v8, v10 from semiDown6279294213293106105 join semiDown8582494326459718208 using(v2);
create or replace TEMP view joinView8875283864195792622 as select v6, v7, v8, v10 from semiUp2638079363265377776 join joinView7496631532026641525 using(v4);
select distinct v7, v6, v8, v10 from joinView8875283864195792622;
