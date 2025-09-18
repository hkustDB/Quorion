create or replace TEMP view aggView2768738351225156525 as select src as v6, SUM(dst) as v10, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin3723599505454759213 as select src as v4, dst as v6, v10, annot from Graph as g3, aggView2768738351225156525 where g3.dst=aggView2768738351225156525.v6;
create or replace TEMP view aggView7746040367779130358 as select v4, SUM(v10) as v10, SUM(v6 * annot) as v9, SUM(annot) as annot from aggJoin3723599505454759213 group by v4;
create or replace TEMP view aggJoin5415993294626377845 as select src as v2, v10, v9, annot from Graph as g2, aggView7746040367779130358 where g2.dst=aggView7746040367779130358.v4;
create or replace TEMP view aggView4046229464162677587 as select v2, SUM(v10) as v10, SUM(v9) as v9, SUM(annot) as annot from aggJoin5415993294626377845 group by v2;
create or replace TEMP view aggView8172407818095724687 as select dst as v2, SUM(src) as v11, COUNT(*) as annot from Graph as g1 group by dst;
create or replace TEMP view aggJoin631114043378564868 as select v2, v10*aggView8172407818095724687.annot as v10, v9*aggView8172407818095724687.annot as v9, aggView4046229464162677587.annot * aggView8172407818095724687.annot as annot, v11 * aggView4046229464162677587.annot as v11 from aggView4046229464162677587 join aggView8172407818095724687 using(v2);
select v2,SUM(v9) as v9,SUM(v10/annot) as v10,SUM(v11/annot) as v11 from aggJoin631114043378564868 group by v2;
