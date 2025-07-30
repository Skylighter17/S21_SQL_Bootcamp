/* ex00_Let's make a simple aggregation, please write a SQL statement
that returns person identifiers and corresponding number of visits in
any pizzerias and sorts by number of visits in descending mode and sorts by
person_id in ascending mode. Please take a look at the sample of data below.*/

SELECT person_id, COUNT(pizzeria_id) AS "count_of_visits"
FROM person_visits
GROUP BY person_id
ORDER BY count_of_visits DESC, person_id;

/*SELECT DISTINCT person_id,
        COUNT(person_id) OVER (PARTITION BY person_id) AS count_of_visits
FROM person_visits
ORDER BY 2 DESC, 1;*/

/*Day_03_07-13*/
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
CREATE MATERIALIZED VIEW mv_dmitriy_visits_and_eats AS
(
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
WHERE m.price < 800
    );
INSERT INTO person_visits(id, person_id, pizzeria_id, visit_date)
VALUES ((SELECT MAX(id) + 1 FROM person_visits),
        (SELECT id FROM person WHERE name = 'Dmitriy'),
        (SELECT pizz.id
         FROM pizzeria pizz
         JOIN menu m ON m.pizzeria_id = pizz.id
         WHERE m.price < 800
           AND pizz.name NOT IN (SELECT * FROM mv_dmitriy_visits_and_eats)
         LIMIT 1),
        '2022-01-08');
REFRESH MATERIALIZED VIEW mv_dmitriy_visits_and_eats;
*/



/* ex01_Please modify an SQL statement from Exercise 00 and return a person name
(not an identifier). Additional clause is we need to see only top 4 people with
maximum visits in each pizzerias and sorted by a person name.
See the example of output data below.*/

SELECT p.name, COUNT(pv.pizzeria_id) AS "count_of_visits"
FROM person_visits pv
JOIN person p ON pv.person_id = p.id
GROUP BY p.name
ORDER BY 2 DESC, 1
LIMIT 4;



/* ex02_Please write a SQL statement to see 3 favorite
restaurants by visits and by orders in a list (please add an action_type
column with values 'order' or 'visit', it depends on the data
from the corresponding table). Please have a look at the example data below.
The result should be sorted in ascending order by the action_type column
and in descending order by the count column*/

WITH top3_orders AS
         (SELECT pizz.name, COUNT(*) AS "count", 'order' AS "action_type"
          FROM person_order po
          JOIN menu m ON po.menu_id = m.id
          JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
          GROUP BY pizz.name
          ORDER BY 2 DESC, 1
          LIMIT 3),
     top3_visits AS
         (SELECT pizz.name, COUNT(*) AS "count", 'visit' AS "action_type"
          FROM person_visits pv
          JOIN pizzeria pizz ON pv.pizzeria_id = pizz.id
          GROUP BY pizz.name
          ORDER BY 2 DESC, 1
          LIMIT 3)

SELECT *
FROM top3_orders
UNION ALL
SELECT *
FROM top3_visits
ORDER BY action_type, count DESC;

/*
WITH windows AS (SELECT pizz.name, COUNT(*) AS "count", 'order' AS "type"
                 FROM person_order po
                 JOIN menu ON po.menu_id = menu.id
                 JOIN pizzeria pizz ON menu.pizzeria_id = pizz.id
                 GROUP BY pizz.name
                 UNION ALL
                 SELECT pizz.name, COUNT(*) AS "count", 'visit' AS "type"
                 FROM person_visits
                 JOIN pizzeria pizz ON person_visits.pizzeria_id = pizz.id
                 GROUP BY pizz.name)

SELECT name, count, type, rn
FROM (SELECT name, count, type,
             ROW_NUMBER() OVER (PARTITION BY type ORDER BY count DESC) AS rn
      FROM windows) AS ranked
WHERE rn < 4;
*/



