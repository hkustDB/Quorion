create or replace TEMP view aggView2194707253319214570 as select id as v1 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin6842500111289506625 as select movie_id as v12 from movie_keyword as mk, aggView2194707253319214570 where mk.keyword_id=aggView2194707253319214570.v1;
create or replace TEMP view aggView3435924728147039961 as select movie_id as v12, COUNT(*) as annot from movie_info as mi where (info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German')) group by movie_id;
create or replace TEMP view aggJoin3079280796632791046 as select v12, annot from aggJoin6842500111289506625 join aggView3435924728147039961 using(v12);
create or replace TEMP view aggView3850546843235808706 as select id as v12, title as v24 from title as t where (production_year > 2005);
create or replace TEMP view aggJoin5383010871321996125 as select annot, v24 as v24 from aggJoin3079280796632791046 join aggView3850546843235808706 using(v12);
select MIN(v24) as v24 from aggJoin5383010871321996125;
