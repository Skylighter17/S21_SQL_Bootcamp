/* ex00_Please write a SQL statement that returns a list of pizza names, pizza prices, pizzeria names,
and visit dates for Kate and for prices ranging from 800 to 1000 rubles.
Please sort by pizza, price, and pizzeria name. See a sample of the data below.*/
WITH kate_visits AS
         (SELECT *
          FROM person_visits pv
          JOIN person p ON p.id = pv.person_id
          WHERE p.name = 'Kate')


SELECT m.pizza_name,
       m.price,
       pizz.name AS "pizzeria_name",
       kv.visit_date
FROM kate_visits kv
JOIN pizzeria pizz ON kv.pizzeria_id = pizz.id
JOIN menu m ON m.pizzeria_id = pizz.id
WHERE m.price BETWEEN 800 AND 1000
ORDER BY 1, 2, 3;


/* ex01_Please write a SQL statement that returns a list of pizza names, pizza prices, pizzeria names,
and visit dates for Kate and for prices ranging from 800 to 1000 rubles.
Please sort by pizza, price, and pizzeria name. See a sample of the data below.*/
WITH kate_visits AS
         (SELECT *
          FROM person_visits pv
          JOIN person p ON p.id = pv.person_id
          WHERE p.name = 'Kate')


SELECT m.pizza_name,
       m.price,
       pizz.name AS "pizzeria_name",
       kv.visit_date
FROM kate_visits kv
JOIN pizzeria pizz ON kv.pizzeria_id = pizz.id
JOIN menu m ON m.pizzeria_id = pizz.id
WHERE m.price BETWEEN 800 AND 1000
ORDER BY 1, 2, 3;


/* ex02_Please use the SQL statement from Exercise #01
and display the names of pizzas from the pizzeria
that no one has ordered, including the corresponding prices.
The result should be sorted by pizza name and price.
The sample output data is shown below.*/

WITH goofy_ah_pizzas AS (SELECT id AS "menu_id"
FROM menu
EXCEPT
                         SELECT menu_id
FROM person_order
ORDER BY 1)

SELECT m.pizza_name, m.price, pizz.name AS "pizzeria_name"
FROM goofy_ah_pizzas gap
JOIN menu m ON
gap.menu_id = m.id
JOIN pizzeria pizz ON
m.pizzeria_id = pizz.id
ORDER BY 1, 2, 3;


/* ex03_Please find pizzerias that have been visited more often by women or by men.
Save duplicates for any SQL operators with sets
    (UNION ALL, EXCEPT ALL, INTERSECT ALL constructions).
    Please sort a result by the name of the pizzeria.
    The sample data is shown below.*/

WITH woman AS
         (SELECT pizz.id, pizz.name
          FROM person_visits pv
          JOIN person p ON p.id = pv.person_id
          JOIN pizzeria pizz ON pv.pizzeria_id = pizz.id
          WHERE p.gender = 'female'),
     man AS
         (SELECT pizz.id, pizz.name
          FROM person_visits pv
          JOIN person p ON p.id = pv.person_id
          JOIN pizzeria pizz ON pv.pizzeria_id = pizz.id
          WHERE p.gender = 'male')

SELECT w_count.name AS "pizzeria_name"
FROM (SELECT name, COUNT(name)
      FROM woman
      GROUP BY name) AS w_count
JOIN (SELECT name, COUNT(name)
      FROM man
      GROUP BY name) AS m_count ON w_count.name = m_count.name
WHERE w_count.count != m_count.count;

-- (R - S) U (S - R), without group by
-- SELECT name AS "pizzeria_name"
-- FROM ((SELECT *
-- FROM woman
-- EXCEPT ALL
-- SELECT *
-- FROM man)
-- UNION ALL
-- (SELECT *
-- FROM man
-- EXCEPT ALL
-- SELECT *
-- FROM woman)) AS R_minus_S_U_S_minus_R
-- ORDER BY 1;


/* ex04_Find a union of pizzerias that have orders from either women or men.
In other words, you should find a set of names of pizzerias that have been ordered
    only by women and make "UNION" operation with set of names of pizzerias
    that have been ordered only by men. Please be careful with word "only"
    for both genders. For all SQL operators with sets don't store duplicates
    (UNION, EXCEPT, INTERSECT).
    Please sort a result by the name of the pizzeria.
    The sample data is shown below.*/

