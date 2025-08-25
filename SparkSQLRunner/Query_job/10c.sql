SELECT MIN(chn.name) AS character1,
       MIN(t.title) AS movie_with_american_producer
FROM gchar_nameh AS chn,
     ecast_infof AS ci,
     lcompany_namem AS cn,
     ocompany_typen AS ct,
     xmovie_companiesc AS mc,
     irole_typeo AS rt,
     title AS t
WHERE ci.note LIKE '%(producer)%'
  AND cn.country_code = '[us]'
  AND t.production_year > 1990
  AND t.id = mc.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mc.movie_id
  AND chn.id = ci.person_role_id
  AND rt.id = ci.role_id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id