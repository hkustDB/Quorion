create or replace view customerAux12 as select c_custkey as v1, c_name as v2, c_address as v3, c_nationkey as v4, c_phone as v5, c_acctbal as v6, c_comment as v8 from customer;
create or replace view nationAux87 as select n_nationkey as v4, n_name as v35 from nation;
create or replace view semiUp8761272827831337584 as select o_orderkey as v18, o_custkey as v1 from orders AS orders where (o_orderkey) in (select l_orderkey from lineitem AS lineitem where l_returnflag= 'R') and o_orderdate>=DATE '1993-10-01' and o_orderdate<DATE '1994-01-01';
create or replace view semiUp924681112883200420 as select v1, v2, v3, v4, v5, v6, v8 from customerAux12 where (v1) in (select v1 from semiUp8761272827831337584);
create or replace view semiUp7045263624967991126 as select v4, v35 from nationAux87 where (v4) in (select v4 from semiUp924681112883200420);
create or replace view semiDown6864649125514027099 as select n_nationkey as v4, n_name as v35 from nation AS nation where (n_name, n_nationkey) in (select v35, v4 from semiUp7045263624967991126);
create or replace view semiDown4703304417578579830 as select v1, v2, v3, v4, v5, v6, v8 from semiUp924681112883200420 where (v4) in (select v4 from semiUp7045263624967991126);
create or replace view semiDown5227964397923073374 as select v18, v1 from semiUp8761272827831337584 where (v1) in (select v1 from semiDown4703304417578579830);
create or replace view semiDown1158206418979093936 as select c_custkey as v1, c_name as v2, c_address as v3, c_nationkey as v4, c_phone as v5, c_acctbal as v6, c_comment as v8 from customer AS customer where (c_comment, c_custkey, c_address, c_acctbal, c_nationkey, c_name, c_phone) in (select v8, v1, v3, v6, v4, v2, v5 from semiDown4703304417578579830);
create or replace view semiDown6703332609305523426 as select l_orderkey as v18, l_extendedprice as v23, l_discount as v24 from lineitem AS lineitem where (l_orderkey) in (select v18 from semiDown5227964397923073374) and l_returnflag= 'R';
create or replace view aggView1418813979578268972 as select v8, v1, v3, v6, v4, v2, v5 from semiDown1158206418979093936;
create or replace view aggView4906440339698168817 as select v35, v4 from semiDown6864649125514027099;
create or replace view aggView3223264006874032788 as select v18, SUM(v23 * (1 - v24)) as v39, COUNT(*) as annot from semiDown6703332609305523426 group by v18;
create or replace view aggJoin1785001774528188851 as select v1, v39, annot from semiDown5227964397923073374 join aggView3223264006874032788 using(v18);
create or replace view aggView8710534243873282988 as select v1, SUM(v39) as v39, SUM(annot) as annot from aggJoin1785001774528188851 group by v1,v39;
create or replace view aggJoin6604271452815870976 as select v8, v1, v3, v6, v4, v2, v5, v39, annot from aggView1418813979578268972 join aggView8710534243873282988 using(v1);
create or replace view aggView6149657613479539186 as select v4, SUM(v39) as v39, v8, v1, v3, v6, v2, v5, SUM(annot) as annot from aggJoin6604271452815870976 group by v4,v39,v8,v1,v3,v6,v2,v5;
create or replace view aggJoin84082132690830986 as select v35, v39, v8, v1, v3, v6, v2, v5 from aggView4906440339698168817 join aggView6149657613479539186 using(v4);
select v1, v2, SUM(v39) as v39, v6, v35, v3, v5, v8 from aggJoin84082132690830986 group by v1, v2, v6, v5, v35, v3, v8;

