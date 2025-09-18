create or replace TEMP view aggView7875925839745706455 as select id as v1 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin6623000515289103860 as select movie_id as v12 from movie_keyword as mk, aggView7875925839745706455 where mk.keyword_id=aggView7875925839745706455.v1;
create or replace TEMP view aggView7931399880628244254 as select id as v12, title as v24 from title as t where (production_year > 2005);
create or replace TEMP view aggJoin3491382618614320338 as select v12, v24 from aggJoin6623000515289103860 join aggView7931399880628244254 using(v12);
create or replace TEMP view aggView4451957940329604389 as select v12, MIN(v24) as v24 from aggJoin3491382618614320338 group by v12,v24;
create or replace TEMP view aggJoin3485644308147821615 as select info as v7, v24 from movie_info as mi, aggView4451957940329604389 where mi.movie_id=aggView4451957940329604389.v12 and (info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German'));
select MIN(v24) as v24 from aggJoin3485644308147821615;
