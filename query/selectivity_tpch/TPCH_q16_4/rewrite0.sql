create or replace view aggView5455802152684778280 as select p_partkey as v6, p_size as v11, p_brand as v9, p_type as v10 from part as part where p_size between 25 and 50;
create or replace view aggJoin2326403689263027316 as select v11, v9, v10 from partsupp as partsupp, aggView5455802152684778280 where partsupp.ps_partkey=aggView5455802152684778280.v6;
select v9, v10, v11, COUNT(*) as v15 from aggJoin2326403689263027316 group by v9, v10, v11;
