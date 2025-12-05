create or replace TEMP view aggView2228131999881382626 as select id as v1 from info_type as it where (info = 'rating');
create or replace TEMP view aggJoin1945901703757833901 as select movie_id as v14, info as v9 from movie_info_idx as mi_idx, aggView2228131999881382626 where mi_idx.info_type_id=aggView2228131999881382626.v1 and (info > '5.0');
create or replace TEMP view aggView7993166566074861470 as select id as v14, title as v27 from title as t where (production_year > 2005);
create or replace TEMP view aggJoin3636033252156003766 as select movie_id as v14, keyword_id as v3, v27 from movie_keyword as mk, aggView7993166566074861470 where mk.movie_id=aggView7993166566074861470.v14;
create or replace TEMP view aggView1785367127759975190 as select id as v3 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin4014163100179788590 as select v14, v27 from aggJoin3636033252156003766 join aggView1785367127759975190 using(v3);
create or replace TEMP view aggView8973905459441195351 as select v14, MIN(v9) as v26 from aggJoin1945901703757833901 group by v14;
create or replace TEMP view aggJoin2128485832116434995 as select v27 as v27, v26 from aggJoin4014163100179788590 join aggView8973905459441195351 using(v14);
select MIN(v26) as v26,MIN(v27) as v27 from aggJoin2128485832116434995;
