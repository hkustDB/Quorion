create or replace view aggView4651140231081925779 as select id as v27 from keyword as k where keyword= 'sequel';
create or replace view aggJoin2262830587977791534 as select movie_id as v29 from movie_keyword as mk, aggView4651140231081925779 where mk.keyword_id=aggView4651140231081925779.v27;
create or replace view aggView1438793137572548612 as select v29 from aggJoin2262830587977791534 group by v29;
create or replace view aggJoin3866249251491307281 as select id as v29, title as v33, production_year as v36 from title as t, aggView1438793137572548612 where t.id=aggView1438793137572548612.v29 and production_year<=2000 and production_year>=1950;
create or replace view aggView3651272646515028140 as select v29, MIN(v33) as v46 from aggJoin3866249251491307281 group by v29;
create or replace view aggJoin7678176750831653763 as select movie_id as v29, company_id as v17, company_type_id as v18, v46 from movie_companies as mc, aggView3651272646515028140 where mc.movie_id=aggView3651272646515028140.v29;
create or replace view aggView7383429355093878546 as select id as v18 from company_type as ct where kind= 'production companies';
create or replace view aggJoin9204124053112514189 as select v29, v17, v46 from aggJoin7678176750831653763 join aggView7383429355093878546 using(v18);
create or replace view aggView4327196349607753933 as select v29, v17, MIN(v46) as v46 from aggJoin9204124053112514189 group by v29,v17;
create or replace view aggJoin3180211932767101796 as select movie_id as v29, info as v23, v17, v46 from movie_info as mi, aggView4327196349607753933 where mi.movie_id=aggView4327196349607753933.v29 and info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German');
create or replace view aggView8065667170695551388 as select v17, v29, MIN(v46) as v46 from aggJoin3180211932767101796 group by v17,v29;
create or replace view aggJoin8774155630879779317 as select id as v17, name as v2, country_code as v3, v29, v46 from company_name as cn, aggView8065667170695551388 where cn.id=aggView8065667170695551388.v17 and country_code<> '[pl]' and ((name LIKE '%Film%') OR (name LIKE '%Warner%'));
create or replace view aggView5942624482233529073 as select v29, MIN(v46) as v46, MIN(v2) as v44 from aggJoin8774155630879779317 group by v29;
create or replace view aggJoin8816967289516006566 as select movie_id as v29, link_type_id as v13, v46, v44 from movie_link as ml, aggView5942624482233529073 where ml.movie_id=aggView5942624482233529073.v29;
create or replace view aggView1108709833077210702 as select id as v13, link as v45 from link_type as lt where link LIKE '%follow%';
create or replace view aggJoin4100366130220228078 as select v29, v46, v44, v45 from aggJoin8816967289516006566 join aggView1108709833077210702 using(v13);
select MIN(v44) as v44,MIN(v45) as v45,MIN(v46) as v46 from aggJoin4100366130220228078;
