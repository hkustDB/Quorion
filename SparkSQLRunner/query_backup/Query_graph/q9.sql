SELECT g2.src, COUNT(*), SUM(g3.dst), AVG(g4.dst), AVG(g1.src)
FROM epinions AS g1, epinions AS g2, epinions AS g3, epinions AS g4
WHERE g1.dst = g2.src AND g2.dst = g3.src AND g3.dst = g4.src AND g1.src < g4.dst
GROUP BY g2.src