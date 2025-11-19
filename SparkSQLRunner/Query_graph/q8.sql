SELECT g2.src, g2.dst, sum(g4.dst + g4.src)
FROM epinions AS g1, epinions AS g2, epinions AS g3, epinions AS g4
WHERE g1.dst = g2.src AND g2.dst = g3.src AND g3.dst = g4.src
Group by g2.src, g2.dst