create or replace TEMP view aggView2369313530579016081 as select movie_id as v12, COUNT(*) as annot from movie_info as mi where (info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German')) group by movie_id;
create or replace TEMP view aggJoin4444680300565319216 as select id as v12, title as v13, production_year as v16, annot from title as t, aggView2369313530579016081 where t.id=aggView2369313530579016081.v12 and (production_year > 2005);
create or replace TEMP view aggView3335640882782090727 as select v12, MIN(v13) as v24, SUM(annot) as annot from aggJoin4444680300565319216 group by v12;
create or replace TEMP view aggJoin516578241632646762 as select keyword_id as v1, v24, annot from movie_keyword as mk, aggView3335640882782090727 where mk.movie_id=aggView3335640882782090727.v12;
create or replace TEMP view aggView6975837694619286259 as select v1, MIN(v24) as v24, SUM(annot) as annot from aggJoin516578241632646762 group by v1;
create or replace TEMP view aggJoin1623811372634929316 as select keyword as v2, v24, annot from keyword as k, aggView6975837694619286259 where k.id=aggView6975837694619286259.v1 and (keyword LIKE '%sequel%');
select MIN(v24) as v24 from aggJoin1623811372634929316;
