create or replace TEMP view aggView7295624547500116670 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin5865580628666457568 as select src as v4, annot from Graph as g3, aggView7295624547500116670 where g3.dst=aggView7295624547500116670.v6;
create or replace TEMP view aggView8012605638608204991 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin3768813209584700400 as select dst as v4, annot from Graph as g2, aggView8012605638608204991 where g2.src=aggView8012605638608204991.v2;
create or replace TEMP view aggView4197842952663064166 as select v4, SUM(annot) as annot from aggJoin5865580628666457568 group by v4;
create or replace TEMP view aggJoin5131148697220662314 as select aggJoin3768813209584700400.annot * aggView4197842952663064166.annot as annot from aggJoin3768813209584700400 join aggView4197842952663064166 using(v4);
select SUM(annot) as v9 from aggJoin5131148697220662314;
