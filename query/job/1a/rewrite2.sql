create or replace TEMP view aggView2284075454143109922 as select id as v1 from keyword as k where (keyword LIKE '%sequel%');
create or replace TEMP view aggJoin2260684664986708671 as select movie_id as v12 from movie_keyword as mk, aggView2284075454143109922 where mk.keyword_id=aggView2284075454143109922.v1;
create or replace TEMP view aggView2089938777798577204 as select v12, COUNT(*) as annot from aggJoin2260684664986708671 group by v12;
create or replace TEMP view aggJoin1749525513643265361 as select movie_id as v12, info as v7, annot from movie_info as mi, aggView2089938777798577204 where mi.movie_id=aggView2089938777798577204.v12 and (info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German'));
create or replace TEMP view aggView1501556449656051774 as select v12, SUM(annot) as annot from aggJoin1749525513643265361 group by v12;
create or replace TEMP view aggJoin3862167617225340214 as select title as v13, production_year as v16, annot from title as t, aggView1501556449656051774 where t.id=aggView1501556449656051774.v12 and (production_year > 2005);
select MIN(v13) as v24 from aggJoin3862167617225340214;
