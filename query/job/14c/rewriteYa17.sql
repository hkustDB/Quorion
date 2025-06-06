create or replace view semiUp8587749473238583630 as select movie_id as v23, info_type_id as v1 from movie_info AS mi where (info_type_id) in (select id from info_type AS it1 where info= 'countries') and info IN ('Sweden','Norway','Germany','Denmark','Swedish','Danish','Norwegian','German','USA','American');
create or replace view semiUp6194111233801648999 as select movie_id as v23, info_type_id as v3, info as v18 from movie_info_idx AS mi_idx where (info_type_id) in (select id from info_type AS it2 where info= 'rating') and info<'8.5';
create or replace view semiUp2022700582524182067 as select movie_id as v23, keyword_id as v5 from movie_keyword AS mk where (keyword_id) in (select id from keyword AS k where keyword IN ('murder','murder-in-title','blood','violence'));
create or replace view semiUp6419849309974857125 as select id as v23, title as v24, kind_id as v8 from title AS t where (kind_id) in (select id from kind_type AS kt where kind IN ('movie','episode')) and production_year>2005;
create or replace view semiUp7001592456146229104 as select v23, v24, v8 from semiUp6419849309974857125 where (v23) in (select v23 from semiUp8587749473238583630);
create or replace view semiUp8263640383592524986 as select v23, v3, v18 from semiUp6194111233801648999 where (v23) in (select v23 from semiUp7001592456146229104);
create or replace view semiUp3152165694822983565 as select v23, v5 from semiUp2022700582524182067 where (v23) in (select v23 from semiUp8263640383592524986);
create or replace view semiDown1253112919308740209 as select id as v5 from keyword AS k where (id) in (select v5 from semiUp3152165694822983565) and keyword IN ('murder','murder-in-title','blood','violence');
create or replace view semiDown6013624581182832889 as select v23, v3, v18 from semiUp8263640383592524986 where (v23) in (select v23 from semiUp3152165694822983565);
create or replace view semiDown2455905543184752862 as select id as v3 from info_type AS it2 where (id) in (select v3 from semiDown6013624581182832889) and info= 'rating';
create or replace view semiDown6231396494328489627 as select v23, v24, v8 from semiUp7001592456146229104 where (v23) in (select v23 from semiDown6013624581182832889);
create or replace view semiDown3318002740093495916 as select id as v8 from kind_type AS kt where (id) in (select v8 from semiDown6231396494328489627) and kind IN ('movie','episode');
create or replace view semiDown158006016716993771 as select v23, v1 from semiUp8587749473238583630 where (v23) in (select v23 from semiDown6231396494328489627);
create or replace view semiDown1733333344045537749 as select id as v1 from info_type AS it1 where (id) in (select v1 from semiDown158006016716993771) and info= 'countries';
create or replace view aggView6521366696789262038 as select v1 from semiDown1733333344045537749;
create or replace view aggJoin1488050189644001036 as select v23 from semiDown158006016716993771 join aggView6521366696789262038 using(v1);
create or replace view aggView7275904998276695699 as select v23 from aggJoin1488050189644001036 group by v23;
create or replace view aggJoin103906422714925467 as select v23, v24, v8 from semiDown6231396494328489627 join aggView7275904998276695699 using(v23);
create or replace view aggView8317885761299764831 as select v8 from semiDown3318002740093495916;
create or replace view aggJoin6179624140485833515 as select v23, v24 from aggJoin103906422714925467 join aggView8317885761299764831 using(v8);
create or replace view aggView8375930810814357381 as select v3 from semiDown2455905543184752862;
create or replace view aggJoin4427186483677630176 as select v23, v18 from semiDown6013624581182832889 join aggView8375930810814357381 using(v3);
create or replace view aggView6000998823939288515 as select v23, MIN(v24) as v36 from aggJoin6179624140485833515 group by v23;
create or replace view aggJoin1597457204458365149 as select v23, v18, v36 from aggJoin4427186483677630176 join aggView6000998823939288515 using(v23);
create or replace view aggView7282005607920607787 as select v23, MIN(v36) as v36, MIN(v18) as v35 from aggJoin1597457204458365149 group by v23,v36;
create or replace view aggJoin2971974734434442104 as select v5, v36, v35 from semiUp3152165694822983565 join aggView7282005607920607787 using(v23);
create or replace view aggView7770668069483132021 as select v5 from semiDown1253112919308740209;
create or replace view aggJoin1698029259741635212 as select v36, v35 from aggJoin2971974734434442104 join aggView7770668069483132021 using(v5);
select MIN(v35) as v35, MIN(v36) as v36 from aggJoin1698029259741635212;

