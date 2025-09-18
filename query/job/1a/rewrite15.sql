create or replace TEMP view aggView4909404913091796494 as select id as v14, title as v27 from title as t where (production_year > 2005);
create or replace TEMP view aggJoin8485563501448399103 as select movie_id as v14, info_type_id as v1, info as v9, v27 from movie_info_idx as mi_idx, aggView4909404913091796494 where mi_idx.movie_id=aggView4909404913091796494.v14 and (info > '5.0');
create or replace TEMP view aggView8629269892105815929 as select id as v1 from info_type as it where (info = 'rating');
create or replace TEMP view aggJoin5210670269118259128 as select v14, v9, v27 from aggJoin8485563501448399103 join aggView8629269892105815929 using(v1);
create or replace TEMP view aggView3322027537664490529 as select id as v3 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin4383132280056898678 as select movie_id as v14 from movie_keyword as mk, aggView3322027537664490529 where mk.keyword_id=aggView3322027537664490529.v3;
create or replace TEMP view aggView4676944948094857465 as select v14, MIN(v27) as v27, MIN(v9) as v26 from aggJoin5210670269118259128 group by v14,v27;
create or replace TEMP view aggJoin3885451975141635547 as select v27, v26 from aggJoin4383132280056898678 join aggView4676944948094857465 using(v14);
select MIN(v26) as v26,MIN(v27) as v27 from aggJoin3885451975141635547;
