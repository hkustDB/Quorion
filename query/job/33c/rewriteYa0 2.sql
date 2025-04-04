create or replace view semiUp4338654293678258787 as select movie_id as v61, info_type_id as v17, info as v43 from movie_info_idx AS mi_idx2 where (info_type_id) in (select id from info_type AS it2 where info= 'rating') and info<'3.5';
create or replace view semiUp7507979986100463595 as select movie_id as v49, linked_movie_id as v61, link_type_id as v23 from movie_link AS ml where (linked_movie_id) in (select v61 from semiUp4338654293678258787);
create or replace view semiUp5775193712759763731 as select v49, v61, v23 from semiUp7507979986100463595 where (v23) in (select id from link_type AS lt where link IN ('sequel','follows','followed by'));
create or replace view semiUp5095238079020307497 as select id as v61, title as v62, kind_id as v21 from title AS t2 where (id) in (select v61 from semiUp5775193712759763731) and production_year>=2000 and production_year<=2010;
create or replace view semiUp7268873722694119700 as select id as v21 from kind_type AS kt2 where (id) in (select v21 from semiUp5095238079020307497) and kind IN ('tv series','episode');
create or replace view semiUp1257137345722919649 as select movie_id as v49, info_type_id as v15, info as v38 from movie_info_idx AS mi_idx1;
create or replace view semiUp1482626368908862921 as select id as v15 from info_type AS it1 where (id) in (select v15 from semiUp1257137345722919649) and info= 'rating';
create or replace view semiUp4989559420091697758 as select id as v49, title as v50, kind_id as v19 from title AS t1;
create or replace view semiUp2287642481616480034 as select id as v19 from kind_type AS kt1 where (id) in (select v19 from semiUp4989559420091697758) and kind IN ('tv series','episode');
create or replace view semiUp3544665329606847067 as select movie_id as v49, company_id as v1 from movie_companies AS mc1;
create or replace view semiUp5669642876154015291 as select id as v1, name as v2 from company_name AS cn1 where (id) in (select v1 from semiUp3544665329606847067) and country_code<> '[us]';
create or replace view semiUp8597904950713670666 as select movie_id as v61, company_id as v8 from movie_companies AS mc2;
create or replace view semiUp2257813511332640811 as select id as v8, name as v9 from company_name AS cn2 where (id) in (select v8 from semiUp8597904950713670666);
create or replace view semiDown4863134209546772758 as select v61, v8 from semiUp8597904950713670666 where (v8) in (select v8 from semiUp2257813511332640811);
create or replace view semiDown6289300152359812918 as select v1, v2 from semiUp5669642876154015291;
create or replace view semiDown4554699762567596777 as select v49, v1 from semiUp3544665329606847067 where (v1) in (select v1 from semiDown6289300152359812918);
create or replace view semiDown4574886433772555824 as select v19 from semiUp2287642481616480034;
create or replace view semiDown804107243577311427 as select v49, v50, v19 from semiUp4989559420091697758 where (v19) in (select v19 from semiDown4574886433772555824);
create or replace view semiDown6830873560724278609 as select v15 from semiUp1482626368908862921;
create or replace view semiDown6704922643674744967 as select v49, v15, v38 from semiUp1257137345722919649 where (v15) in (select v15 from semiDown6830873560724278609);
create or replace view semiDown8264813614547609966 as select v21 from semiUp7268873722694119700;
create or replace view semiDown6422022538467071503 as select v61, v62, v21 from semiUp5095238079020307497 where (v21) in (select v21 from semiDown8264813614547609966);
create or replace view semiDown1070666759124123079 as select v49, v61, v23 from semiUp5775193712759763731 where (v61) in (select v61 from semiDown6422022538467071503);
create or replace view semiDown2239414409180494647 as select id as v23 from link_type AS lt where (id) in (select v23 from semiDown1070666759124123079) and link IN ('sequel','follows','followed by');
create or replace view semiDown3964057303094587003 as select v61, v17, v43 from semiUp4338654293678258787 where (v61) in (select v61 from semiDown1070666759124123079);
create or replace view semiDown7469144856956705095 as select id as v17 from info_type AS it2 where (id) in (select v17 from semiDown3964057303094587003) and info= 'rating';
create or replace view aggView2358412340888007342 as select v17 from semiDown7469144856956705095;
create or replace view aggJoin8757713157122351586 as select v61, v43 from semiDown3964057303094587003 join aggView2358412340888007342 using(v17);
create or replace view aggView2202869463790855972 as select v61, MIN(v43) as v76 from aggJoin8757713157122351586 group by v61;
create or replace view aggJoin6078750361269152009 as select v49, v61, v23, v76 from semiDown1070666759124123079 join aggView2202869463790855972 using(v61);
create or replace view aggView6386411988816103312 as select v23 from semiDown2239414409180494647;
create or replace view aggJoin4054399544617600090 as select v49, v61, v76 from aggJoin6078750361269152009 join aggView6386411988816103312 using(v23);
create or replace view aggView7290920236504360104 as select v61, v49, MIN(v76) as v76 from aggJoin4054399544617600090 group by v61,v49,v76;
create or replace view aggJoin1712235905128737511 as select v61, v62, v21, v49, v76 from semiDown6422022538467071503 join aggView7290920236504360104 using(v61);
create or replace view aggView1196628476948186313 as select v21, v61, v49, MIN(v76) as v76, MIN(v62) as v78 from aggJoin1712235905128737511 group by v21,v61,v49,v76;
create or replace view aggJoin825321821547489195 as select v61, v49, v76, v78 from semiDown8264813614547609966 join aggView1196628476948186313 using(v21);
create or replace view aggView4017108778413454309 as select v49, v61, MIN(v76) as v76, MIN(v78) as v78 from aggJoin825321821547489195 group by v49,v61,v78,v76;
create or replace view aggJoin7635882566955394721 as select v49, v15, v38, v61, v76, v78 from semiDown6704922643674744967 join aggView4017108778413454309 using(v49);
create or replace view aggView2196110798785275941 as select v15, v61, v49, MIN(v76) as v76, MIN(v78) as v78, MIN(v38) as v75 from aggJoin7635882566955394721 group by v15,v61,v49,v78,v76;
create or replace view aggJoin6752519734802714001 as select v61, v49, v76, v78, v75 from semiDown6830873560724278609 join aggView2196110798785275941 using(v15);
create or replace view aggView2490767948401179689 as select v49, v61, MIN(v76) as v76, MIN(v78) as v78, MIN(v75) as v75 from aggJoin6752519734802714001 group by v49,v61,v78,v76,v75;
create or replace view aggJoin7188498401923322141 as select v49, v50, v19, v61, v76, v78, v75 from semiDown804107243577311427 join aggView2490767948401179689 using(v49);
create or replace view aggView643157163764903540 as select v19, v61, v49, MIN(v76) as v76, MIN(v78) as v78, MIN(v75) as v75, MIN(v50) as v77 from aggJoin7188498401923322141 group by v19,v61,v49,v78,v76,v75;
create or replace view aggJoin8714734240581874616 as select v61, v49, v76, v78, v75, v77 from semiDown4574886433772555824 join aggView643157163764903540 using(v19);
create or replace view aggView2035335852682212136 as select v49, v61, MIN(v76) as v76, MIN(v78) as v78, MIN(v75) as v75, MIN(v77) as v77 from aggJoin8714734240581874616 group by v49,v61,v78,v76,v75,v77;
create or replace view aggJoin1989149256211409243 as select v49, v1, v61, v76, v78, v75, v77 from semiDown4554699762567596777 join aggView2035335852682212136 using(v49);
create or replace view aggView1002608460540438504 as select v1, v61, MIN(v76) as v76, MIN(v78) as v78, MIN(v75) as v75, MIN(v77) as v77 from aggJoin1989149256211409243 group by v1,v61,v78,v76,v75,v77;
create or replace view aggJoin7853733659200352894 as select v2, v61, v76, v78, v75, v77 from semiDown6289300152359812918 join aggView1002608460540438504 using(v1);
create or replace view aggView3024873126285001145 as select v61, MIN(v76) as v76, MIN(v78) as v78, MIN(v75) as v75, MIN(v77) as v77, MIN(v2) as v73 from aggJoin7853733659200352894 group by v61,v78,v76,v75,v77;
create or replace view aggJoin4940928996648035538 as select v61, v8, v76, v78, v75, v77, v73 from semiDown4863134209546772758 join aggView3024873126285001145 using(v61);
create or replace view aggView8222419585761624263 as select v8, MIN(v76) as v76, MIN(v78) as v78, MIN(v75) as v75, MIN(v77) as v77, MIN(v73) as v73 from aggJoin4940928996648035538 group by v8,v73,v77,v78,v76,v75;
create or replace view aggJoin8249733943205621360 as select v9, v76, v78, v75, v77, v73 from semiUp2257813511332640811 join aggView8222419585761624263 using(v8);
select MIN(v73) as v73, MIN(v9) as v74, MIN(v75) as v75, MIN(v76) as v76, MIN(v77) as v77, MIN(v78) as v78 from aggJoin8249733943205621360;

