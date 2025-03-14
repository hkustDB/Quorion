create or replace view semiUp7523286591942625273 as select id as v40, title as v41 from title AS t where (id) in (select movie_id from aka_title AS aka_t) and production_year>1990;
create or replace view semiUp4883398981708754009 as select movie_id as v40, info_type_id as v22, info as v35 from movie_info AS mi where (info_type_id) in (select id from info_type AS it1 where info= 'release dates') and note LIKE '%internet%' and ((info LIKE 'USA:% 199%') OR (info LIKE 'USA:% 200%'));
create or replace view semiUp924816555839410182 as select v40, v41 from semiUp7523286591942625273 where (v40) in (select v40 from semiUp4883398981708754009);
create or replace view semiUp7209740756204970985 as select movie_id as v40, keyword_id as v24 from movie_keyword AS mk where (keyword_id) in (select id from keyword AS k);
create or replace view semiUp2731039574665390334 as select v40, v24 from semiUp7209740756204970985 where (v40) in (select v40 from semiUp924816555839410182);
create or replace view semiUp1792682070060696027 as select movie_id as v40, company_id as v13, company_type_id as v20 from movie_companies AS mc where (company_type_id) in (select id from company_type AS ct);
create or replace view semiUp8317383233282539262 as select v40, v13, v20 from semiUp1792682070060696027 where (v13) in (select id from company_name AS cn where country_code= '[us]');
create or replace view semiUp8342445335885644401 as select v40, v24 from semiUp2731039574665390334 where (v40) in (select v40 from semiUp8317383233282539262);
create or replace view semiDown6761769234932114650 as select id as v24 from keyword AS k where (id) in (select v24 from semiUp8342445335885644401);
create or replace view semiDown2637275587332482096 as select v40, v41 from semiUp924816555839410182 where (v40) in (select v40 from semiUp8342445335885644401);
create or replace view semiDown8968215775197955708 as select v40, v13, v20 from semiUp8317383233282539262 where (v40) in (select v40 from semiUp8342445335885644401);
create or replace view semiDown8227865403520878549 as select v40, v22, v35 from semiUp4883398981708754009 where (v40) in (select v40 from semiDown2637275587332482096);
create or replace view semiDown6313535390654060298 as select movie_id as v40 from aka_title AS aka_t where (movie_id) in (select v40 from semiDown2637275587332482096);
create or replace view semiDown7193469019281995707 as select id as v20 from company_type AS ct where (id) in (select v20 from semiDown8968215775197955708);
create or replace view semiDown4405456995332837861 as select id as v13 from company_name AS cn where (id) in (select v13 from semiDown8968215775197955708) and country_code= '[us]';
create or replace view semiDown7132436995391997737 as select id as v22 from info_type AS it1 where (id) in (select v22 from semiDown8227865403520878549) and info= 'release dates';
create or replace view aggView84637138195711950 as select v22 from semiDown7132436995391997737;
create or replace view aggJoin6928086923638220074 as select v40, v35 from semiDown8227865403520878549 join aggView84637138195711950 using(v22);
create or replace view aggView8350700234962930839 as select v20 from semiDown7193469019281995707;
create or replace view aggJoin5824881962409377348 as select v40, v13 from semiDown8968215775197955708 join aggView8350700234962930839 using(v20);
create or replace view aggView6513973350164881312 as select v40 from semiDown6313535390654060298 group by v40;
create or replace view aggJoin8729429981918737706 as select v40, v41 from semiDown2637275587332482096 join aggView6513973350164881312 using(v40);
create or replace view aggView9196596103015270724 as select v40, MIN(v35) as v52 from aggJoin6928086923638220074 group by v40;
create or replace view aggJoin3132677701553497225 as select v40, v41, v52 from aggJoin8729429981918737706 join aggView9196596103015270724 using(v40);
create or replace view aggView5430873839710925929 as select v13 from semiDown4405456995332837861;
create or replace view aggJoin6604571320935331276 as select v40 from aggJoin5824881962409377348 join aggView5430873839710925929 using(v13);
create or replace view aggView4812075578459298669 as select v24 from semiDown6761769234932114650;
create or replace view aggJoin7250325915905807473 as select v40 from semiUp8342445335885644401 join aggView4812075578459298669 using(v24);
create or replace view aggView516638421755160334 as select v40, MIN(v52) as v52, MIN(v41) as v53 from aggJoin3132677701553497225 group by v40,v52;
create or replace view aggJoin1226019781537528701 as select v40, v52, v53 from aggJoin7250325915905807473 join aggView516638421755160334 using(v40);
create or replace view aggView5407615510422917082 as select v40 from aggJoin6604571320935331276 group by v40;
create or replace view aggJoin5036005439917795251 as select v52 as v52, v53 as v53 from aggJoin1226019781537528701 join aggView5407615510422917082 using(v40);
select MIN(v52) as v52, MIN(v53) as v53 from aggJoin5036005439917795251;

