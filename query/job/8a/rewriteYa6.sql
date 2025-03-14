create or replace view an1Aux17 as select person_id as v2, name as v3 from aka_name;
create or replace view semiUp1485131849253723208 as select movie_id as v11, company_id as v25 from movie_companies AS mc where (company_id) in (select id from company_name AS cn where country_code= '[jp]') and note NOT LIKE '%(USA)%' and note LIKE '%(Japan)%';
create or replace view semiUp3378429911854596917 as select id as v11, title as v40 from title AS t where (id) in (select v11 from semiUp1485131849253723208);
create or replace view tAux84 as select v11, v40 from semiUp3378429911854596917;
create or replace view semiUp2611110969810972611 as select person_id as v2, movie_id as v11, role_id as v15 from cast_info AS ci where (person_id) in (select id from name AS n1 where name LIKE '%Yo%' and name NOT LIKE '%Yu%') and note= '(voice: English version)';
create or replace view semiUp3898452343631042972 as select v2, v11, v15 from semiUp2611110969810972611 where (v2) in (select v2 from an1Aux17);
create or replace view semiUp3264366138115430402 as select v2, v11, v15 from semiUp3898452343631042972 where (v15) in (select id from role_type AS rt where role= 'actress');
create or replace view semiUp6845940467001913278 as select v11, v40 from tAux84 where (v11) in (select v11 from semiUp3264366138115430402);
create or replace view semiDown4687544097023118117 as select v2, v11, v15 from semiUp3264366138115430402 where (v11) in (select v11 from semiUp6845940467001913278);
create or replace view semiDown9173593882751514722 as select v11, v40 from semiUp3378429911854596917 where (v11, v40) in (select v11, v40 from semiUp6845940467001913278);
create or replace view semiDown9031063770596631623 as select id as v15 from role_type AS rt where (id) in (select v15 from semiDown4687544097023118117) and role= 'actress';
create or replace view semiDown6089487535647929612 as select id as v2 from name AS n1 where (id) in (select v2 from semiDown4687544097023118117) and name LIKE '%Yo%' and name NOT LIKE '%Yu%';
create or replace view semiDown598052454683968575 as select v2, v3 from an1Aux17 where (v2) in (select v2 from semiDown4687544097023118117);
create or replace view semiDown1724126526571399742 as select v11, v25 from semiUp1485131849253723208 where (v11) in (select v11 from semiDown9173593882751514722);
create or replace view semiDown7372813092638650902 as select person_id as v2, name as v3 from aka_name AS an1 where (name, person_id) in (select v3, v2 from semiDown598052454683968575);
create or replace view semiDown6776412408987531692 as select id as v25 from company_name AS cn where (id) in (select v25 from semiDown1724126526571399742) and country_code= '[jp]';
create or replace view aggView7959648249991240143 as select v3, v2, MIN(v3) as v51 from semiDown7372813092638650902 group by v3,v2;
create or replace view aggView1060467536180460650 as select v25 from semiDown6776412408987531692;
create or replace view aggJoin6958045019784729764 as select v11 from semiDown1724126526571399742 join aggView1060467536180460650 using(v25);
create or replace view aggView7032088398426609843 as select v11 from aggJoin6958045019784729764 group by v11;
create or replace view aggJoin4848694357568234860 as select v11, v40 from semiDown9173593882751514722 join aggView7032088398426609843 using(v11);
create or replace view aggView5445760139239154164 as select v11, v40, MIN(v40) as v52 from aggJoin4848694357568234860 group by v11,v40;
create or replace view aggView8758454742410351961 as select v2, MIN(v51) as v51 from aggView7959648249991240143 group by v2,v51;
create or replace view aggJoin2627224119721290104 as select v2, v11, v15, v51 from semiDown4687544097023118117 join aggView8758454742410351961 using(v2);
create or replace view aggView5408378353118901013 as select v15 from semiDown9031063770596631623;
create or replace view aggJoin2405249485681036521 as select v2, v11, v51 from aggJoin2627224119721290104 join aggView5408378353118901013 using(v15);
create or replace view aggView2377487478531321040 as select v2 from semiDown6089487535647929612;
create or replace view aggJoin527594355867456143 as select v11, v51 from aggJoin2405249485681036521 join aggView2377487478531321040 using(v2);
create or replace view aggView1652608610836671428 as select v11, MIN(v51) as v51 from aggJoin527594355867456143 group by v11,v51;
create or replace view aggJoin807240176638424468 as select v52 as v52, v51 from aggView5445760139239154164 join aggView1652608610836671428 using(v11);
select MIN(v51) as v51, MIN(v52) as v52 from aggJoin807240176638424468;

