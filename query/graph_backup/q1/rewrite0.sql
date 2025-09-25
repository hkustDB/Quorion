create or replace TEMP view aggView269435917825946857 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin2079077059131539240 as select dst as v4, annot from Graph as g2, aggView269435917825946857 where g2.src=aggView269435917825946857.v2;
create or replace TEMP view aggView42358071165488922 as select v4, SUM(annot) as annot from aggJoin2079077059131539240 group by v4;
create or replace TEMP view aggJoin6140485408462715328 as select dst as v6, annot from Graph as g3, aggView42358071165488922 where g3.src=aggView42358071165488922.v4;
create or replace TEMP view aggView4267407045040460666 as select v6, SUM(annot) as annot from aggJoin6140485408462715328 group by v6;
create or replace TEMP view aggJoin1457498697224388229 as select annot from Graph as g4, aggView4267407045040460666 where g4.src=aggView4267407045040460666.v6;
select SUM(annot) as v9 from aggJoin1457498697224388229;