/* ex03_Write an SQL statement to see how restaurants
are grouped by visits and by orders, and joined together by restaurant name.
You can use the internal SQL from Exercise 02
(Restaurants by Visits and by Orders) without any restrictions on the number of rows.

In addition, add the following rules.

Compute a sum of orders and visits for t
he corresponding pizzeria (note that not all
pizzeria keys are represented in both tables).
Sort the results by the total_count column
in descending order and by the name column in ascending order.
Take a look at the example data below.*/

WITH top3_orders AS
         (SELECT pizz.name, COUNT(*) AS "count", 'order' AS "type"
          FROM person_order po
          JOIN menu m ON po.menu_id = m.id
          JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
          GROUP BY pizz.name
          ORDER BY 2 DESC, 1),
     top3_visits AS
         (SELECT pizz.name, COUNT(*) AS "count", 'visit' AS "type"
          FROM person_visits pv
          JOIN pizzeria pizz ON pv.pizzeria_id = pizz.id
          GROUP BY pizz.name
          ORDER BY 2 DESC, 1)

SELECT name, SUM(count) AS "total_count"
FROM (SELECT *
      FROM top3_orders
      UNION ALL
      SELECT *
      FROM top3_visits
      ORDER BY type, count DESC) AS "topall"
GROUP BY name
ORDER BY total_count DESC, name;



/* ex04_Please write a SQL statement that returns the person's name
and the corresponding number of visits to any pizzerias
if the person has visited more than 3 times (> 3).
Please take a look at the sample data below.
DENIED: WHERE*/

SELECT p.name, COUNT(*) AS "count_of_visits"
FROM person_visits pv
JOIN person p ON pv.person_id = p.id
GROUP BY p.name
HAVING COUNT(*) > 3;



/* ex05_Please write a simple SQL query that returns a list of unique person names
who have placed orders at any pizzerias. The result should be sorted by
person name. Please see the example below.
DENIED: GROUP BY, any type (UNION,...) working with sets*/

SELECT DISTINCT name
FROM person_order po
JOIN person p ON po.person_id = p.id
ORDER BY 1;



/* ex06_Please write a SQL statement that returns the number of orders,
the average price, the maximum price and the minimum price for pizzas sold
by each pizzeria restaurant. The result should be sorted by pizzeria name.
See the sample data below. Round the average price to 2 floating numbers.*/

SELECT pizz.name,
       COUNT(*) AS "count_of_orders",
       ROUND(AVG(price), 2) AS "average_price",
       MAX(price) AS "max_price",
       MIN(price) AS "min_price"
FROM person_order po
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
GROUP BY pizz.name
ORDER BY pizz.name;


/* ex07_Write an SQL statement that returns a common average rating
(the output attribute name is global_rating) for all restaurants.
Round your average rating to 4 floating point numbers.*/

SELECT ROUND(AVG(rating), 4) AS "global_rating"
FROM pizzeria;



/* ex08_We know personal addresses from our data.
Let's assume that this person only visits pizzerias in his city. ' ||
Write a SQL statement that returns the address, the name of the pizzeria,
and the amount of the person's orders. The result should be
sorted by address and then by restaurant name. Please take a
look at the sample output data below.*/

SELECT p.address, pizz.name, COUNT(*) AS "count_of_orders"
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
GROUP BY p.address, pizz.name
ORDER BY p.address, pizz.name;



/* ex09_Please write a SQL statement that returns aggregated information
by person's address, the result of "Maximum Age - (Minimum Age / Maximum Age)"
presented as a formula column, next is average age per address and the
result of comparison between formula and average columns
(in other words, if formula is greater than average, then True, otherwise False value).*/

SELECT address,
       ROUND(MAX(age)::numeric - (MIN(age)::numeric / MAX(age)::numeric), 2) AS "formula",
       ROUND(AVG(age), 2) AS "average",
       CASE MAX(age)::numeric - (MIN(age)::numeric / MAX(age)::numeric) > AVG(age)
           WHEN TRUE THEN 'true'
           ELSE 'false'
       END AS "comparison"
FROM person
GROUP BY address
ORDER BY address;