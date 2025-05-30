create or replace view semiUp8463616971123118489 as select movie_id as v36, info_type_id as v16 from movie_info AS mi where (info_type_id) in (select id from info_type AS it1 where info= 'release dates') and ((info LIKE 'USA:% 199%') OR (info LIKE 'USA:% 200%')) and note LIKE '%internet%';
create or replace view semiUp4592482323120134212 as select movie_id as v36, company_id as v7, company_type_id as v14 from movie_companies AS mc where (company_type_id) in (select id from company_type AS ct);
create or replace view semiUp171191008648035801 as select id as v36, title as v37, kind_id as v21 from title AS t where (id) in (select v36 from semiUp8463616971123118489) and production_year>2000;
create or replace view semiUp8276824503722542963 as select movie_id as v36, keyword_id as v18 from movie_keyword AS mk where (keyword_id) in (select id from keyword AS k);
create or replace view semiUp5017234467980023242 as select v36, v7, v14 from semiUp4592482323120134212 where (v7) in (select id from company_name AS cn where country_code= '[us]');
create or replace view semiUp2879920830819415810 as select v36, v37, v21 from semiUp171191008648035801 where (v36) in (select v36 from semiUp8276824503722542963);
create or replace view semiUp79462881645630585 as select v36, v37, v21 from semiUp2879920830819415810 where (v36) in (select v36 from semiUp5017234467980023242);
create or replace view semiUp596074160000997724 as select movie_id as v36, status_id as v5 from complete_cast AS cc where (status_id) in (select id from comp_cast_type AS cct1 where kind= 'complete+verified');
create or replace view semiUp5261121280018467395 as select v36, v37, v21 from semiUp79462881645630585 where (v36) in (select v36 from semiUp596074160000997724);
create or replace view tAux92 as select v37, v21 from semiUp5261121280018467395;
create or replace view semiUp3057784503043099118 as select v37, v21 from tAux92 where (v21) in (select id from kind_type AS kt where kind= 'movie');
create or replace view semiDown8485069432650173080 as select id as v21, kind as v22 from kind_type AS kt where (id) in (select v21 from semiUp3057784503043099118) and kind= 'movie';
create or replace view semiDown1218210593157555523 as select v36, v37, v21 from semiUp5261121280018467395 where (v21, v37) in (select v21, v37 from semiUp3057784503043099118);
create or replace view semiDown3042152255136962688 as select v36, v16 from semiUp8463616971123118489 where (v36) in (select v36 from semiDown1218210593157555523);
create or replace view semiDown7247366206814160165 as select v36, v5 from semiUp596074160000997724 where (v36) in (select v36 from semiDown1218210593157555523);
create or replace view semiDown1136359701756489 as select v36, v7, v14 from semiUp5017234467980023242 where (v36) in (select v36 from semiDown1218210593157555523);
create or replace view semiDown7379028856486445004 as select v36, v18 from semiUp8276824503722542963 where (v36) in (select v36 from semiDown1218210593157555523);
create or replace view semiDown3202253410405775893 as select id as v16 from info_type AS it1 where (id) in (select v16 from semiDown3042152255136962688) and info= 'release dates';
create or replace view semiDown3362334308422269894 as select id as v5 from comp_cast_type AS cct1 where (id) in (select v5 from semiDown7247366206814160165) and kind= 'complete+verified';
create or replace view semiDown417287357033399171 as select id as v14 from company_type AS ct where (id) in (select v14 from semiDown1136359701756489);
create or replace view semiDown7130450318338226150 as select id as v7 from company_name AS cn where (id) in (select v7 from semiDown1136359701756489) and country_code= '[us]';
create or replace view semiDown8354502104289746531 as select id as v18 from keyword AS k where (id) in (select v18 from semiDown7379028856486445004);
create or replace view aggView1669040187457707277 as select v14 from semiDown417287357033399171;
create or replace view aggJoin5623938298816870888 as select v36, v7 from semiDown1136359701756489 join aggView1669040187457707277 using(v14);
create or replace view aggView4232978919822213381 as select v16 from semiDown3202253410405775893;
create or replace view aggJoin30178696677131715 as select v36 from semiDown3042152255136962688 join aggView4232978919822213381 using(v16);
create or replace view aggView7359059972255384857 as select v5 from semiDown3362334308422269894;
create or replace view aggJoin5825684989350279521 as select v36 from semiDown7247366206814160165 join aggView7359059972255384857 using(v5);
create or replace view aggView3069812842179930795 as select v18 from semiDown8354502104289746531;
create or replace view aggJoin2260235601736272918 as select v36 from semiDown7379028856486445004 join aggView3069812842179930795 using(v18);
create or replace view aggView8804830276498341798 as select v7 from semiDown7130450318338226150;
create or replace view aggJoin2638987937897009123 as select v36 from aggJoin5623938298816870888 join aggView8804830276498341798 using(v7);
create or replace view aggView1455101636117958756 as select v36 from aggJoin5825684989350279521 group by v36;
create or replace view aggJoin5099685910051444415 as select v36, v37, v21 from semiDown1218210593157555523 join aggView1455101636117958756 using(v36);
create or replace view aggView5565392098087570998 as select v36 from aggJoin2260235601736272918 group by v36;
create or replace view aggJoin6460549774858534521 as select v36, v37, v21 from aggJoin5099685910051444415 join aggView5565392098087570998 using(v36);
create or replace view aggView4128977851976315881 as select v36 from aggJoin30178696677131715 group by v36;
create or replace view aggJoin1961046303116610395 as select v36, v37, v21 from aggJoin6460549774858534521 join aggView4128977851976315881 using(v36);
create or replace view aggView3435278389278380220 as select v36 from aggJoin2638987937897009123 group by v36;
create or replace view aggJoin1848218653384217214 as select v37, v21 from aggJoin1961046303116610395 join aggView3435278389278380220 using(v36);
create or replace view aggView236269623636863893 as select v21, v37, MIN(v37) as v49 from aggJoin1848218653384217214 group by v21,v37;
create or replace view aggView4532948765440658350 as select v21, v22 as v48 from semiDown8485069432650173080;
create or replace view aggJoin7549954218540998661 as select v49, v48 from aggView236269623636863893 join aggView4532948765440658350 using(v21);
select MIN(v48) as v48, MIN(v49) as v49 from aggJoin7549954218540998661;

