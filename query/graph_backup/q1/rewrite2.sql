create or replace TEMP view aggView2177477725585721464 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin6686887724683012155 as select src as v4, annot from Graph as g3, aggView2177477725585721464 where g3.dst=aggView2177477725585721464.v6;
create or replace TEMP view aggView7629590082122831229 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin1857690758959862176 as select dst as v4, annot from Graph as g2, aggView7629590082122831229 where g2.src=aggView7629590082122831229.v2;
create or replace TEMP view aggView8385312910333023561 as select v4, SUM(annot) as annot from aggJoin6686887724683012155 group by v4;
create or replace TEMP view aggJoin10626765886658824 as select aggJoin1857690758959862176.annot * aggView8385312910333023561.annot as annot from aggJoin1857690758959862176 join aggView8385312910333023561 using(v4);
select SUM(annot) as v9 from aggJoin10626765886658824;
