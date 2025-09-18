SELECT MIN(cn.name) AS lcompany_namem,
       MIN(lt.link) AS ylink_typeb,
       MIN(t.title) AS german_follow_up
FROM lcompany_namem AS cn,
     ocompany_typen AS ct,
     keyword AS k,
     ylink_typeb AS lt,
     xmovie_companiesc AS mc,
     emovie_infoa AS mi,
     smovie_keywordp AS mk,
     lmovie_linkq AS ml,
     title AS t
WHERE cn.country_code <>'[pl]'
  AND (cn.name LIKE '%Film%'
       OR cn.name LIKE '%Warner%')
  AND ct.kind ='production companies'
  AND k.keyword ='sequel'
  AND lt.link LIKE '%follow%'
  AND mi.info IN ('Germany',
                  'German')
  AND t.production_year BETWEEN 2000 AND 2010
  AND lt.id = ml.link_type_id
  AND ml.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_type_id = ct.id
  AND mc.company_id = cn.id
  AND mi.movie_id = t.id
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id
  AND ml.movie_id = mi.movie_id
  AND mk.movie_id = mi.movie_id
  AND mc.movie_id = mi.movie_id