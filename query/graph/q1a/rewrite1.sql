create or replace TEMP view aggView9024957768226840889 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin5945530511992686148 as select src as v4, annot from Graph as g3, aggView9024957768226840889 where g3.dst=aggView9024957768226840889.v6;
create or replace TEMP view aggView1879936600432465345 as select v4, SUM(annot) as annot from aggJoin5945530511992686148 group by v4;
create or replace TEMP view aggJoin6768858176087856783 as select src as v2, annot from Graph as g2, aggView1879936600432465345 where g2.dst=aggView1879936600432465345.v4;
create or replace TEMP view aggView465775793804848112 as select v2, SUM(annot) as annot from aggJoin6768858176087856783 group by v2;
create or replace TEMP view aggJoin4661900044035720336 as select annot from Graph as g1, aggView465775793804848112 where g1.dst=aggView465775793804848112.v2;
select SUM(annot) as v9 from aggJoin4661900044035720336;
