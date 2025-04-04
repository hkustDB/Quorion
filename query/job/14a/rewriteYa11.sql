create or replace view semiUp8654513778418544727 as select movie_id as v23, info_type_id as v1 from movie_info AS mi where (info_type_id) in (select id from info_type AS it1 where info= 'countries') and info IN ('Sweden','Norway','Germany','Denmark','Swedish','Denish','Norwegian','German','USA','American');
create or replace view semiUp298997691752599968 as select movie_id as v23, info_type_id as v3, info as v18 from movie_info_idx AS mi_idx where (info_type_id) in (select id from info_type AS it2 where info= 'rating');
create or replace view semiUp7829279743168214112 as select v23, v3, v18 from semiUp298997691752599968 where (v23) in (select v23 from semiUp8654513778418544727);
create or replace view mi_idxAux71 as select v23, v18 from semiUp7829279743168214112;
create or replace view semiUp627217275882118689 as select movie_id as v23, keyword_id as v5 from movie_keyword AS mk where (keyword_id) in (select id from keyword AS k where keyword IN ('murder','murder-in-title','blood','violence'));
create or replace view semiUp7108673476829581715 as select id as v23, title as v24, kind_id as v8 from title AS t where (id) in (select v23 from semiUp627217275882118689) and production_year>2010;
create or replace view semiUp4708548144764958527 as select v23, v24, v8 from semiUp7108673476829581715 where (v8) in (select id from kind_type AS kt where kind= 'movie');
create or replace view tAux57 as select v23, v24 from semiUp4708548144764958527;
create or replace view semiUp1981544887361111527 as select v23, v24 from tAux57 where (v23) in (select v23 from mi_idxAux71);
create or replace view semiDown752404687855021918 as select v23, v24, v8 from semiUp4708548144764958527 where (v23, v24) in (select v23, v24 from semiUp1981544887361111527);
create or replace view semiDown5606355987962955682 as select v23, v18 from mi_idxAux71 where (v23) in (select v23 from semiUp1981544887361111527);
create or replace view semiDown3949063132836509762 as select id as v8 from kind_type AS kt where (id) in (select v8 from semiDown752404687855021918) and kind= 'movie';
create or replace view semiDown6236820209084086569 as select v23, v5 from semiUp627217275882118689 where (v23) in (select v23 from semiDown752404687855021918);
create or replace view semiDown3476629967951736936 as select v23, v3, v18 from semiUp7829279743168214112 where (v23, v18) in (select v23, v18 from semiDown5606355987962955682);
create or replace view semiDown3771715847558477300 as select id as v5 from keyword AS k where (id) in (select v5 from semiDown6236820209084086569) and keyword IN ('murder','murder-in-title','blood','violence');
create or replace view semiDown7275681190157190043 as select id as v3 from info_type AS it2 where (id) in (select v3 from semiDown3476629967951736936) and info= 'rating';
create or replace view semiDown8293865328455521630 as select v23, v1 from semiUp8654513778418544727 where (v23) in (select v23 from semiDown3476629967951736936);
create or replace view semiDown8504353343649918802 as select id as v1 from info_type AS it1 where (id) in (select v1 from semiDown8293865328455521630) and info= 'countries';
create or replace view aggView5587978898864725360 as select v1 from semiDown8504353343649918802;
create or replace view aggJoin2182525576383394372 as select v23 from semiDown8293865328455521630 join aggView5587978898864725360 using(v1);
create or replace view aggView5709857024375368424 as select v23 from aggJoin2182525576383394372 group by v23;
create or replace view aggJoin7669470634924797499 as select v23, v3, v18 from semiDown3476629967951736936 join aggView5709857024375368424 using(v23);
create or replace view aggView983850486786404753 as select v5 from semiDown3771715847558477300;
create or replace view aggJoin3888234276305931793 as select v23 from semiDown6236820209084086569 join aggView983850486786404753 using(v5);
create or replace view aggView5657870128774729646 as select v3 from semiDown7275681190157190043;
create or replace view aggJoin6718419875102787470 as select v23, v18 from aggJoin7669470634924797499 join aggView5657870128774729646 using(v3);
create or replace view aggView8819859166386905558 as select v23, v18, MIN(v18) as v35 from aggJoin6718419875102787470 group by v23,v18;
create or replace view aggView2570418280015047331 as select v23 from aggJoin3888234276305931793 group by v23;
create or replace view aggJoin7774283419907765020 as select v23, v24, v8 from semiDown752404687855021918 join aggView2570418280015047331 using(v23);
create or replace view aggView5509643105699757522 as select v8 from semiDown3949063132836509762;
create or replace view aggJoin3496727846946953696 as select v23, v24 from aggJoin7774283419907765020 join aggView5509643105699757522 using(v8);
create or replace view aggView9096237908353752399 as select v23, v24, MIN(v24) as v36 from aggJoin3496727846946953696 group by v23,v24;
create or replace view aggView1980877163018253092 as select v23, MIN(v35) as v35 from aggView8819859166386905558 group by v23,v35;
create or replace view aggJoin6879741284196216574 as select v36 as v36, v35 from aggView9096237908353752399 join aggView1980877163018253092 using(v23);
select MIN(v35) as v35, MIN(v36) as v36 from aggJoin6879741284196216574;

