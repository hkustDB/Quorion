create or replace view semiUp341695765597767677 as select movie_id as v29, company_id as v1, company_type_id as v8 from movie_companies AS mc where (company_id) in (select id from company_name AS cn where country_code= '[us]');
create or replace view semiUp3587598997532120697 as select movie_id as v29, info_type_id as v21, info as v22 from movie_info AS mi where (info_type_id) in (select id from info_type AS it1 where info= 'budget');
create or replace view semiUp98893940179310657 as select movie_id as v29, info_type_id as v26 from movie_info_idx AS mi_idx where (info_type_id) in (select id from info_type AS it2 where info= 'bottom 10 rank');
create or replace view semiUp3629926443462215988 as select v29, v1, v8 from semiUp341695765597767677 where (v29) in (select v29 from semiUp98893940179310657);
create or replace view semiUp6317118952931216470 as select v29, v1, v8 from semiUp3629926443462215988 where (v8) in (select id from company_type AS ct where kind IN ('production companies','distributors'));
create or replace view semiUp8838548628803057937 as select id as v29, title as v30 from title AS t where (id) in (select v29 from semiUp6317118952931216470) and production_year>2000 and ((title LIKE 'Birdemic%') OR (title LIKE '%Movie%'));
create or replace view semiUp1663605359542651620 as select v29, v21, v22 from semiUp3587598997532120697 where (v29) in (select v29 from semiUp8838548628803057937);
create or replace view semiDown879949398713594332 as select id as v21 from info_type AS it1 where (id) in (select v21 from semiUp1663605359542651620) and info= 'budget';
create or replace view semiDown1710770027943873614 as select v29, v30 from semiUp8838548628803057937 where (v29) in (select v29 from semiUp1663605359542651620);
create or replace view semiDown7116299099128041410 as select v29, v1, v8 from semiUp6317118952931216470 where (v29) in (select v29 from semiDown1710770027943873614);
create or replace view semiDown7208035362487208567 as select id as v8 from company_type AS ct where (id) in (select v8 from semiDown7116299099128041410) and kind IN ('production companies','distributors');
create or replace view semiDown5631894167543681590 as select id as v1 from company_name AS cn where (id) in (select v1 from semiDown7116299099128041410) and country_code= '[us]';
create or replace view semiDown7992462578353681572 as select v29, v26 from semiUp98893940179310657 where (v29) in (select v29 from semiDown7116299099128041410);
create or replace view semiDown5740601019239545502 as select id as v26 from info_type AS it2 where (id) in (select v26 from semiDown7992462578353681572) and info= 'bottom 10 rank';
create or replace view aggView10178880116893448 as select v26 from semiDown5740601019239545502;
create or replace view aggJoin1419555373417503183 as select v29 from semiDown7992462578353681572 join aggView10178880116893448 using(v26);
create or replace view aggView8520531667929091773 as select v8 from semiDown7208035362487208567;
create or replace view aggJoin4060976313522025750 as select v29, v1 from semiDown7116299099128041410 join aggView8520531667929091773 using(v8);
create or replace view aggView5161644498023140780 as select v29 from aggJoin1419555373417503183 group by v29;
create or replace view aggJoin3853757311895469359 as select v29, v1 from aggJoin4060976313522025750 join aggView5161644498023140780 using(v29);
create or replace view aggView204083878179152487 as select v1 from semiDown5631894167543681590;
create or replace view aggJoin5647229871726405946 as select v29 from aggJoin3853757311895469359 join aggView204083878179152487 using(v1);
create or replace view aggView5614679257452128214 as select v29 from aggJoin5647229871726405946 group by v29;
create or replace view aggJoin5413881858354201194 as select v29, v30 from semiDown1710770027943873614 join aggView5614679257452128214 using(v29);
create or replace view aggView2928779092810781238 as select v29, MIN(v30) as v42 from aggJoin5413881858354201194 group by v29;
create or replace view aggJoin1965293512278988281 as select v21, v22, v42 from semiUp1663605359542651620 join aggView2928779092810781238 using(v29);
create or replace view aggView2523822955333693977 as select v21 from semiDown879949398713594332;
create or replace view aggJoin2910561533010989425 as select v22, v42 from aggJoin1965293512278988281 join aggView2523822955333693977 using(v21);
select MIN(v22) as v41, MIN(v42) as v42 from aggJoin2910561533010989425;