WITH only_womans AS
         (SELECT pizz.name
          FROM person_order po
          JOIN person p ON p.id = po.person_id
          JOIN menu m ON po.menu_id = m.id
          JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
          WHERE p.gender = 'female'),
     only_fans AS
         (SELECT pizz.name
          FROM person_order po
          JOIN person p ON p.id = po.person_id
          JOIN menu m ON po.menu_id = m.id
          JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
          WHERE p.gender = 'male')

(SELECT *
FROM only_womans
EXCEPT
SELECT *
FROM only_fans)
UNION
(SELECT *
 FROM only_fans
 EXCEPT
 SELECT *
 FROM only_womans)


 /* ex05_Write an SQL statement that returns a list of pizzerias that
 Andrey visited but did not order from. Please order by the name of the pizzeria.
 The sample data is shown below.*/

WITH andrey_vists AS
         (SELECT pv.pizzeria_id AS "pizz_id",
                 p.name         AS "person_name",
                 pizz.name      AS "pizzeria_name"
          FROM person_visits pv
          JOIN person p ON pv.person_id = p.id
          JOIN pizzeria pizz ON pv.pizzeria_id = pizz.id
          WHERE p.name = 'Andrey'),
     andrey_orders AS
         (SELECT pizz.id,
                 p.name,
                 pizz.name
          FROM person_order po
          JOIN person p ON po.person_id = p.id
          JOIN menu m ON po.menu_id = m.id
          JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
          WHERE p.name = 'Andrey')


SELECT pizzeria_name
FROM (SELECT *
      FROM andrey_vists
      EXCEPT
      SELECT *
      FROM andrey_orders) AS pv_except_po;

-- Without sets
-- SELECT *
-- FROM person_visits pv
-- JOIN person p ON pv.person_id = p.id AND p.name = 'Andrey'
-- LEFT JOIN (
--     SELECT p.name, m.*
--     FROM person_order po
--     JOIN person p ON po.person_id = p.id AND p.name = 'Andrey'
--     JOIN menu m ON m.id = po.menu_id
-- ) as andrey_orders ON pv.pizzeria_id = andrey_orders.pizzeria_id
-- JOIN pizzeria pizz ON pv.pizzeria_id = pizz.id
-- WHERE andrey_orders.pizzeria_id IS NULL;



/* ex06_Find the same pizza names that have the same price,
but from different pizzerias. Make sure that the result is ordered by pizza name.
The data sample is shown below.
Please make sure that your column names match the column names below.*/

SELECT m1.pizza_name,
       pizz1.name AS "pizzeria_name_1",
       pizz2.name AS "pizzeria_name_2",
       m1.price
FROM menu m1
JOIN menu m2 ON m1.price = m2.price
    AND m1.pizza_name = m2.pizza_name
    AND m1.id != m2.id
    AND m1.pizzeria_id > m2.pizzeria_id
JOIN pizzeria pizz1 ON m1.pizzeria_id = pizz1.id
JOIN pizzeria pizz2 ON m2.pizzeria_id = pizz2.id
ORDER BY m1.pizza_name;


/* ex07_Please register a new pizza with the name "greek pizza" (use id = 19)
with the price of 800 rubles in the restaurant "Dominos" (pizzeria_id = 2). */


INSERT INTO menu(id, pizzeria_id, pizza_name, price)
VALUES (19, 2, 'greek pizza', 800);


/* Check */
-- SELECT COUNT(*) = 1 as "check"
-- FROM menu
-- WHERE id = 19
--   AND pizzeria_id = 2
--   AND pizza_name = 'greek pizza'
--   AND price = 800;

/*Delete*/
-- DELETE FROM menu
-- WHERE id = 19;


/*ex 08_Please register a new pizza with the name "sicilian pizza"
(whose id should be calculated by the formula "maximum id value + 1")
with the price of 900 rubles in the restaurant "Dominos"
(please use internal query to get the identifier of the pizzeria).*/

-- INSERT INTO menu(id, pizzeria_id, pizza_name, price)
-- SELECT COALESCE(MAX(m.id), 0) + 1,
--        (SELECT pizz.id FROM pizzeria pizz WHERE pizz.name = 'Dominos'),
--        'sicilian pizza',
--        900
-- FROM menu m;

