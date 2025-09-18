create or replace TEMP view aggView2303380050363401 as select id as v1 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin854663297017189605 as select movie_id as v12 from movie_keyword as mk, aggView2303380050363401 where mk.keyword_id=aggView2303380050363401.v1;
create or replace TEMP view aggView1791343460855815199 as select v12, COUNT(*) as annot from aggJoin854663297017189605 group by v12;
create or replace TEMP view aggJoin968607074396522544 as select movie_id as v12, info as v7, annot from movie_info as mi, aggView1791343460855815199 where mi.movie_id=aggView1791343460855815199.v12 and (info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German'));
create or replace TEMP view aggView1873926234543913812 as select id as v12, title as v24 from title as t where (production_year > 2005);
create or replace TEMP view aggJoin5094281962417069035 as select v7, v24 as v24 from aggJoin968607074396522544 join aggView1873926234543913812 using(v12);
select MIN(v24) as v24 from aggJoin5094281962417069035;
