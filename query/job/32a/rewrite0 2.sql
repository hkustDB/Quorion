create or replace view aggView5685475597052354602 as select id as v8 from keyword as k where keyword= '10,000-mile-club';
create or replace view aggJoin1703749074260480359 as select movie_id as v13 from movie_keyword as mk, aggView5685475597052354602 where mk.keyword_id=aggView5685475597052354602.v8;
create or replace view aggView583240129350333707 as select v13 from aggJoin1703749074260480359 group by v13;
create or replace view aggJoin4140429859655248483 as select id as v13, title as v14 from title as t1, aggView583240129350333707 where t1.id=aggView583240129350333707.v13;
create or replace view aggView369264100463491394 as select v13, MIN(v14) as v38 from aggJoin4140429859655248483 group by v13;
create or replace view aggJoin3542443502534987551 as select linked_movie_id as v11, link_type_id as v4, v38 from movie_link as ml, aggView369264100463491394 where ml.movie_id=aggView369264100463491394.v13;
create or replace view aggView4940846113784803358 as select v11, v4, MIN(v38) as v38 from aggJoin3542443502534987551 group by v11,v4;
create or replace view aggJoin7211833513509587531 as select title as v26, v4, v38 from title as t2, aggView4940846113784803358 where t2.id=aggView4940846113784803358.v11;
create or replace view aggView217081283313323112 as select v4, MIN(v38) as v38, MIN(v26) as v39 from aggJoin7211833513509587531 group by v4;
create or replace view aggJoin2059909999616325411 as select id as v4, link as v5, v38, v39 from link_type as lt, aggView217081283313323112 where lt.id=aggView217081283313323112.v4;
select MIN(v5) as v37,MIN(v38) as v38,MIN(v39) as v39 from aggJoin2059909999616325411;
