create or replace TEMP view aggView5444125463151814955 as select id as v3 from rinfo_types as it where info= 'top 250 rank';
create or replace TEMP view aggJoin3317109740096809620 as select movie_id as v15 from tmovie_info_idxd as mi_idx, aggView5444125463151814955 where mi_idx.info_type_id=aggView5444125463151814955.v3;
create or replace TEMP view aggView1677475375120014564 as select v15 from aggJoin3317109740096809620 group by v15;
create or replace TEMP view aggJoin6643400305341799612 as select movie_id as v15, company_type_id as v1, note as v9 from xmovie_companiesc as mc, aggView1677475375120014564 where mc.movie_id=aggView1677475375120014564.v15 and note NOT LIKE '%(as Metro-Goldwyn-Mayer Pictures)%' and ((note LIKE '%(co-production)%') OR (note LIKE '%(presents)%'));
create or replace TEMP view aggView756924113092613098 as select id as v1 from ocompany_typen as ct where kind= 'production companies';
create or replace TEMP view aggJoin206350773245404905 as select v15, v9 from aggJoin6643400305341799612 join aggView756924113092613098 using(v1);
create or replace TEMP view aggView3091575384486404650 as select id as v15, title as v28, production_year as v29 from title as t;
create or replace TEMP view aggJoin3281908045188086306 as select v9, v28, v29 from aggJoin206350773245404905 join aggView3091575384486404650 using(v15);
select MIN(v9) as v27,MIN(v28) as v28,MIN(v29) as v29 from aggJoin3281908045188086306;
