create or replace TEMP view aggView1682649967448940480 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin6198769729997326584 as select src as v4, annot from Graph as g3, aggView1682649967448940480 where g3.dst=aggView1682649967448940480.v6;
create or replace TEMP view aggView703697881387704777 as select v4, SUM(annot) as annot from aggJoin6198769729997326584 group by v4;
create or replace TEMP view aggJoin6003205793794102013 as select src as v2, annot from Graph as g2, aggView703697881387704777 where g2.dst=aggView703697881387704777.v4;
create or replace TEMP view aggView2946527300997848545 as select v2, SUM(annot) as annot from aggJoin6003205793794102013 group by v2;
create or replace TEMP view aggJoin220812856171467610 as select annot from Graph as g1, aggView2946527300997848545 where g1.dst=aggView2946527300997848545.v2;
select SUM(annot) as v9 from aggJoin220812856171467610;
