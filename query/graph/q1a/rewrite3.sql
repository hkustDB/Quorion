create or replace TEMP view aggView2264277143943039442 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin4634118655295953430 as select src as v4, annot from Graph as g3, aggView2264277143943039442 where g3.dst=aggView2264277143943039442.v6;
create or replace TEMP view aggView6490356491155711089 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin1145578292224404293 as select dst as v4, annot from Graph as g2, aggView6490356491155711089 where g2.src=aggView6490356491155711089.v2;
create or replace TEMP view aggView4345000763685112855 as select v4, SUM(annot) as annot from aggJoin4634118655295953430 group by v4;
create or replace TEMP view aggJoin7330685862595049652 as select aggJoin1145578292224404293.annot * aggView4345000763685112855.annot as annot from aggJoin1145578292224404293 join aggView4345000763685112855 using(v4);
select SUM(annot) as v9 from aggJoin7330685862595049652;
