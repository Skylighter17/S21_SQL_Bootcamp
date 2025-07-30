/*ex00_Please write a SQL statement that returns the menu identifier and pizza names from
  the menu table and the person identifier and person name from the person table
  in one global list (with column names as shown in the example below) ordered by object_id
  and then by object_name columns.*/


SELECT id AS "object_id", pizza_name AS "object_name"
FROM menu

UNION

SELECT id, name
FROM person
ORDER BY 1, 2;


/* ex01_Please modify an SQL statement from "Exercise 00" by removing the
object_id column. Then change the order by object_name for part
of the data from the person table and then from the menu table
(as shown in an example below). Please save duplicates!*/
SELECT object_name
FROM (SELECT pizza_name AS "object_name", 'pizza' AS "description"
      FROM menu

      UNION ALL

      SELECT name AS "object_name", 'human' AS "description"
      FROM person
      ORDER BY "description", object_name) AS t1;



/* ex02_Write an SQL statement that returns unique pizza names from the menu table
and sorts them by the pizza_name column in descending order.
Please note the Denied section.: DISTINCT, GROUP BY, HAVING, any type of JOINs*/
SELECT pizza_name
FROM menu
UNION
SELECT pizza_name
FROM menu
ORDER BY pizza_name DESC;


/* ex03_Write an SQL statement that returns common rows for attributes order_date, person_id
from the person_order table on one side and visit_date, person_id
from the person_visits table on the other side (see an example below).
In other words, let's find the identifiers of persons who visited
and ordered a pizza on the same day.
Actually, please add the order by action_date in ascending mode and
then by person_id in descending mode.*/
SELECT order_date AS "action_date", person_id
FROM person_order
INTERSECT
SELECT visit_date AS "action_date", person_id
FROM person_visits
ORDER BY action_date, person_id DESC;

/* ex04_Please write a SQL statement that returns a difference (minus) of person_id column values
while saving duplicates between person_order table and person_visits table
for order_date and visit_date are for January 7, 2022.*/
SELECT person_id
FROM person_order
WHERE order_date = '2022-01-07'
EXCEPT ALL
SELECT person_id
FROM person_visits
WHERE visit_date = '2022-01-07';


/* ex05_Please write a SQL statement that returns all possible combinations
between person and pizzeria tables, and please set the order of
    the person identifier columns and then the pizzeria identifier columns.
    Please take a look at the sample result below.
    Please note that the column names may be different for you.*/

SELECT *
FROM person, pizzeria
ORDER BY person.id, pizzeria.id;

-- SELECT *
-- FROM person
-- CROSS JOIN pizzeria
-- ORDER BY person.id, pizzeria.id;


/* ex06_Let's go back to Exercise #03 and modify our SQL statement
  to return person names instead of person identifiers and change
  the order by action_date in ascending mode and then by person_name
  in descending mode. Take a look at the sample data below.*/
SELECT act_id.action_date, p.name
FROM (
    SELECT order_date AS "action_date", person_id
    FROM person_order
    INTERSECT
    SELECT visit_date AS "action_date", person_id
    FROM person_visits
    ORDER BY action_date, person_id DESC
     ) as act_id
JOIN person p ON p.id = act_id.person_id
ORDER BY act_id.action_date , p.name DESC;


/* ex07_Write an SQL statement that returns the order date from
the person_order table and the corresponding person
name (name and age are formatted as in the data sample below)
who made an order from the person table.
Add a sort by both columns in ascending order.*/
--Test1
SELECT po.order_date,
       (p.name || ' (age:' || p.age || ')') AS "person_information"
FROM person_order po
JOIN person p on p.id = po.person_id
ORDER BY po.order_date, person_information;


/* ex08_Please rewrite a SQL statement from Exercise #07
by using NATURAL JOIN construction. The result must be the
same like for Exercise #07.*/
--Test2
SELECT order_date,
       (p.name || ' (age:' || p.age || ')') AS "person_information"
FROM (
    SELECT po.order_date, po.id as "order_id", person_id as "id"
    FROM person_order po
     ) as pers_ord
NATURAL JOIN person p
ORDER BY pers_ord.order_date, person_information;


/* ex09_Write 2 SQL statements that return a list of pizzerias that
have not been visited by people using IN for the first
and EXISTS for the second.*/

-- IN
SELECT name
FROM pizzeria
WHERE id NOT IN (SELECT pizzeria_id
                 FROM person_visits);
-- EXISTS
SELECT name
FROM pizzeria pizz
WHERE NOT EXISTS (SELECT pv.pizzeria_id
                  FROM person_visits pv
                  WHERE pv.pizzeria_id = pizz.id);


/* ex10_Please write an SQL statement that returns a list of the
names of the people who ordered pizza from the corresponding pizzeria.
The sample result (with named columns) is provided below and yes
... please make the ordering by 3 columns (person_name, pizza_name, pizzeria_name)
in ascending mode.*/

SELECT p.name AS "person_name", m.pizza_name, pizz.name AS "pizzeria_name"
FROM person_order po
JOIN person p ON p.id = po.person_id
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
ORDER BY 1,2,3;


