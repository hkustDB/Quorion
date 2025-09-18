SELECT MIN(cn.name) AS from_company,
       MIN(mc.note) AS production_note,
       MIN(t.title) AS movie_based_on_book
FROM lcompany_namem AS cn,
     ocompany_typen AS ct,
     keyword AS k,
     ylink_typeb AS lt,
     xmovie_companiesc AS mc,
     smovie_keywordp AS mk,
     lmovie_linkq AS ml,
     title AS t
WHERE cn.country_code <>'[pl]'
  AND ct.kind <> 'production companies'
  AND k.keyword IN ('sequel',
                    'revenge',
                    'based-on-novel')
  AND t.production_year > 1950
  AND lt.id = ml.link_type_id
  AND ml.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_type_id = ct.id
  AND mc.company_id = cn.id
  AND ml.movie_id = mk.movie_id
  AND ml.movie_id = mc.movie_id
  AND mk.movie_id = mc.movie_id