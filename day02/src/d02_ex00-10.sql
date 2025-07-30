/* ex00_Write a SQL statement that returns a list of pizzerias with the corresponding rating value
that have not been visited by people. DENIED: NOT IN, IN, NOT EXISTS, EXISTS, UNION, EXCEPT, INTERSECT*/

SELECT pizz.name, pizz.rating
FROM person_visits pv
RIGHT JOIN pizzeria pizz ON pv.pizzeria_id = pizz.id
WHERE pv.id IS NULL;



/* ex01_Please write a SQL statement that returns the missing days
from January 1 through January 10, 2022 (including all days) for visits
by people with identifiers 1 or 2 (i.e., days missed by both).
Please order by visit days in ascending mode. The sample data with column names is shown below.
DENIED: NOT IN, IN, NOT EXISTS, EXISTS, UNION, EXCEPT, INTERSECT*/

SELECT days_01_10::date AS "missing_date"
FROM GENERATE_SERIES('2022-01-01'::timestamp,
                     '2022-01-10'::timestamp,
                     '1 day'::interval) AS days_01_10
LEFT JOIN (SELECT *
           FROM person_visits pv
           WHERE person_id = 1
              OR person_id = 2) AS pv12 ON days_01_10 = pv12.visit_date
WHERE pv12.id IS NULL
ORDER BY 1;


/* ex02_Please write an SQL statement that will return the entire list of names of people
who visited (or did not visit) pizzerias during the period from January 1 to January 3, 2022
on one side and the entire list of names of pizzerias that were visited (or did not visit)
on the other side. The data sample with the required column names is shown below.
Please note the replacement value '-' for NULL values in the columns person_name
and pizzeria_name. Please also add the order for all 3 columns.*/


SELECT COALESCE(p.name, '-')    AS "person_name",
       pv01_03.visit_date,
       COALESCE(pizz.name, '-') AS "pizzeria_name"
FROM person p
FULL JOIN (SELECT *
           FROM person_visits
           WHERE visit_date BETWEEN '2022-01-01' AND '2022-01-03') AS pv01_03 ON pv01_03.person_id = p.id
FULL JOIN pizzeria pizz ON pv01_03.pizzeria_id = pizz.id
ORDER BY "person_name", pv01_03.visit_date, "pizzeria_name";



/* ex03_Let's go back to Exercise #01, please rewrite your SQL using the
CTE (Common Table Expression) pattern. Please go to the CTE part of your "day generator".
The result should look similar to Exercise #01.*/

WITH day_generator AS
         (SELECT generate_series::date AS generated_date
          FROM GENERATE_SERIES('2022-01-01'::timestamp,
                               '2022-01-10'::timestamp,
                               '1 day'::interval)),
     personvisits12 AS
         (SELECT *
          FROM person_visits pv
          WHERE person_id = 1
             OR person_id = 2)


SELECT dg.generated_date AS "missing_date"
FROM day_generator dg
LEFT JOIN personvisits12 pv12 ON dg.generated_date = pv12.visit_date
WHERE pv12.id IS NULL
ORDER BY 1;


/* ex04_Find complete information about all possible pizzeria names and prices
to get mushroom or pepperoni pizza. Then sort the result by pizza name
and pizzeria name. The result of the sample data is shown below
(please use the same column names in your SQL statement).*/

SELECT m.pizza_name,
       pizz.name AS "pizzeria_name",
       m.price
FROM menu m
JOIN pizzeria pizz ON pizz.id = m.pizzeria_id
WHERE m.pizza_name = 'mushroom pizza'
   OR m.pizza_name = 'pepperoni pizza'
ORDER BY 1, 2, 3;


/* ex05_Find the names of all females over the age of 25 and sort the
  result by name. The sample output is shown below.
 */

SELECT name
FROM person
WHERE gender = 'female'
  AND age > 25
ORDER BY name;


/* ex06_Find all pizza names (and corresponding pizzeria names using the menu table)
ordered by Denis or Anna. Sort a result by both columns.
The sample output is shown below.*/
WITH anna_den_orders AS (SELECT po.menu_id, p.name
                         FROM person_order po
                         JOIN person p ON po.person_id = p.id
                         WHERE p.name = 'Anna'
                            OR p.name = 'Denis')

SELECT m.pizza_name,
       pizz.name AS "pizzeria_name"
FROM anna_den_orders ado
JOIN menu m ON ado.menu_id = m.id
JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
ORDER BY pizza_name, pizzeria_name;



/* ex07_Please find the name of the pizzeria Dmitriy visited
on January 8, 2022 and could eat pizza for less than 800 rubles.*/
WITH dmitry_visits_08 AS
         (SELECT pv.pizzeria_id, visit_date, p.name
          FROM person_visits pv
          JOIN person p ON pv.person_id = p.id
          WHERE pv.visit_date = '2022-01-08'
            AND p.name = 'Dmitriy')

SELECT pizz.name AS "pizzeria_name"
FROM dmitry_visits_08 AS dv08
JOIN menu m ON m.pizzeria_id = dv08.pizzeria_id
JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
WHERE m.price < 800;



/* ex08_Please find the names of all men from Moscow or Samara who
order either pepperoni or mushroom pizza (or both).
Please sort the result by person names in descending order.
The sample output is shown below.*/
WITH samara_moscow_boys AS (SELECT *
                            FROM person
                            WHERE gender = 'male'
                              AND address IN ('Moscow', 'Samara'))

SELECT smp.name
FROM samara_moscow_boys smp
JOIN person_order po ON po.person_id = smp.id
JOIN menu m ON m.id = po.menu_id
WHERE m.pizza_name IN ('mushroom pizza', 'pepperoni pizza')
ORDER BY smp.name DESC;




/* ex09_Find the names of all women who ordered both pepperoni and cheese pizzas
(at any time and in any pizzerias). Make sure that the result is ordered by person's name.
The sample data is shown below.*/

SELECT p.name
FROM person_order po
JOIN person p ON p.id = po.person_id
JOIN menu m ON m.id = po.menu_id
WHERE p.gender = 'female'
  AND (m.pizza_name =  'cheese pizza' OR m.pizza_name = 'pepperoni pizza')
GROUP BY p.name
HAVING COUNT(DISTINCT m.pizza_name) = 2
ORDER BY p.name;


-- SELECT p.name
-- FROM person_order po
-- JOIN person p ON p.id = po.person_id
-- JOIN menu m ON m.id = po.menu_id
-- WHERE p.gender = 'female'
--   AND m.pizza_name =  'cheese pizza'
-- INTERSECT
-- SELECT p.name
-- FROM person_order po
-- JOIN person p ON p.id = po.person_id
-- JOIN menu m ON m.id = po.menu_id
-- WHERE p.gender = 'female'
--   AND m.pizza_name =  'pepperoni pizza';


/* ex10_Find the names of people who live at the same address.
Make sure the result is sorted by 1st person's name, 2nd person's name,
and shared address. The data sample is shown below.
Make sure your column names match the column names below.*/
SELECT p1.name AS "person_name1",
       p2.name AS "person_name2",
       p1.address AS "common_address"
FROM person p1
CROSS JOIN person p2
WHERE p1.address = p2.address AND p1.id != p2.id AND p1.id > p2.id
ORDER BY 1, 2, 3;
