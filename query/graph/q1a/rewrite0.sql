create or replace TEMP view aggView4280812133095911007 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin8511361725447380230 as select dst as v4, annot from Graph as g2, aggView4280812133095911007 where g2.src=aggView4280812133095911007.v2;
create or replace TEMP view aggView6546347043955258053 as select v4, SUM(annot) as annot from aggJoin8511361725447380230 group by v4;
create or replace TEMP view aggJoin691152132561831385 as select dst as v6, annot from Graph as g3, aggView6546347043955258053 where g3.src=aggView6546347043955258053.v4;
create or replace TEMP view aggView7273221731784675269 as select v6, SUM(annot) as annot from aggJoin691152132561831385 group by v6;
create or replace TEMP view aggJoin4871135739999705359 as select annot from Graph as g4, aggView7273221731784675269 where g4.src=aggView7273221731784675269.v6;
select SUM(annot) as v9 from aggJoin4871135739999705359;
