create or replace TEMP view aggView3862679126982363597 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin7900058366947417112 as select dst as v4, annot from Graph as g2, aggView3862679126982363597 where g2.src=aggView3862679126982363597.v2;
create or replace TEMP view aggView4021880900510186252 as select v4, SUM(annot) as annot from aggJoin7900058366947417112 group by v4;
create or replace TEMP view aggJoin4120040170062442478 as select dst as v6, annot from Graph as g3, aggView4021880900510186252 where g3.src=aggView4021880900510186252.v4;
create or replace TEMP view aggView8286856828363875469 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin9067232694733260343 as select aggJoin4120040170062442478.annot * aggView8286856828363875469.annot as annot from aggJoin4120040170062442478 join aggView8286856828363875469 using(v6);
select SUM(annot) as v9 from aggJoin9067232694733260343;
