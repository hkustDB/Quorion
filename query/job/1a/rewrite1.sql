create or replace TEMP view aggView6618342892562765735 as select id as v1 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin6332895257520969650 as select movie_id as v12 from movie_keyword as mk, aggView6618342892562765735 where mk.keyword_id=aggView6618342892562765735.v1;
create or replace TEMP view aggView4953525959282900418 as select id as v12, title as v24 from title as t where (production_year > 2005);
create or replace TEMP view aggJoin3150164524260891095 as select v12, v24 from aggJoin6332895257520969650 join aggView4953525959282900418 using(v12);
create or replace TEMP view aggView4119200046220570075 as select v12, MIN(v24) as v24, COUNT(*) as annot from aggJoin3150164524260891095 group by v12;
create or replace TEMP view aggJoin8568098382291406579 as select info as v7, v24, annot from movie_info as mi, aggView4119200046220570075 where mi.movie_id=aggView4119200046220570075.v12 and (info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German'));
select MIN(v24) as v24 from aggJoin8568098382291406579;
