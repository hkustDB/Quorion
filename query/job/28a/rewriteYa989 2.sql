create or replace view semiUp7717247307850295724 as select id as v45, title as v46, kind_id as v25 from title AS t where (kind_id) in (select id from kind_type AS kt where kind IN ('movie','episode')) and production_year>2000;
create or replace view semiUp2554280727356274684 as select movie_id as v45, subject_id as v5, status_id as v7 from complete_cast AS cc where (subject_id) in (select id from comp_cast_type AS cct1 where kind= 'crew');
create or replace view semiUp6387979975199739316 as select movie_id as v45, info_type_id as v20, info as v40 from movie_info_idx AS mi_idx where (info_type_id) in (select id from info_type AS it2 where info= 'rating') and info<'8.5';
create or replace view semiUp2110593635197630334 as select movie_id as v45, company_id as v9, company_type_id as v16 from movie_companies AS mc where (company_type_id) in (select id from company_type AS ct) and note NOT LIKE '%(USA)%' and note LIKE '%(200%)%';
create or replace view semiUp1628852485923881118 as select movie_id as v45, keyword_id as v22 from movie_keyword AS mk where (keyword_id) in (select id from keyword AS k where keyword IN ('murder','murder-in-title','blood','violence'));
create or replace view semiUp7071273318276211927 as select movie_id as v45, info_type_id as v18 from movie_info AS mi where (info_type_id) in (select id from info_type AS it1 where info= 'countries') and info IN ('Sweden','Norway','Germany','Denmark','Swedish','Danish','Norwegian','German','USA','American');
create or replace view semiUp2928976065878046732 as select v45, v9, v16 from semiUp2110593635197630334 where (v9) in (select id from company_name AS cn where country_code<> '[us]');
create or replace view semiUp2782137539569034747 as select v45, v46, v25 from semiUp7717247307850295724 where (v45) in (select v45 from semiUp2928976065878046732);
create or replace view semiUp5399543463408354225 as select v45, v20, v40 from semiUp6387979975199739316 where (v45) in (select v45 from semiUp2782137539569034747);
create or replace view semiUp2464872936345882332 as select v45, v5, v7 from semiUp2554280727356274684 where (v7) in (select id from comp_cast_type AS cct2 where kind<> 'complete+verified');
create or replace view semiUp7374115115355187637 as select v45, v22 from semiUp1628852485923881118 where (v45) in (select v45 from semiUp7071273318276211927);
create or replace view semiUp1935630278034363404 as select v45, v5, v7 from semiUp2464872936345882332 where (v45) in (select v45 from semiUp5399543463408354225);
create or replace view semiUp4222452721114013725 as select v45, v22 from semiUp7374115115355187637 where (v45) in (select v45 from semiUp1935630278034363404);
create or replace view semiDown5550185050750170001 as select id as v22 from keyword AS k where (id) in (select v22 from semiUp4222452721114013725) and keyword IN ('murder','murder-in-title','blood','violence');
create or replace view semiDown5228846677622445875 as select v45, v5, v7 from semiUp1935630278034363404 where (v45) in (select v45 from semiUp4222452721114013725);
create or replace view semiDown1341814745001608388 as select v45, v18 from semiUp7071273318276211927 where (v45) in (select v45 from semiUp4222452721114013725);
create or replace view semiDown8183078822345914550 as select id as v7 from comp_cast_type AS cct2 where (id) in (select v7 from semiDown5228846677622445875) and kind<> 'complete+verified';
create or replace view semiDown783660806501706258 as select id as v5 from comp_cast_type AS cct1 where (id) in (select v5 from semiDown5228846677622445875) and kind= 'crew';
create or replace view semiDown649193000761250383 as select v45, v20, v40 from semiUp5399543463408354225 where (v45) in (select v45 from semiDown5228846677622445875);
create or replace view semiDown2910239394717927883 as select id as v18 from info_type AS it1 where (id) in (select v18 from semiDown1341814745001608388) and info= 'countries';
create or replace view semiDown1336094776210919922 as select id as v20 from info_type AS it2 where (id) in (select v20 from semiDown649193000761250383) and info= 'rating';
create or replace view semiDown3338060072150957180 as select v45, v46, v25 from semiUp2782137539569034747 where (v45) in (select v45 from semiDown649193000761250383);
create or replace view semiDown8102030505394616761 as select id as v25 from kind_type AS kt where (id) in (select v25 from semiDown3338060072150957180) and kind IN ('movie','episode');
create or replace view semiDown205739814458295998 as select v45, v9, v16 from semiUp2928976065878046732 where (v45) in (select v45 from semiDown3338060072150957180);
create or replace view semiDown472548912163137552 as select id as v16 from company_type AS ct where (id) in (select v16 from semiDown205739814458295998);
create or replace view semiDown8830845312313051947 as select id as v9, name as v10 from company_name AS cn where (id) in (select v9 from semiDown205739814458295998) and country_code<> '[us]';
create or replace view aggView5176921364558591435 as select v16 from semiDown472548912163137552;
create or replace view aggJoin1989636532627074458 as select v45, v9 from semiDown205739814458295998 join aggView5176921364558591435 using(v16);
create or replace view aggView5329751077670708408 as select v9, v10 as v57 from semiDown8830845312313051947;
create or replace view aggJoin6204381966784082838 as select v45, v57 from aggJoin1989636532627074458 join aggView5329751077670708408 using(v9);
create or replace view aggView3098725648544928956 as select v25 from semiDown8102030505394616761;
create or replace view aggJoin6077864025053444988 as select v45, v46 from semiDown3338060072150957180 join aggView3098725648544928956 using(v25);
create or replace view aggView3821228390383815170 as select v45, MIN(v57) as v57 from aggJoin6204381966784082838 group by v45,v57;
create or replace view aggJoin7204423130042264564 as select v45, v46, v57 from aggJoin6077864025053444988 join aggView3821228390383815170 using(v45);
create or replace view aggView8854692145420216532 as select v45, MIN(v57) as v57, MIN(v46) as v59 from aggJoin7204423130042264564 group by v45,v57;
create or replace view aggJoin5532818640404192826 as select v45, v20, v40, v57, v59 from semiDown649193000761250383 join aggView8854692145420216532 using(v45);
create or replace view aggView9201094086107143775 as select v20 from semiDown1336094776210919922;
create or replace view aggJoin7544003063011911914 as select v45, v40, v57, v59 from aggJoin5532818640404192826 join aggView9201094086107143775 using(v20);
create or replace view aggView7733802353110908261 as select v18 from semiDown2910239394717927883;
create or replace view aggJoin837343573959665857 as select v45 from semiDown1341814745001608388 join aggView7733802353110908261 using(v18);
create or replace view aggView879798441090279299 as select v45, MIN(v57) as v57, MIN(v59) as v59, MIN(v40) as v58 from aggJoin7544003063011911914 group by v45,v59,v57;
create or replace view aggJoin8110345947398799920 as select v45, v5, v7, v57, v59, v58 from semiDown5228846677622445875 join aggView879798441090279299 using(v45);
create or replace view aggView4245463179062366279 as select v7 from semiDown8183078822345914550;
create or replace view aggJoin4002579767010638977 as select v45, v5, v57, v59, v58 from aggJoin8110345947398799920 join aggView4245463179062366279 using(v7);
create or replace view aggView6769212732698759461 as select v5 from semiDown783660806501706258;
create or replace view aggJoin6701160993318225357 as select v45, v57, v59, v58 from aggJoin4002579767010638977 join aggView6769212732698759461 using(v5);
create or replace view aggView1012487941618030390 as select v22 from semiDown5550185050750170001;
create or replace view aggJoin2619815968971268547 as select v45 from semiUp4222452721114013725 join aggView1012487941618030390 using(v22);
create or replace view aggView7385496235140169389 as select v45 from aggJoin837343573959665857 group by v45;
create or replace view aggJoin346578101620422345 as select v45 from aggJoin2619815968971268547 join aggView7385496235140169389 using(v45);
create or replace view aggView651202270861318964 as select v45, MIN(v57) as v57, MIN(v59) as v59, MIN(v58) as v58 from aggJoin6701160993318225357 group by v45,v59,v57,v58;
create or replace view aggJoin4011613745011456077 as select v57, v59, v58 from aggJoin346578101620422345 join aggView651202270861318964 using(v45);
select MIN(v57) as v57, MIN(v58) as v58, MIN(v59) as v59 from aggJoin4011613745011456077;

