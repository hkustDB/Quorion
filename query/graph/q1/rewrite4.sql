create or replace TEMP view aggView6373649387603250972 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin4341546725900337015 as select src as v4, annot from Graph as g3, aggView6373649387603250972 where g3.dst=aggView6373649387603250972.v6;
create or replace TEMP view aggView8476853619264029382 as select v4, SUM(annot) as annot from aggJoin4341546725900337015 group by v4;
create or replace TEMP view aggJoin2714923138649429111 as select src as v2, annot from Graph as g2, aggView8476853619264029382 where g2.dst=aggView8476853619264029382.v4;
create or replace TEMP view aggView3026164970095856725 as select v2, SUM(annot) as annot from aggJoin2714923138649429111 group by v2;
create or replace TEMP view aggJoin1214117910059947434 as select annot from Graph as g1, aggView3026164970095856725 where g1.dst=aggView3026164970095856725.v2;
select SUM(annot) as v9 from aggJoin1214117910059947434;
