create or replace TEMP view bq17_innerD as select l_partkey as v1_partkey, 0.2 * AVG(l_quantity) as v1_quantity_avg from lineitem l2 group by l_partkey;
create or replace TEMP view aggView3787360506141835060 as select v1_partkey as v17, v1_quantity_avg as v27 from bq17_innerD as bq17_innerD;
create or replace TEMP view aggJoin285672210051290392 as select p_partkey as v17, p_brand as v20, p_container as v23, v27 from part as part, aggView3787360506141835060 where part.p_partkey=aggView3787360506141835060.v17 and p_brand= 'Brand#23' and p_container= 'MED BOX';
create or replace TEMP view aggView7602657607298452756 as select v17, COUNT(*) as annot, v27 from aggJoin285672210051290392 group by v17,v27;
create or replace TEMP view aggJoin947919608480690834 as select l_quantity as v5, l_extendedprice as v6, v27, annot from lineitem as lineitem, aggView7602657607298452756 where lineitem.l_partkey=aggView7602657607298452756.v17 and l_quantity>v27;
create or replace TEMP view aggView8303664545546949653 as select v6, SUM(annot) as annot from aggJoin947919608480690834 group by v6;
select SUM((v6)* annot) / 7.0 as v29 from aggView8303664545546949653;
