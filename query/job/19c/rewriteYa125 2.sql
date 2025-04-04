create or replace view nAux54 as select id as v42, name as v43 from name where name LIKE '%An%' and gender= 'f';
create or replace view tAux2 as select id as v53, title as v54 from title where production_year>2000;
create or replace view semiUp2919022710413937875 as select movie_id as v53, company_id as v23 from movie_companies AS mc where (company_id) in (select id from company_name AS cn where country_code= '[us]');
create or replace view semiUp4262138845977962970 as select movie_id as v53, info_type_id as v30 from movie_info AS mi where (info_type_id) in (select id from info_type AS it where info= 'release dates') and ((info LIKE 'Japan:%200%') OR (info LIKE 'USA:%200%'));
create or replace view semiUp24910760757335077 as select person_id as v42, movie_id as v53, person_role_id as v9, role_id as v51 from cast_info AS ci where (person_role_id) in (select id from char_name AS chn) and note IN ('(voice)','(voice: Japanese version)','(voice) (uncredited)','(voice: English version)');
create or replace view semiUp1808055862094897960 as select v42, v53, v9, v51 from semiUp24910760757335077 where (v53) in (select v53 from semiUp2919022710413937875);
create or replace view semiUp1349577514756657493 as select v42, v53, v9, v51 from semiUp1808055862094897960 where (v51) in (select id from role_type AS rt where role= 'actress');
create or replace view semiUp809516325988499921 as select v42, v53, v9, v51 from semiUp1349577514756657493 where (v53) in (select v53 from semiUp4262138845977962970);
create or replace view semiUp1924909201681363551 as select v42, v53, v9, v51 from semiUp809516325988499921 where (v42) in (select person_id from aka_name AS an);
create or replace view semiUp7116071328776941871 as select v42, v53, v9, v51 from semiUp1924909201681363551 where (v53) in (select v53 from tAux2);
create or replace view semiUp313376643939099393 as select v42, v43 from nAux54 where (v42) in (select v42 from semiUp7116071328776941871);
create or replace view semiDown8355949506907920664 as select id as v42, name as v43 from name AS n where (name, id) in (select v43, v42 from semiUp313376643939099393) and name LIKE '%An%' and gender= 'f';
create or replace view semiDown4362611948200474456 as select v42, v53, v9, v51 from semiUp7116071328776941871 where (v42) in (select v42 from semiUp313376643939099393);
create or replace view semiDown9023726569066081717 as select id as v51 from role_type AS rt where (id) in (select v51 from semiDown4362611948200474456) and role= 'actress';
create or replace view semiDown3401830368342764078 as select v53, v30 from semiUp4262138845977962970 where (v53) in (select v53 from semiDown4362611948200474456);
create or replace view semiDown4882578030459463911 as select person_id as v42 from aka_name AS an where (person_id) in (select v42 from semiDown4362611948200474456);
create or replace view semiDown5972829187705339719 as select v53, v54 from tAux2 where (v53) in (select v53 from semiDown4362611948200474456);
create or replace view semiDown3717775386860189235 as select v53, v23 from semiUp2919022710413937875 where (v53) in (select v53 from semiDown4362611948200474456);
create or replace view semiDown4449059337055300223 as select id as v9 from char_name AS chn where (id) in (select v9 from semiDown4362611948200474456);
create or replace view semiDown590748725425260417 as select id as v30 from info_type AS it where (id) in (select v30 from semiDown3401830368342764078) and info= 'release dates';
create or replace view semiDown8969901173306922712 as select id as v53, title as v54 from title AS t where (title, id) in (select v54, v53 from semiDown5972829187705339719) and production_year>2000;
create or replace view semiDown7815198979186686178 as select id as v23 from company_name AS cn where (id) in (select v23 from semiDown3717775386860189235) and country_code= '[us]';
create or replace view aggView5790660506134129676 as select v54, v53, v54 as v66 from semiDown8969901173306922712;
create or replace view aggView3965754042006490815 as select v43, v42, v43 as v65 from semiDown8355949506907920664;
create or replace view aggView8106943046083228631 as select v23 from semiDown7815198979186686178;
create or replace view aggJoin6869480544873074488 as select v53 from semiDown3717775386860189235 join aggView8106943046083228631 using(v23);
create or replace view aggView3237336975161771050 as select v30 from semiDown590748725425260417;
create or replace view aggJoin1896536973398891041 as select v53 from semiDown3401830368342764078 join aggView3237336975161771050 using(v30);
create or replace view aggView1742615216968111395 as select v51 from semiDown9023726569066081717;
create or replace view aggJoin6900472131523282591 as select v42, v53, v9 from semiDown4362611948200474456 join aggView1742615216968111395 using(v51);
create or replace view aggView3197039141580396904 as select v53, MIN(v66) as v66 from aggView5790660506134129676 group by v53,v66;
create or replace view aggJoin1944075768379760126 as select v42, v53, v9, v66 from aggJoin6900472131523282591 join aggView3197039141580396904 using(v53);
create or replace view aggView4511203548899377428 as select v42 from semiDown4882578030459463911 group by v42;
create or replace view aggJoin6159451694624266335 as select v42, v53, v9, v66 as v66 from aggJoin1944075768379760126 join aggView4511203548899377428 using(v42);
create or replace view aggView180368638951018424 as select v53 from aggJoin6869480544873074488 group by v53;
create or replace view aggJoin3926955624595105669 as select v42, v53, v9, v66 as v66 from aggJoin6159451694624266335 join aggView180368638951018424 using(v53);
create or replace view aggView7765314828486989700 as select v9 from semiDown4449059337055300223;
create or replace view aggJoin8055505697010160291 as select v42, v53, v66 from aggJoin3926955624595105669 join aggView7765314828486989700 using(v9);
create or replace view aggView1359727850328635581 as select v53 from aggJoin1896536973398891041 group by v53;
create or replace view aggJoin133736848176092685 as select v42, v66 as v66 from aggJoin8055505697010160291 join aggView1359727850328635581 using(v53);
create or replace view aggView2142481625687574984 as select v42, MIN(v66) as v66 from aggJoin133736848176092685 group by v42,v66;
create or replace view aggJoin6164604183734567126 as select v65 as v65, v66 from aggView3965754042006490815 join aggView2142481625687574984 using(v42);
select MIN(v65) as v65, MIN(v66) as v66 from aggJoin6164604183734567126;

