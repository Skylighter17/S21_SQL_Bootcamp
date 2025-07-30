--ex00
CREATE TABLE IF NOT EXISTS paths(
    point1 VARCHAR,
    point2 VARCHAR,
    cost INTEGER
);


INSERT INTO paths (point1, point2, cost)
VALUES
    ('a', 'b', 10),
    ('b', 'a', 10),
    ('a', 'd', 20),
    ('d', 'a', 20),
    ('a', 'c', 15),
    ('c', 'a', 15),
    ('b', 'd', 25),
    ('d', 'b', 25),
    ('b', 'c', 35),
    ('c', 'b', 35),
    ('d', 'c', 30),
    ('c', 'd', 30);


WITH RECURSIVE merchant_travels AS (
    SELECT 0 AS total_cost,
        'a'::VARCHAR AS tour,
        'a'::VARCHAR as path_point1,
        'a'::VARCHAR AS last_point,
        0 AS cur_cost,
        0 AS lvl
    UNION ALL
    -- В каждой итерации мы "превращаем" last_point в path_point1 и просматриваем все возможные
    -- варианты без возвращения в точки, в которых мы уже были (через условие WHERE)
    -- То есть, в первом шаге рекурсивного запроса мы "превращаем" А (первый last_point)
    -- в path_point1 и смотрим все возможные пути
    -- Во втором шаге мы поочерёдно "превращаем" B, C и D из первого шага в path_point1
    -- и смотрим все возможные пути и тд
    SELECT merchant_travels.total_cost + paths.cost AS total_cost,
        merchant_travels.tour || ',' || paths.point2 AS tour,
        paths.point1 AS path_point1,
        paths.point2 AS last_point,
        paths.cost AS cur_cost,
        lvl + 1 AS lvl
    FROM paths
    JOIN merchant_travels ON paths.point1 = merchant_travels.last_point
    WHERE POSITION (paths.point2 IN merchant_travels.tour) = 0
),


min_and_max AS (
    SELECT total_cost + cost AS total_cost,
        CONCAT ('{', tour, ',a}') as tour
    FROM merchant_travels
    JOIN paths ON merchant_travels.last_point = paths.point2
    WHERE point1 = 'a'
        AND lvl = (
            SELECT MAX(lvl)
            FROM merchant_travels
        )
    ORDER BY total_cost,
        tour
)


SELECT *
FROM min_and_max
WHERE total_cost = (
        SELECT MIN(total_cost)
        FROM min_and_max
    );


--ex01
WITH RECURSIVE merchant_travels AS (
    SELECT 0 AS total_cost,
        'a'::VARCHAR AS tour,
        'a'::VARCHAR as path_point1,
        'a'::VARCHAR AS last_point,
        0 AS cur_cost,
        0 AS lvl
    UNION ALL
    -- В каждой итерации мы "превращаем" last_point в path_point1 и просматриваем все возможные
    -- варианты без возвращения в точки, в которых мы уже были (через условие WHERE)
    -- То есть, в первом шаге рекурсивного запроса мы "превращаем" А (первый last_point)
    -- в path_point1 и смотрим все возможные пути
    -- Во втором шаге мы поочерёдно "превращаем" B, C и D из первого шага в path_point1
    -- и смотрим все возможные пути и тд
    SELECT merchant_travels.total_cost + paths.cost AS total_cost,
        merchant_travels.tour || ',' || paths.point2 AS tour,
        paths.point1 AS path_point1,
        paths.point2 AS last_point,
        paths.cost AS cur_cost,
        lvl + 1 AS lvl
    FROM paths
        JOIN merchant_travels ON paths.point1 = merchant_travels.last_point
    WHERE POSITION (paths.point2 IN merchant_travels.tour) = 0
),


min_and_max AS (
    SELECT total_cost + cost AS total_cost,
        CONCAT ('{', tour, ',a}') as tour
    FROM merchant_travels
        JOIN paths ON merchant_travels.last_point = paths.point2
    WHERE point1 = 'a'
        AND lvl = (
            SELECT MAX(lvl)
            FROM merchant_travels
        )
    ORDER BY total_cost,
        tour
)


SELECT *
FROM min_and_max;    