SELECT MIN(lt.link) AS ylink_typeb,
       MIN(t1.title) AS first_movie,
       MIN(t2.title) AS second_movie
FROM keyword AS k,
     ylink_typeb AS lt,
     smovie_keywordp AS mk,
     lmovie_linkq AS ml,
     title AS t1,
     title AS t2
WHERE k.keyword ='character-name-in-title'
  AND mk.keyword_id = k.id
  AND t1.id = mk.movie_id
  AND ml.movie_id = t1.id
  AND ml.linked_movie_id = t2.id
  AND lt.id = ml.link_type_id
  AND mk.movie_id = t1.id