/*Check*/
SELECT COUNT(*) = 1 as "check"
FROM menu
WHERE id = 20
  AND pizzeria_id = 2
  AND pizza_name = 'sicilian pizza'
  AND price = 900;

/*Delete*/
-- DELETE FROM menu
-- WHERE id = 20;



/* ex 09_Please record new visits to Domino's
restaurant by Denis and Irina on February 24, 2022.*/

-- INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
-- VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_visits),
--         (SELECT id FROM person WHERE name = 'Irina'),
--         (SELECT id FROM pizzeria WHERE name = 'Dominos'),
--         '2022-02-24');
-- INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
-- VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_visits),
--         (SELECT id FROM person WHERE name = 'Denis'),
--         (SELECT id FROM pizzeria WHERE name = 'Dominos'),
--         '2022-02-24');

/*Check*/
SELECT COUNT(*) = 1
FROM person_visits
WHERE id = 20
  AND person_id = 6
  AND pizzeria_id = 2
  AND visit_date = '2022-02-24';
SELECT COUNT(*) = 1
FROM person_visits
WHERE id = 21
  AND person_id = 4
  AND pizzeria_id = 2
  AND visit_date = '2022-02-24';

/*Delete*/
-- DELETE
-- FROM person_visits
-- WHERE id IN (20, 21);



/* ex10_Please register new orders from Denis and Irina on February 24, 2022
for the new menu with "sicilian pizza"*/

-- INSERT INTO person_order(id, person_id, menu_id, order_date)
-- VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_order),
--        (SELECT id FROM person WHERE name = 'Irina'),
--        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'),
--        '2022-02-24');
-- INSERT INTO person_order(id, person_id, menu_id, order_date)
-- VALUES ((SELECT COALESCE(MAX(id), 0) + 1 FROM person_order),
--        (SELECT id FROM person WHERE name = 'Denis'),
--        (SELECT id FROM menu WHERE pizza_name = 'sicilian pizza'),
--        '2022-02-24');


/*Check*/
SELECT COUNT(*) = 1
FROM person_order
WHERE id = 21
  AND person_id = 6
  AND menu_id = 20
  AND order_date = '2022-02-24';
SELECT COUNT(*) = 1
FROM person_order
WHERE id = 22
  AND person_id = 4
  AND menu_id = 20
  AND order_date = '2022-02-24';

/*Delete*/
-- DELETE
-- FROM person_order
-- WHERE id IN (21, 22);


/* ex11_Please change the price of "greek pizza" to -10% of the current value. */

-- UPDATE menu
-- SET price = price * 0.9
-- WHERE pizza_name = 'greek pizza';


/*Check*/
SELECT COUNT(*) = 1
FROM menu
WHERE pizza_name = 'greek pizza' AND price = 800 * 0.9;

/*Snap back to reality*/
-- UPDATE menu
-- SET price = price / 0.9
-- WHERE pizza_name = 'greek pizza';




/* ex12_Please register new orders of all persons for "greek pizza" on February 25, 2022.*/

-- INSERT INTO person_order(id, person_id, menu_id, order_date)
-- SELECT GENERATE_SERIES((SELECT MAX(id) FROM person_order) + 1,
--                        (SELECT MAX(id) FROM person) + (SELECT MAX(id) FROM person_order)),
--        GENERATE_SERIES((SELECT MIN(id) FROM person),
--                        (SELECT MAX(id) FROM person)),
--        (SELECT id FROM menu WHERE pizza_name = 'greek pizza'),
--        '2022-02-25';

/*Check*/
SELECT COUNT(*) = 9
FROM person_order
WHERE person_id = ANY(SELECT id FROM person)
      AND menu_id = 19
      AND order_date = '2022-02-25';


/*Delete*/
-- DELETE FROM person_order
-- WHERE menu_id = 19;



/* ex13_Write 2 SQL (DML) statements that delete all new orders
from Exercise #12 based on the order date.
Then delete "greek pizza" from the menu*/


DELETE
FROM person_order
WHERE order_date = '2022-02-25';

DELETE
FROM menu
WHERE pizza_name = 'greek pizza';

/*Check*/
-- SELECT COUNT(*) = 0
-- FROM person_order
-- WHERE person_id = ANY(SELECT id FROM person)
--       AND menu_id = 19
--       AND order_date = '2022-02-25';
--
-- SELECT COUNT(*) = 0
-- FROM menu
-- WHERE pizza_name = 'greek pizza';


