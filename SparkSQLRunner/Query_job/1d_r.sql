create or replace TEMP view aggView2801604243281547873 as select id as v3 from rinfo_types as it where info= 'bottom 10 rank';
create or replace TEMP view aggJoin4733216446838201899 as select movie_id as v15 from tmovie_info_idxd as mi_idx, aggView2801604243281547873 where mi_idx.info_type_id=aggView2801604243281547873.v3;
create or replace TEMP view aggView6894622029475138148 as select v15 from aggJoin4733216446838201899 group by v15;
create or replace TEMP view aggJoin8800571948998090190 as select movie_id as v15, company_type_id as v1, note as v9 from xmovie_companiesc as mc, aggView6894622029475138148 where mc.movie_id=aggView6894622029475138148.v15 and note NOT LIKE '%(as Metro-Goldwyn-Mayer Pictures)%';
create or replace TEMP view aggView7993043554909184828 as select id as v15, title as v28, production_year as v29 from title as t where production_year>2000;
create or replace TEMP view aggJoin2418696590648294589 as select v1, v9, v28, v29 from aggJoin8800571948998090190 join aggView7993043554909184828 using(v15);
create or replace TEMP view aggView8867337515604092927 as select id as v1 from ocompany_typen as ct where kind= 'production companies';
create or replace TEMP view aggJoin650517216120546039 as select v9, v28, v29 from aggJoin2418696590648294589 join aggView8867337515604092927 using(v1);
select MIN(v9) as v27,MIN(v28) as v28,MIN(v29) as v29 from aggJoin650517216120546039;
