create or replace TEMP view aggView4630874567968124305 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin4063767316721570437 as select dst as v4, annot from Graph as g2, aggView4630874567968124305 where g2.src=aggView4630874567968124305.v2;
create or replace TEMP view aggView7009673930162217239 as select v4, SUM(annot) as annot from aggJoin4063767316721570437 group by v4;
create or replace TEMP view aggJoin7980387570204844181 as select dst as v6, annot from Graph as g3, aggView7009673930162217239 where g3.src=aggView7009673930162217239.v4;
create or replace TEMP view aggView8691320315640723742 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin991580905465714695 as select aggJoin7980387570204844181.annot * aggView8691320315640723742.annot as annot from aggJoin7980387570204844181 join aggView8691320315640723742 using(v6);
select SUM(annot) as v9 from aggJoin991580905465714695;
