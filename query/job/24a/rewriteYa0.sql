create or replace view semiUp9150760145370518563 as select person_id as v48, movie_id as v59, person_role_id as v9, role_id as v57 from cast_info AS ci where (role_id) in (select id from role_type AS rt where role= 'actress') and note IN ('(voice)','(voice: Japanese version)','(voice) (uncredited)','(voice: English version)');
create or replace view semiUp3896563163855230837 as select movie_id as v59, info_type_id as v30 from movie_info AS mi where (info_type_id) in (select id from info_type AS it where info= 'release dates') and ((info LIKE 'Japan:%201%') OR (info LIKE 'USA:%201%'));
create or replace view semiUp446279668496482183 as select movie_id as v59, company_id as v23 from movie_companies AS mc where (company_id) in (select id from company_name AS cn where country_code= '[us]');
create or replace view semiUp8436285666838399158 as select id as v59, title as v60 from title AS t where (id) in (select v59 from semiUp446279668496482183) and production_year>2010;
create or replace view semiUp3863579368545572127 as select v59, v30 from semiUp3896563163855230837 where (v59) in (select v59 from semiUp8436285666838399158);
create or replace view semiUp5003153995156258982 as select movie_id as v59, keyword_id as v32 from movie_keyword AS mk where (movie_id) in (select v59 from semiUp3863579368545572127);
create or replace view semiUp3319349926201629775 as select id as v32 from keyword AS k where (id) in (select v32 from semiUp5003153995156258982) and keyword IN ('hero','martial-arts','hand-to-hand-combat');
create or replace view semiUp2880742363109243668 as select v48, v59, v9, v57 from semiUp9150760145370518563;
create or replace view semiUp4612440542532885533 as select id as v48, name as v49 from name AS n where (id) in (select v48 from semiUp2880742363109243668) and name LIKE '%An%' and gender= 'f';
create or replace view semiUp5586487561471181528 as select person_id as v48 from aka_name AS an where (person_id) in (select v48 from semiUp4612440542532885533);
create or replace view semiUp5507832673081920966 as select id as v9, name as v10 from char_name AS chn;
create or replace view semiDown8600886419963227428 as select v48 from semiUp5586487561471181528;
create or replace view semiDown7609211782112906349 as select v48, v49 from semiUp4612440542532885533 where (v48) in (select v48 from semiDown8600886419963227428);
create or replace view semiDown6108944638784170648 as select v48, v59, v9, v57 from semiUp2880742363109243668 where (v48) in (select v48 from semiDown7609211782112906349);
create or replace view semiDown2349943913537855212 as select id as v57 from role_type AS rt where (id) in (select v57 from semiDown6108944638784170648) and role= 'actress';
create or replace view semiDown5222379271715954834 as select v32 from semiUp3319349926201629775;
create or replace view semiDown5995569802925028575 as select v59, v32 from semiUp5003153995156258982 where (v32) in (select v32 from semiDown5222379271715954834);
create or replace view semiDown8136688161574484327 as select v59, v30 from semiUp3863579368545572127 where (v59) in (select v59 from semiDown5995569802925028575);
create or replace view semiDown3901885970806307467 as select id as v30 from info_type AS it where (id) in (select v30 from semiDown8136688161574484327) and info= 'release dates';
create or replace view semiDown8326942844144419001 as select v59, v60 from semiUp8436285666838399158 where (v59) in (select v59 from semiDown8136688161574484327);
create or replace view semiDown6691207677249270112 as select v59, v23 from semiUp446279668496482183 where (v59) in (select v59 from semiDown8326942844144419001);
create or replace view semiDown527142006364344027 as select id as v23 from company_name AS cn where (id) in (select v23 from semiDown6691207677249270112) and country_code= '[us]';
create or replace view aggView1551712249245732529 as select v23 from semiDown527142006364344027;
create or replace view aggJoin6069237026504235960 as select v59 from semiDown6691207677249270112 join aggView1551712249245732529 using(v23);
create or replace view aggView2776269037153863749 as select v59 from aggJoin6069237026504235960 group by v59;
create or replace view aggJoin1996653045588418970 as select v59, v60 from semiDown8326942844144419001 join aggView2776269037153863749 using(v59);
create or replace view aggView1056760466166130099 as select v59, MIN(v60) as v73 from aggJoin1996653045588418970 group by v59;
create or replace view aggJoin2812197951747454891 as select v59, v30, v73 from semiDown8136688161574484327 join aggView1056760466166130099 using(v59);
create or replace view aggView5298066333012736567 as select v30 from semiDown3901885970806307467;
create or replace view aggJoin7452465140501002454 as select v59, v73 from aggJoin2812197951747454891 join aggView5298066333012736567 using(v30);
create or replace view aggView506455081416411295 as select v59, MIN(v73) as v73 from aggJoin7452465140501002454 group by v59,v73;
create or replace view aggJoin2900426525906404424 as select v59, v32, v73 from semiDown5995569802925028575 join aggView506455081416411295 using(v59);
create or replace view aggView6841420602758308651 as select v32, v59, MIN(v73) as v73 from aggJoin2900426525906404424 group by v32,v59,v73;
create or replace view aggJoin8756666144913308397 as select v59, v73 from semiDown5222379271715954834 join aggView6841420602758308651 using(v32);
create or replace view aggView4946313492106150253 as select v59, MIN(v73) as v73 from aggJoin8756666144913308397 group by v59,v73;
create or replace view aggJoin7930274530585755025 as select v48, v59, v9, v57, v73 from semiDown6108944638784170648 join aggView4946313492106150253 using(v59);
create or replace view aggView5439121310586464492 as select v57 from semiDown2349943913537855212;
create or replace view aggJoin9204193295403411425 as select v48, v59, v9, v73 from aggJoin7930274530585755025 join aggView5439121310586464492 using(v57);
create or replace view aggView9161765758311874125 as select v48, v9, MIN(v73) as v73 from aggJoin9204193295403411425 group by v48,v9,v73;
create or replace view aggJoin7322578334711338927 as select v48, v49, v9, v73 from semiDown7609211782112906349 join aggView9161765758311874125 using(v48);
create or replace view aggView5613460439662818957 as select v48, v9, MIN(v73) as v73, MIN(v49) as v72 from aggJoin7322578334711338927 group by v48,v9,v73;
create or replace view aggJoin5925432183690806451 as select v9, v73, v72 from semiDown8600886419963227428 join aggView5613460439662818957 using(v48);
create or replace view aggView4213869823077276287 as select v9, MIN(v73) as v73, MIN(v72) as v72 from aggJoin5925432183690806451 group by v9,v72,v73;
create or replace view aggJoin1734241530998559431 as select v9, v10, v73, v72 from semiUp5507832673081920966 join aggView4213869823077276287 using(v9);
select MIN(v10) as v71, MIN(v72) as v72, MIN(v73) as v73 from aggJoin1734241530998559431;

