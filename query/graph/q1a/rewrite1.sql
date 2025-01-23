create or replace TEMP view aggView2576394691380028439 as select src as v6, COUNT(*) as annot from Graph as g4 group by src;
create or replace TEMP view aggJoin129063209372186716 as select src as v4, annot from Graph as g3, aggView2576394691380028439 where g3.dst=aggView2576394691380028439.v6;
create or replace TEMP view aggView8852481172596273284 as select v4, SUM(annot) as annot from aggJoin129063209372186716 group by v4;
create or replace TEMP view aggJoin3659664683207232821 as select src as v2, annot from Graph as g2, aggView8852481172596273284 where g2.dst=aggView8852481172596273284.v4;
create or replace TEMP view aggView7483306253374091945 as select v2, SUM(annot) as annot from aggJoin3659664683207232821 group by v2;
create or replace TEMP view aggJoin4212872721825612773 as select annot from Graph as g1, aggView7483306253374091945 where g1.dst=aggView7483306253374091945.v2;
select SUM(annot) as v9 from aggJoin4212872721825612773;
