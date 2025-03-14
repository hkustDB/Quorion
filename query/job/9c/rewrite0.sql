create or replace view aggView4463160316727391452 as select id as v35, name as v60 from name as n where name LIKE '%An%' and gender= 'f';
create or replace view aggJoin7320128454876531491 as select person_id as v35, movie_id as v18, person_role_id as v9, note as v20, role_id as v22, v60 from cast_info as ci, aggView4463160316727391452 where ci.person_id=aggView4463160316727391452.v35 and note IN ('(voice)','(voice: Japanese version)','(voice) (uncredited)','(voice: English version)');
create or replace view aggView8034037506252985628 as select id as v22 from role_type as rt where role= 'actress';
create or replace view aggJoin199915050250074669 as select v35, v18, v9, v20, v60 from aggJoin7320128454876531491 join aggView8034037506252985628 using(v22);
create or replace view aggView1333718250504809712 as select id as v18, title as v61 from title as t;
create or replace view aggJoin8489934564990411697 as select v35, v18, v9, v20, v60, v61 from aggJoin199915050250074669 join aggView1333718250504809712 using(v18);
create or replace view aggView2440176086971804122 as select v18, v35, v9, MIN(v60) as v60, MIN(v61) as v61 from aggJoin8489934564990411697 group by v18,v35,v9;
create or replace view aggJoin6425792139178205690 as select company_id as v32, v35, v9, v60, v61 from movie_companies as mc, aggView2440176086971804122 where mc.movie_id=aggView2440176086971804122.v18;
create or replace view aggView4303702089585338861 as select v32, v35, v9, MIN(v60) as v60, MIN(v61) as v61 from aggJoin6425792139178205690 group by v32,v35,v9;
create or replace view aggJoin860109839418000434 as select country_code as v25, v35, v9, v60, v61 from company_name as cn, aggView4303702089585338861 where cn.id=aggView4303702089585338861.v32 and country_code= '[us]';
create or replace view aggView872231132728430690 as select v9, v35, MIN(v60) as v60, MIN(v61) as v61 from aggJoin860109839418000434 group by v9,v35;
create or replace view aggJoin7618302986958271740 as select id as v9, name as v10, v35, v60, v61 from char_name as chn, aggView872231132728430690 where chn.id=aggView872231132728430690.v9;
create or replace view aggView5442173139645029075 as select v35, MIN(v60) as v60, MIN(v61) as v61, MIN(v10) as v59 from aggJoin7618302986958271740 group by v35;
create or replace view aggJoin6341241419860753578 as select person_id as v35, name as v3, v60, v61, v59 from aka_name as an, aggView5442173139645029075 where an.person_id=aggView5442173139645029075.v35;
select MIN(v3) as v58,MIN(v59) as v59,MIN(v60) as v60,MIN(v61) as v61 from aggJoin6341241419860753578;
