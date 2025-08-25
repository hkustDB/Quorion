SELECT MIN(n.name) AS member_in_charnamed_movie
FROM ecast_infof AS ci,
     lcompany_namem AS cn,
     keyword AS k,
     xmovie_companiesc AS mc,
     smovie_keywordp AS mk,
     name AS n,
     title AS t
WHERE k.keyword ='character-name-in-title'
  AND n.name LIKE 'X%'
  AND n.id = ci.person_id
  AND ci.movie_id = t.id
  AND t.id = mk.movie_id
  AND mk.keyword_id = k.id
  AND t.id = mc.movie_id
  AND mc.company_id = cn.id
  AND ci.movie_id = mc.movie_id
  AND ci.movie_id = mk.movie_id
  AND mc.movie_id = mk.movie_id