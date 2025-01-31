create or replace TEMP view aggView9082596949540442482 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin6931003692779752994 as select dst as v4, annot from Graph as g2, aggView9082596949540442482 where g2.src=aggView9082596949540442482.v2;
create or replace TEMP view aggView6504696165820117860 as select v4, SUM(annot) as annot from aggJoin6931003692779752994 group by v4;
create or replace TEMP view aggJoin1513566499196528627 as select dst as v6, annot from Graph as g3, aggView6504696165820117860 where g3.src=aggView6504696165820117860.v4;
create or replace TEMP view aggView6926783756589803232 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin6143230716167542356 as select aggJoin1513566499196528627.annot * aggView6926783756589803232.annot as annot from aggJoin1513566499196528627 join aggView6926783756589803232 using(v6);
select SUM(annot) as v9 from aggJoin6143230716167542356;
