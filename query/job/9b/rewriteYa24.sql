create or replace view semiUp578284729493414818 as select person_id as v35, movie_id as v18, person_role_id as v9, role_id as v22 from cast_info AS ci where (role_id) in (select id from role_type AS rt where role= 'actress') and note= '(voice)';
create or replace view semiUp4217740880456311798 as select movie_id as v18, company_id as v32 from movie_companies AS mc where (company_id) in (select id from company_name AS cn where country_code= '[us]') and ((note LIKE '%(USA)%') OR (note LIKE '%(worldwide)%')) and note LIKE '%(200%)%';
create or replace view semiUp3043327193524197034 as select v35, v18, v9, v22 from semiUp578284729493414818 where (v35) in (select person_id from aka_name AS an);
create or replace view semiUp5245296884173489627 as select v35, v18, v9, v22 from semiUp3043327193524197034 where (v35) in (select id from name AS n where gender= 'f' and name LIKE '%Angel%');
create or replace view semiUp2781952415428173482 as select v18, v32 from semiUp4217740880456311798 where (v18) in (select id from title AS t where production_year>=2007 and production_year<=2010);
create or replace view semiUp6098550733500969974 as select v35, v18, v9, v22 from semiUp5245296884173489627 where (v18) in (select v18 from semiUp2781952415428173482);
create or replace view semiUp7297604671300209264 as select id as v9, name as v10 from char_name AS chn where (id) in (select v9 from semiUp6098550733500969974);
create or replace view semiDown642815259440419034 as select v35, v18, v9, v22 from semiUp6098550733500969974 where (v9) in (select v9 from semiUp7297604671300209264);
create or replace view semiDown5726251910883113485 as select id as v22 from role_type AS rt where (id) in (select v22 from semiDown642815259440419034) and role= 'actress';
create or replace view semiDown7060798816118882827 as select id as v35, name as v36 from name AS n where (id) in (select v35 from semiDown642815259440419034) and gender= 'f' and name LIKE '%Angel%';
create or replace view semiDown685568559077988884 as select v18, v32 from semiUp2781952415428173482 where (v18) in (select v18 from semiDown642815259440419034);
create or replace view semiDown5426745417126481541 as select person_id as v35, name as v3 from aka_name AS an where (person_id) in (select v35 from semiDown642815259440419034);
create or replace view semiDown5359069690914930372 as select id as v32 from company_name AS cn where (id) in (select v32 from semiDown685568559077988884) and country_code= '[us]';
create or replace view semiDown5696894838440795145 as select id as v18, title as v47 from title AS t where (id) in (select v18 from semiDown685568559077988884) and production_year>=2007 and production_year<=2010;
create or replace view aggView7682867601602148341 as select v32 from semiDown5359069690914930372;
create or replace view aggJoin4273812245322486916 as select v18 from semiDown685568559077988884 join aggView7682867601602148341 using(v32);
create or replace view aggView1238162893984495679 as select v18, v47 as v61 from semiDown5696894838440795145;
create or replace view aggJoin4426859886767449364 as select v18, v61 from aggJoin4273812245322486916 join aggView1238162893984495679 using(v18);
create or replace view aggView6830662465186429224 as select v35, MIN(v3) as v58 from semiDown5426745417126481541 group by v35;
create or replace view aggJoin5848792322464049139 as select v35, v18, v9, v22, v58 from semiDown642815259440419034 join aggView6830662465186429224 using(v35);
create or replace view aggView931853178168098528 as select v35, v36 as v60 from semiDown7060798816118882827;
create or replace view aggJoin6286655722132783918 as select v18, v9, v22, v58, v60 from aggJoin5848792322464049139 join aggView931853178168098528 using(v35);
create or replace view aggView1801423406017918699 as select v18, MIN(v61) as v61 from aggJoin4426859886767449364 group by v18,v61;
create or replace view aggJoin4764131389323878416 as select v9, v22, v58 as v58, v60 as v60, v61 from aggJoin6286655722132783918 join aggView1801423406017918699 using(v18);
create or replace view aggView4398670693478413379 as select v22 from semiDown5726251910883113485;
create or replace view aggJoin7082260772745968927 as select v9, v58, v60, v61 from aggJoin4764131389323878416 join aggView4398670693478413379 using(v22);
create or replace view aggView8771810400232638139 as select v9, MIN(v58) as v58, MIN(v60) as v60, MIN(v61) as v61 from aggJoin7082260772745968927 group by v9,v58,v61,v60;
create or replace view aggJoin2225448872565225322 as select v10, v58, v60, v61 from semiUp7297604671300209264 join aggView8771810400232638139 using(v9);
select MIN(v58) as v58, MIN(v10) as v59, MIN(v60) as v60, MIN(v61) as v61 from aggJoin2225448872565225322;

