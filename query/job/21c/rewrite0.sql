create or replace view aggView3206636349508071358 as select id as v27 from keyword as k where keyword= 'sequel';
create or replace view aggJoin4940184784863686444 as select movie_id as v29 from movie_keyword as mk, aggView3206636349508071358 where mk.keyword_id=aggView3206636349508071358.v27;
create or replace view aggView8531688699904181300 as select v29 from aggJoin4940184784863686444 group by v29;
create or replace view aggJoin826129572750779916 as select movie_id as v29, company_id as v17, company_type_id as v18 from movie_companies as mc, aggView8531688699904181300 where mc.movie_id=aggView8531688699904181300.v29;
create or replace view aggView1735796228283473356 as select id as v17, name as v44 from company_name as cn where country_code<> '[pl]' and ((name LIKE '%Film%') OR (name LIKE '%Warner%'));
create or replace view aggJoin9211676598031792739 as select v29, v18, v44 from aggJoin826129572750779916 join aggView1735796228283473356 using(v17);
create or replace view aggView6231969401945679265 as select v18, v29, MIN(v44) as v44 from aggJoin9211676598031792739 group by v18,v29;
create or replace view aggJoin3548456991260480827 as select kind as v9, v29, v44 from company_type as ct, aggView6231969401945679265 where ct.id=aggView6231969401945679265.v18 and kind= 'production companies';
create or replace view aggView6379869564227040686 as select v29, MIN(v44) as v44 from aggJoin3548456991260480827 group by v29;
create or replace view aggJoin7172703357615247594 as select id as v29, title as v33, production_year as v36, v44 from title as t, aggView6379869564227040686 where t.id=aggView6379869564227040686.v29 and production_year<=2010 and production_year>=1950;
create or replace view aggView5529846341862907509 as select movie_id as v29 from movie_info as mi where info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German','English') group by movie_id;
create or replace view aggJoin7059713171676432074 as select v29, v33, v36, v44 as v44 from aggJoin7172703357615247594 join aggView5529846341862907509 using(v29);
create or replace view aggView862336849385594485 as select v29, MIN(v44) as v44, MIN(v33) as v46 from aggJoin7059713171676432074 group by v29;
create or replace view aggJoin263133336689809195 as select movie_id as v29, link_type_id as v13, v44, v46 from movie_link as ml, aggView862336849385594485 where ml.movie_id=aggView862336849385594485.v29;
create or replace view aggView66971642284580168 as select id as v13, link as v45 from link_type as lt where link LIKE '%follow%';
create or replace view aggJoin2146934041842897177 as select v29, v44, v46, v45 from aggJoin263133336689809195 join aggView66971642284580168 using(v13);
select MIN(v44) as v44,MIN(v45) as v45,MIN(v46) as v46 from aggJoin2146934041842897177;
