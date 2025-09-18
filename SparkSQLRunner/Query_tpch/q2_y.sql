create or replace TEMP view hq2_innerK as
SELECT ps_partkey as v1_partkey, MIN(ps_supplycost) as v1_supplycost_min
FROM spartsuppT, supplier, nation, region
WHERE s_suppkey = ps_suppkey
  AND s_nationkey = n_nationkey
  AND n_regionkey = r_regionkey
  AND r_name = 'EUROPE'
GROUP BY ps_partkey;
create or replace TEMP view partAux87 as select p_partkey as v1, p_mfgr as v3 from part where p_size= 15 and p_type LIKE '%BRASS';
create or replace TEMP view semiUp8388309865963014162 as select n_nationkey as v13, n_name as v23, n_regionkey as v24 from nation AS nation where (n_regionkey) in (select r_regionkey from region AS region where r_name= 'EUROPE');
create or replace TEMP view partsuppAux72 as select ps_partkey as v1, ps_suppkey as v10, ps_supplycost as v20 from spartsuppT;
create or replace TEMP view nationAux58 as select v13, v23 from semiUp8388309865963014162;
create or replace TEMP view semiUp8644864795297693116 as select v1, v10, v20 from partsuppAux72 where (v1, v20) in (select v1_partkey, v1_supplycost_min from hq2_innerK AS hq2_innerK);
create or replace TEMP view semiUp2034655538763913075 as select s_suppkey as v10, s_name as v11, s_address as v12, s_nationkey as v13, s_phone as v14, s_acctbal as v15, s_comment as v16 from supplier AS supplier where (s_nationkey) in (select v13 from nationAux58);
create or replace TEMP view semiUp1007479781353551284 as select v1, v10, v20 from semiUp8644864795297693116 where (v1) in (select v1 from partAux87);
create or replace TEMP view semiUp808668342265645404 as select v1, v10, v20 from semiUp1007479781353551284 where (v10) in (select v10 from semiUp2034655538763913075);
create or replace TEMP view semiDown6143247668680418108 as select v1, v3 from partAux87 where (v1) in (select v1 from semiUp808668342265645404);
create or replace TEMP view semiDown9122877498056922140 as select v10, v11, v12, v13, v14, v15, v16 from semiUp2034655538763913075 where (v10) in (select v10 from semiUp808668342265645404);
create or replace TEMP view semiDown3412758824195970077 as select v1_partkey as v1, v1_supplycost_min as v20 from hq2_innerK AS hq2_innerK where (v1_partkey, v1_supplycost_min) in (select v1, v20 from semiUp808668342265645404);
create or replace TEMP view semiDown1715331003736644191 as select ps_partkey as v1, ps_suppkey as v10, ps_supplycost as v20 from spartsuppT AS spartsuppT where (ps_partkey, ps_supplycost, ps_suppkey) in (select v1, v20, v10 from semiUp808668342265645404);
create or replace TEMP view semiDown2507864953813183794 as select p_partkey as v1, p_mfgr as v3 from part AS part where (p_partkey, p_mfgr) in (select v1, v3 from semiDown6143247668680418108) and p_size= 15 and p_type LIKE '%BRASS';
create or replace TEMP view semiDown4279406890942360092 as select v13, v23 from nationAux58 where (v13) in (select v13 from semiDown9122877498056922140);
create or replace TEMP view semiDown668200283003462048 as select v13, v23, v24 from semiUp8388309865963014162 where (v13, v23) in (select v13, v23 from semiDown4279406890942360092);
create or replace TEMP view semiDown8820627938896200458 as select r_regionkey as v24 from region AS region where (r_regionkey) in (select v24 from semiDown668200283003462048) and r_name= 'EUROPE';
create or replace TEMP view joinView2080543063037042324 as select v1, v3 from semiDown6143247668680418108 join semiDown2507864953813183794 using(v1, v3);
create or replace TEMP view joinView3897431496269403133 as select v1, v10, v20 from semiUp808668342265645404 join semiDown1715331003736644191 using(v1, v20, v10);
create or replace TEMP view joinView2141783138643545716 as select v13, v23 from semiDown668200283003462048 join semiDown8820627938896200458 using(v24);
create or replace TEMP view joinView4217902036196424583 as select v13, v23 from semiDown4279406890942360092 join joinView2141783138643545716 using(v23, v13);
create or replace TEMP view joinView7201421990426258041 as select v10, v11, v12, v14, v15, v16, v23 from semiDown9122877498056922140 join joinView4217902036196424583 using(v13);
create or replace TEMP view joinView3564961484435949730 as select v1, v20, v11, v12, v14, v15, v16, v23 from joinView3897431496269403133 join joinView7201421990426258041 using(v10);
create or replace TEMP view joinView2865640779622932643 as select v1, v11, v12, v14, v15, v16, v23 from joinView3564961484435949730 join semiDown3412758824195970077 using(v1, v20);
create or replace TEMP view joinView1241934936450472328 as select v1, v11, v12, v14, v15, v16, v23, v3 from joinView2865640779622932643 join joinView2080543063037042324 using(v1);
select distinct v15, v11, v23, v1, v3, v12, v14, v16 from joinView1241934936450472328;
