create or replace TEMP view aggView8369173979894555164 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin2788876919541831078 as select src as v4, annot from Graph as g3, aggView8369173979894555164 where g3.dst=aggView8369173979894555164.v6;
create or replace TEMP view aggView667487164270784163 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin5345893749398206991 as select dst as v4, annot from Graph as g2, aggView667487164270784163 where g2.src=aggView667487164270784163.v2;
create or replace TEMP view aggView2724044990518289379 as select v4, SUM(annot) as annot from aggJoin2788876919541831078 group by v4;
create or replace TEMP view aggJoin2790909783872372994 as select aggJoin5345893749398206991.annot * aggView2724044990518289379.annot as annot from aggJoin5345893749398206991 join aggView2724044990518289379 using(v4);
select SUM(annot) as v9 from aggJoin2790909783872372994;
