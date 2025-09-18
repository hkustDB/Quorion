create or replace TEMP view aggView4833840850038527982 as select id as v1 from info_type as it where (info = 'rating');
create or replace TEMP view aggJoin1911928367863046825 as select movie_id as v14, info as v9 from movie_info_idx as mi_idx, aggView4833840850038527982 where mi_idx.info_type_id=aggView4833840850038527982.v1 and (info > '5.0');
create or replace TEMP view aggView1620719913427114405 as select v14, MIN(v9) as v26, COUNT(*) as annot from aggJoin1911928367863046825 group by v14;
create or replace TEMP view aggJoin8033966152555890649 as select id as v14, title as v15, production_year as v18, v26, annot from title as t, aggView1620719913427114405 where t.id=aggView1620719913427114405.v14 and (production_year > 2005);
create or replace TEMP view aggView1266614057191752655 as select id as v3 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin359139327354630646 as select movie_id as v14 from movie_keyword as mk, aggView1266614057191752655 where mk.keyword_id=aggView1266614057191752655.v3;
create or replace TEMP view aggView704348788701721389 as select v14, MIN(v26) as v26, MIN(v15) as v27 from aggJoin8033966152555890649 group by v14,v26;
create or replace TEMP view aggJoin2342861628132079707 as select v26, v27 from aggJoin359139327354630646 join aggView704348788701721389 using(v14);
select MIN(v26) as v26,MIN(v27) as v27 from aggJoin2342861628132079707;
