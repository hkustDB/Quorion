CREATE TABLE R (
    a INT,
    b INT
) WITH (
    'cardinality' = '1'
);

CREATE TABLE S (
    b INT,
    c INT
) WITH (
    'cardinality' = '2'
);

CREATE TABLE T (
    c INT,
    d INT,
    e INT,
    f INT
) WITH (
    'cardinality' = '3'
);