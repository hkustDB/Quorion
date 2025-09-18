create or replace TEMP view aggView5668320397953659806 as select id as v1 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin822411494600364091 as select movie_id as v12 from movie_keyword as mk, aggView5668320397953659806 where mk.keyword_id=aggView5668320397953659806.v1;
create or replace TEMP view aggView2799371797072406397 as select v12, COUNT(*) as annot from aggJoin822411494600364091 group by v12;
create or replace TEMP view aggJoin2522123477368085492 as select id as v12, title as v13, production_year as v16, annot from title as t, aggView2799371797072406397 where t.id=aggView2799371797072406397.v12 and (production_year > 2005);
create or replace TEMP view aggView8831725302599819032 as select v12, MIN(v13) as v24 from aggJoin2522123477368085492 group by v12;
create or replace TEMP view aggJoin7757268782434605013 as select info as v7, v24 from movie_info as mi, aggView8831725302599819032 where mi.movie_id=aggView8831725302599819032.v12 and (info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German'));
select MIN(v24) as v24 from aggJoin7757268782434605013;
