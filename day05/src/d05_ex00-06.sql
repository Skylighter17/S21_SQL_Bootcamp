/* ex00_Please create a simple BTree index for each foreign key in our database.
The name pattern should match the next rule "idx_{table_name}_{column_name}".
For example, the name of the BTree index for the pizzeria_id
column in the menu table is idx_menu_pizzeria_id.*/


CREATE INDEX IF NOT EXISTS idx_menu_pizzeria_id
    ON menu (pizzeria_id);

CREATE INDEX IF NOT EXISTS idx_person_order_menu_id
    ON person_order (menu_id);

CREATE INDEX IF NOT EXISTS idx_person_order_person_id
    ON person_order (person_id);

CREATE INDEX IF NOT EXISTS idx_person_visits_pizzeria_id
    ON person_visits (pizzeria_id);

CREATE INDEX IF NOT EXISTS idx_person_visits_person_id
    ON person_visits (person_id);

-- SELECT *
-- FROM pg_indexes
-- ORDER BY indexname;

-- DROP INDEX IF EXISTS idx_menu_pizzeria_id;
-- DROP INDEX IF EXISTS idx_person_order_menu_id;
-- DROP INDEX IF EXISTS idx_person_order_person_id;
-- DROP INDEX IF EXISTS idx_person_visits_pizzeria_id;
-- DROP INDEX IF EXISTS idx_person_visits_person_id;


-- Day_03_07-13
/*
INSERT INTO menu(id, pizzeria_id, pizza_name, price)
SELECT COALESCE(MAX(m.id), 0) + 1,
       (SELECT pizz.id FROM pizzeria pizz WHERE pizz.name = 'Dominos'),
       'sicilian pizza',
       900
FROM menu m;

INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Irina'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24');
INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Denis'),
        (SELECT id FROM pizzeria WHERE name = 'Dominos'),
        '2022-02-24');

INSERT INTO person_order(id, person_id, menu_id, order_date)
VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_order),
       (SELECT id FROM person WHERE name = 'Irina'),
       (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'),
       '2022-02-24');
INSERT INTO person_order(id, person_id, menu_id, order_date)
VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_order),
       (SELECT id FROM person WHERE name = 'Denis'),
       (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'),
       '2022-02-24');
*/


/* ex01_Before proceeding, please write an SQL statement
that returns pizzas and the corresponding pizzeria names.
See the example result below (no sorting required).*/

SET enable_seqscan = off;

EXPLAIN ANALYZE
SELECT m.pizza_name, pizz.name AS "pizzeria_name"
FROM menu m
JOIN pizzeria pizz ON m.pizzeria_id = pizz.id;



/* ex02_Please create a functional B-Tree index  named idx_person_name
on the column name of the person table.
The index should contain person names in upper case*/

CREATE INDEX IF NOT EXISTS idx_person_name
    ON person (UPPER(name));

--DROP INDEX IF EXISTS idx_person_name;

SET enable_seqscan = off;

EXPLAIN ANALYZE
SELECT age
FROM person
WHERE UPPER(name) = 'DENIS';

EXPLAIN ANALYZE
SELECT age
FROM person
WHERE name = 'DENIS';



/* ex03_Please create a better multi-column B-Tree index
named idx_person_order_multi for the SQL statement below.*/

CREATE INDEX IF NOT EXISTS idx_person_order_multi
    ON person_order (person_id, menu_id, order_date);

-- DROP INDEX IF EXISTS idx_person_order_multi;

SET enable_seqscan = off;

EXPLAIN ANALYZE
SELECT person_id, menu_id, order_date
FROM person_order
WHERE person_id = 8
  AND menu_id = 19;


-- ex04_Please create a unique BTree index named idx_menu_unique
-- on the menu table for  pizzeria_id and pizza_name columns.
-- Write and provide any SQL with proof (EXPLAIN ANALYZE)
-- that index idx_menu_unique works.

CREATE UNIQUE INDEX IF NOT EXISTS idx_menu_unique
    ON menu (pizzeria_id, pizza_name);


-- DROP INDEX IF EXISTS idx_menu_unique;

SET enable_seqscan = off;

EXPLAIN ANALYZE
SELECT *
FROM menu
WHERE pizzeria_id = 5
  AND pizza_name = 'supreme pizza';

-- INSERT INTO menu(id, pizzeria_id, pizza_name, price)
-- VALUES ((SELECT MAX(id) + 1 FROM menu), 5, 'supreme pizza', 850);
--
-- DELETE FROM menu
-- WHERE id = 20;



/* ex05_Please create a partially unique BTree index
named idx_person_order_order_date on the person_order table
for the person_id and menu_id attributes with partial uniqueness
for the order_date column for the date '2022-01-01'.*/

CREATE UNIQUE INDEX IF NOT EXISTS idx_person_order_order_date
    ON person_order (person_id, menu_id)
    WHERE order_date = '2022-01-01';

-- DROP INDEX IF EXISTS idx_person_order_order_date;

SET enable_seqscan = off;

EXPLAIN ANALYZE
SELECT person_id, menu_id
FROM person_order
WHERE order_date = '2022-01-01';

EXPLAIN ANALYZE
SELECT person_id, menu_id
FROM person_order
WHERE order_date = '2022-01-02';

-- INSERT INTO person_order(id, person_id, menu_id, order_date)
-- VALUES((SELECT MAX(id) + 1 FROM person_order), 1, 1, '2022-01-01');
--
-- INSERT INTO person_order(id, person_id, menu_id, order_date)
-- VALUES((SELECT MAX(id) + 1 FROM person_order), 3, 16, '2022-01-04');
--
-- DELETE FROM person_order
-- WHERE id = 23;



/* ex06_Create a new BTree index named idx_1 that should improve the
"Execution Time" metric of this SQL. Provide evidence (EXPLAIN ANALYZE)
that the SQL has been improved.*/


DROP INDEX IF EXISTS idx_1;

EXPLAIN ANALYZE
SELECT
    m.pizza_name AS pizza_name,
    max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM  menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1,2;

CREATE INDEX IF NOT EXISTS idx_1
ON pizzeria(rating);

SET enable_seqscan = off;

EXPLAIN ANALYZE
SELECT
    m.pizza_name AS pizza_name,
    max(rating) OVER (PARTITION BY rating ORDER BY rating ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS k
FROM  menu m
INNER JOIN pizzeria pz ON m.pizzeria_id = pz.id
ORDER BY 1,2;
