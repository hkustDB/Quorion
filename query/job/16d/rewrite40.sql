create or replace view aggView2600469668803248003 as select title as v44, id as v11 from title as t where episode_nr>=5 and episode_nr<100;
create or replace view aggView5039035811921623685 as select id as v2 from name as n;
create or replace view aggJoin8220009712387383918 as select person_id as v2, name as v3 from aka_name as an, aggView5039035811921623685 where an.person_id=aggView5039035811921623685.v2;
create or replace view aggView6457923872181431748 as select v3, v2 from aggJoin8220009712387383918;
create or replace view aggView8732166509924743026 as select id as v33 from keyword as k where keyword= 'character-name-in-title';
create or replace view aggJoin1770994664500510210 as select movie_id as v11 from movie_keyword as mk, aggView8732166509924743026 where mk.keyword_id=aggView8732166509924743026.v33;
create or replace view aggView5399856473519503991 as select id as v28 from company_name as cn where country_code= '[us]';
create or replace view aggJoin6494359731661687892 as select movie_id as v11 from movie_companies as mc, aggView5399856473519503991 where mc.company_id=aggView5399856473519503991.v28;
create or replace view aggView4750060332488182219 as select v2, MIN(v3) as v55 from aggView6457923872181431748 group by v2;
create or replace view aggJoin8702430795872705483 as select movie_id as v11, v55 from cast_info as ci, aggView4750060332488182219 where ci.person_id=aggView4750060332488182219.v2;
create or replace view aggView6481709368850304805 as select v11 from aggJoin6494359731661687892 group by v11;
create or replace view aggJoin572284904411444818 as select v11, v55 as v55 from aggJoin8702430795872705483 join aggView6481709368850304805 using(v11);
create or replace view aggView1249343972160261843 as select v11 from aggJoin1770994664500510210 group by v11;
create or replace view aggJoin4118604866785535967 as select v11, v55 as v55 from aggJoin572284904411444818 join aggView1249343972160261843 using(v11);
create or replace view aggView3461653956702178016 as select v11, MIN(v55) as v55 from aggJoin4118604866785535967 group by v11;
create or replace view aggJoin1433331904276865751 as select v44, v55 from aggView2600469668803248003 join aggView3461653956702178016 using(v11);
select MIN(v55) as v55,MIN(v44) as v56 from aggJoin1433331904276865751;
