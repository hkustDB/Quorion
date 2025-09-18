create or replace TEMP view aggView3266245058538738434 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin7671301279887633110 as select dst as v4, annot from Graph as g2, aggView3266245058538738434 where g2.src=aggView3266245058538738434.v2;
create or replace TEMP view aggView7144959769338473041 as select v4, SUM(annot) as annot from aggJoin7671301279887633110 group by v4;
create or replace TEMP view aggJoin1696270384340114909 as select dst as v6, annot from Graph as g3, aggView7144959769338473041 where g3.src=aggView7144959769338473041.v4;
create or replace TEMP view aggView8664294249189795214 as select v6, SUM(annot) as annot from aggJoin1696270384340114909 group by v6;
create or replace TEMP view aggJoin2714678809212121136 as select annot from Graph as g4, aggView8664294249189795214 where g4.src=aggView8664294249189795214.v6;
select SUM(annot) as v9 from aggJoin2714678809212121136;
