create or replace view semiUp2119481057841957628 as select movie_id as v29, info_type_id as v21 from movie_info AS mi where (info_type_id) in (select id from info_type AS it1 where info= 'genres') and info IN ('Drama','Horror');
create or replace view tAux10 as select id as v29, title as v30 from title where production_year<=2008 and production_year>=2005;
create or replace view semiUp5888202951510964319 as select movie_id as v29, info_type_id as v26, info as v27 from movie_info_idx AS mi_idx where (movie_id) in (select v29 from semiUp2119481057841957628);
create or replace view cnAux55 as select id as v1, name as v2 from company_name where country_code= '[us]';
create or replace view semiUp1438805985293193048 as select v29, v26, v27 from semiUp5888202951510964319 where (v26) in (select id from info_type AS it2 where info= 'rating');
create or replace view mi_idxAux91 as select v29, v27 from semiUp1438805985293193048;
create or replace view semiUp1302367930594699539 as select movie_id as v29, company_id as v1, company_type_id as v8 from movie_companies AS mc where (company_type_id) in (select id from company_type AS ct where kind= 'production companies');
create or replace view semiUp7872048875799890208 as select v29, v1, v8 from semiUp1302367930594699539 where (v29) in (select v29 from tAux10);
create or replace view semiUp6956703193981504267 as select v29, v1, v8 from semiUp7872048875799890208 where (v29) in (select v29 from mi_idxAux91);
create or replace view semiUp8684773260409174426 as select v1, v2 from cnAux55 where (v1) in (select v1 from semiUp6956703193981504267);
create or replace view semiDown1499076196340003994 as select id as v1, name as v2 from company_name AS cn where (id, name) in (select v1, v2 from semiUp8684773260409174426) and country_code= '[us]';
create or replace view semiDown8197226535943493855 as select v29, v1, v8 from semiUp6956703193981504267 where (v1) in (select v1 from semiUp8684773260409174426);
create or replace view semiDown8192799538773516410 as select id as v8 from company_type AS ct where (id) in (select v8 from semiDown8197226535943493855) and kind= 'production companies';
create or replace view semiDown8210767646650899030 as select v29, v27 from mi_idxAux91 where (v29) in (select v29 from semiDown8197226535943493855);
create or replace view semiDown4096002558831046002 as select v29, v30 from tAux10 where (v29) in (select v29 from semiDown8197226535943493855);
create or replace view semiDown2248240684100158763 as select v29, v26, v27 from semiUp1438805985293193048 where (v29, v27) in (select v29, v27 from semiDown8210767646650899030);
create or replace view semiDown3917858813597426291 as select id as v29, title as v30 from title AS t where (title, id) in (select v30, v29 from semiDown4096002558831046002) and production_year<=2008 and production_year>=2005;
create or replace view semiDown6089190552533979645 as select id as v26 from info_type AS it2 where (id) in (select v26 from semiDown2248240684100158763) and info= 'rating';
create or replace view semiDown6194032810356584999 as select v29, v21 from semiUp2119481057841957628 where (v29) in (select v29 from semiDown2248240684100158763);
create or replace view semiDown7569323562089902596 as select id as v21 from info_type AS it1 where (id) in (select v21 from semiDown6194032810356584999) and info= 'genres';
create or replace view aggView1010062867256175482 as select v30, v29, v30 as v43 from semiDown3917858813597426291;
create or replace view aggView7342481835328793355 as select v1, v2, v2 as v41 from semiDown1499076196340003994;
create or replace view aggView4023540619607834200 as select v21 from semiDown7569323562089902596;
create or replace view aggJoin3193591281483839693 as select v29 from semiDown6194032810356584999 join aggView4023540619607834200 using(v21);
create or replace view aggView6117766248112756018 as select v26 from semiDown6089190552533979645;
create or replace view aggJoin6298588372973848528 as select v29, v27 from semiDown2248240684100158763 join aggView6117766248112756018 using(v26);
create or replace view aggView3843939532075784507 as select v29 from aggJoin3193591281483839693 group by v29;
create or replace view aggJoin7363560228092308444 as select v29, v27 from aggJoin6298588372973848528 join aggView3843939532075784507 using(v29);
create or replace view aggView8383064378921607661 as select v29, v27, MIN(v27) as v42 from aggJoin7363560228092308444 group by v29,v27;
create or replace view aggView485661367814333319 as select v8 from semiDown8192799538773516410;
create or replace view aggJoin4040824056614463968 as select v29, v1 from semiDown8197226535943493855 join aggView485661367814333319 using(v8);
create or replace view aggView7760435533875418905 as select v29, MIN(v42) as v42 from aggView8383064378921607661 group by v29,v42;
create or replace view aggJoin1735160293874895239 as select v29, v1, v42 from aggJoin4040824056614463968 join aggView7760435533875418905 using(v29);
create or replace view aggView3519544047422295437 as select v29, MIN(v43) as v43 from aggView1010062867256175482 group by v29,v43;
create or replace view aggJoin8573408293033590355 as select v1, v42 as v42, v43 from aggJoin1735160293874895239 join aggView3519544047422295437 using(v29);
create or replace view aggView1427686511802877115 as select v1, MIN(v42) as v42, MIN(v43) as v43 from aggJoin8573408293033590355 group by v1,v43,v42;
create or replace view aggJoin5825706948628228666 as select v41 as v41, v42, v43 from aggView7342481835328793355 join aggView1427686511802877115 using(v1);
select MIN(v41) as v41, MIN(v42) as v42, MIN(v43) as v43 from aggJoin5825706948628228666;

