create or replace TEMP view aggView4377053687188512002 as select dst as v2, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin3306996483053682863 as select dst as v4, annot from Graph as g2, aggView4377053687188512002 where g2.src=aggView4377053687188512002.v2;
create or replace TEMP view aggView2872604025856913695 as select v4, SUM(annot) as annot from aggJoin3306996483053682863 group by v4;
create or replace TEMP view aggJoin8205545332582066670 as select dst as v6, annot from Graph as g3, aggView2872604025856913695 where g3.src=aggView2872604025856913695.v4;
create or replace TEMP view aggView1995092628374737240 as select v6, SUM(annot) as annot from aggJoin8205545332582066670 group by v6;
create or replace TEMP view aggJoin3803042842056582810 as select annot from Graph as g4, aggView1995092628374737240 where g4.src=aggView1995092628374737240.v6;
select SUM(annot) as v9 from aggJoin3803042842056582810;
