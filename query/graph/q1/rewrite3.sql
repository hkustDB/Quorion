create or replace TEMP view aggView930993825633817413 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin4243351655890247901 as select dst as v4, annot from Graph as g2, aggView930993825633817413 where g2.src=aggView930993825633817413.v2;
create or replace TEMP view aggView8102670233245012057 as select v4, SUM(annot) as annot from aggJoin4243351655890247901 group by v4;
create or replace TEMP view aggJoin2412903387296732192 as select dst as v6, annot from Graph as g3, aggView8102670233245012057 where g3.src=aggView8102670233245012057.v4;
create or replace TEMP view aggView8395282997007837593 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin7046773518043505424 as select aggJoin2412903387296732192.annot * aggView8395282997007837593.annot as annot from aggJoin2412903387296732192 join aggView8395282997007837593 using(v6);
select SUM(annot) as v9 from aggJoin7046773518043505424;
