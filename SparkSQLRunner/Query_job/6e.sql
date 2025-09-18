SELECT MIN(k.keyword) AS smovie_keywordp,
       MIN(n.name) AS actor_name,
       MIN(t.title) AS marvel_movie
FROM ecast_infof AS ci,
     keyword AS k,
     smovie_keywordp AS mk,
     name AS n,
     title AS t
WHERE k.keyword = 'marvel-cinematic-universe'
  AND n.name LIKE '%Downey%Robert%'
  AND t.production_year > 2000
  AND k.id = mk.keyword_id
  AND t.id = mk.movie_id
  AND t.id = ci.movie_id
  AND ci.movie_id = mk.movie_id
  AND n.id = ci.person_id