create or replace view semiUp9156362626935830906 as select movie_id as v13, keyword_id as v8 from movie_keyword AS mk where (keyword_id) in (select id from keyword AS k where keyword= 'character-name-in-title');
create or replace view semiUp5596634988636654599 as select movie_id as v13, linked_movie_id as v11, link_type_id as v4 from movie_link AS ml where (movie_id) in (select id from title AS t1);
create or replace view semiUp4129265695209659938 as select v13, v11, v4 from semiUp5596634988636654599 where (v11) in (select id from title AS t2);
create or replace view semiUp7974441424270621666 as select v13, v11, v4 from semiUp4129265695209659938 where (v4) in (select id from link_type AS lt);
create or replace view semiUp4298849709244224452 as select v13, v8 from semiUp9156362626935830906 where (v13) in (select v13 from semiUp7974441424270621666);
create or replace view semiDown1911735033627140414 as select id as v8 from keyword AS k where (id) in (select v8 from semiUp4298849709244224452) and keyword= 'character-name-in-title';
create or replace view semiDown6468180165888917965 as select v13, v11, v4 from semiUp7974441424270621666 where (v13) in (select v13 from semiUp4298849709244224452);
create or replace view semiDown3668509994088860126 as select id as v4, link as v5 from link_type AS lt where (id) in (select v4 from semiDown6468180165888917965);
create or replace view semiDown6487782343274081401 as select id as v11, title as v26 from title AS t2 where (id) in (select v11 from semiDown6468180165888917965);
create or replace view semiDown1600639530529384731 as select id as v13, title as v14 from title AS t1 where (id) in (select v13 from semiDown6468180165888917965);
create or replace view aggView4789938700194090672 as select v4, v5 as v37 from semiDown3668509994088860126;
create or replace view aggJoin2005301764032079988 as select v13, v11, v37 from semiDown6468180165888917965 join aggView4789938700194090672 using(v4);
create or replace view aggView1722758423313385668 as select v11, v26 as v39 from semiDown6487782343274081401;
create or replace view aggJoin7089292424554774823 as select v13, v37, v39 from aggJoin2005301764032079988 join aggView1722758423313385668 using(v11);
create or replace view aggView1079141692516890548 as select v13, v14 as v38 from semiDown1600639530529384731;
create or replace view aggJoin8917515549595700593 as select v13, v37, v39, v38 from aggJoin7089292424554774823 join aggView1079141692516890548 using(v13);
create or replace view aggView8058556769629372629 as select v13, MIN(v37) as v37, MIN(v39) as v39, MIN(v38) as v38 from aggJoin8917515549595700593 group by v13,v38,v39,v37;
create or replace view aggJoin3200362918834653131 as select v8, v37, v39, v38 from semiUp4298849709244224452 join aggView8058556769629372629 using(v13);
create or replace view aggView7610510216860841450 as select v8 from semiDown1911735033627140414;
create or replace view aggJoin2539994223916139513 as select v37, v39, v38 from aggJoin3200362918834653131 join aggView7610510216860841450 using(v8);
select MIN(v37) as v37, MIN(v38) as v38, MIN(v39) as v39 from aggJoin2539994223916139513;

