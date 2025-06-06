create or replace view nAux84 as select id as v42, name as v43 from name where gender= 'f';
create or replace view tAux73 as select id as v53, title as v54 from title where production_year>2000;
create or replace view semiUp7862073870793601296 as select person_id as v42, movie_id as v53, person_role_id as v9, role_id as v51 from cast_info AS ci where (movie_id) in (select v53 from tAux73) and note IN ('(voice)','(voice: Japanese version)','(voice) (uncredited)','(voice: English version)');
create or replace view semiUp7930627390107355978 as select movie_id as v53, company_id as v23 from movie_companies AS mc where (company_id) in (select id from company_name AS cn where country_code= '[us]');
create or replace view semiUp4004802440641085505 as select v42, v53, v9, v51 from semiUp7862073870793601296 where (v51) in (select id from role_type AS rt where role= 'actress');
create or replace view semiUp8011277082723274721 as select v42, v53, v9, v51 from semiUp4004802440641085505 where (v53) in (select v53 from semiUp7930627390107355978);
create or replace view semiUp3055503898026893729 as select movie_id as v53, info_type_id as v30 from movie_info AS mi where (info_type_id) in (select id from info_type AS it where info= 'release dates');
create or replace view semiUp1793378358288566526 as select v42, v53, v9, v51 from semiUp8011277082723274721 where (v53) in (select v53 from semiUp3055503898026893729);
create or replace view semiUp6836845197941005494 as select v42, v53, v9, v51 from semiUp1793378358288566526 where (v42) in (select person_id from aka_name AS an);
create or replace view semiUp1136836662645793365 as select v42, v53, v9, v51 from semiUp6836845197941005494 where (v9) in (select id from char_name AS chn);
create or replace view semiUp2389646335485067501 as select v42, v43 from nAux84 where (v42) in (select v42 from semiUp1136836662645793365);
create or replace view semiDown5859823668273005051 as select v42, v53, v9, v51 from semiUp1136836662645793365 where (v42) in (select v42 from semiUp2389646335485067501);
create or replace view semiDown4556324879321134877 as select id as v42, name as v43 from name AS n where (id, name) in (select v42, v43 from semiUp2389646335485067501) and gender= 'f';
create or replace view semiDown5372263412197355982 as select id as v51 from role_type AS rt where (id) in (select v51 from semiDown5859823668273005051) and role= 'actress';
create or replace view semiDown3760226609913655074 as select person_id as v42 from aka_name AS an where (person_id) in (select v42 from semiDown5859823668273005051);
create or replace view semiDown274470823411460788 as select v53, v54 from tAux73 where (v53) in (select v53 from semiDown5859823668273005051);
create or replace view semiDown7653257691071023768 as select v53, v23 from semiUp7930627390107355978 where (v53) in (select v53 from semiDown5859823668273005051);
create or replace view semiDown3242930561767625506 as select id as v9 from char_name AS chn where (id) in (select v9 from semiDown5859823668273005051);
create or replace view semiDown2332181970504312198 as select v53, v30 from semiUp3055503898026893729 where (v53) in (select v53 from semiDown5859823668273005051);
create or replace view semiDown7327115505400229788 as select id as v53, title as v54 from title AS t where (id, title) in (select v53, v54 from semiDown274470823411460788) and production_year>2000;
create or replace view semiDown6118905947092398865 as select id as v23 from company_name AS cn where (id) in (select v23 from semiDown7653257691071023768) and country_code= '[us]';
create or replace view semiDown8071188570658485867 as select id as v30 from info_type AS it where (id) in (select v30 from semiDown2332181970504312198) and info= 'release dates';
create or replace view aggView9034893053534216179 as select v53, v54, v54 as v66 from semiDown7327115505400229788;
create or replace view aggView4176020902872236774 as select v42, v43, v43 as v65 from semiDown4556324879321134877;
create or replace view aggView436801890692223948 as select v30 from semiDown8071188570658485867;
create or replace view aggJoin1169560785473474216 as select v53 from semiDown2332181970504312198 join aggView436801890692223948 using(v30);
create or replace view aggView2575296722595635355 as select v23 from semiDown6118905947092398865;
create or replace view aggJoin5794022902229880304 as select v53 from semiDown7653257691071023768 join aggView2575296722595635355 using(v23);
create or replace view aggView5037134794492964555 as select v53, MIN(v66) as v66 from aggView9034893053534216179 group by v53,v66;
create or replace view aggJoin6261223203795146479 as select v42, v53, v9, v51, v66 from semiDown5859823668273005051 join aggView5037134794492964555 using(v53);
create or replace view aggView2181065633246731549 as select v51 from semiDown5372263412197355982;
create or replace view aggJoin2350964897817363597 as select v42, v53, v9, v66 from aggJoin6261223203795146479 join aggView2181065633246731549 using(v51);
create or replace view aggView3702449401870464511 as select v42 from semiDown3760226609913655074 group by v42;
create or replace view aggJoin9121775449943768221 as select v42, v53, v9, v66 as v66 from aggJoin2350964897817363597 join aggView3702449401870464511 using(v42);
create or replace view aggView3636256939606621515 as select v53 from aggJoin1169560785473474216 group by v53;
create or replace view aggJoin4097077785306041242 as select v42, v53, v9, v66 as v66 from aggJoin9121775449943768221 join aggView3636256939606621515 using(v53);
create or replace view aggView3705094061811193222 as select v9 from semiDown3242930561767625506;
create or replace view aggJoin9076345002738674459 as select v42, v53, v66 from aggJoin4097077785306041242 join aggView3705094061811193222 using(v9);
create or replace view aggView4835724307358331230 as select v53 from aggJoin5794022902229880304 group by v53;
create or replace view aggJoin7256044094809113298 as select v42, v66 as v66 from aggJoin9076345002738674459 join aggView4835724307358331230 using(v53);
create or replace view aggView2593414330739169678 as select v42, MIN(v66) as v66 from aggJoin7256044094809113298 group by v42,v66;
create or replace view aggJoin8944886877712162390 as select v65 as v65, v66 from aggView4176020902872236774 join aggView2593414330739169678 using(v42);
select MIN(v65) as v65, MIN(v66) as v66 from aggJoin8944886877712162390;

