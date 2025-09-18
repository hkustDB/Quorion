SELECT MIN(cn.name) AS producing_company,
       MIN(mi_idx.info) AS rating,
       MIN(t.title) AS movie_about_winning
FROM lcompany_namem AS cn,
     ocompany_typen AS ct,
     rinfo_types AS it,
     rinfo_types AS it2,
     zkind_typea AS kt,
     xmovie_companiesc AS mc,
     emovie_infoa AS mi,
     tmovie_info_idxd AS mi_idx,
     title AS t
WHERE cn.country_code ='[us]'
  AND ct.kind ='production companies'
  AND it.info ='rating'
  AND it2.info ='release dates'
  AND kt.kind ='movie'
  AND t.title <> ''
  AND (t.title LIKE 'Champion%'
       OR t.title LIKE 'Loser%')
  AND mi.movie_id = t.id
  AND it2.id = mi.info_type_id
  AND kt.id = t.kind_id
  AND mc.movie_id = t.id
  AND cn.id = mc.company_id
  AND ct.id = mc.company_type_id
  AND mi_idx.movie_id = t.id
  AND it.id = mi_idx.info_type_id
  AND mi.movie_id = mi_idx.movie_id
  AND mi.movie_id = mc.movie_id
  AND mi_idx.movie_id = mc.movie_id