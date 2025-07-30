
/* ex00_Please create 2 Database Views (with similar attributes as the original table)
based on a simple filtering by gender of persons.
Set the corresponding names for the database views: v_persons_female and v_persons_male*/

CREATE VIEW v_persons_female(id, name, age, gender, address) AS
    SELECT *
    FROM person
    WHERE gender = 'female';

CREATE VIEW v_persons_male(id, name, age, gender, address) AS
    SELECT *
    FROM person
    WHERE gender = 'male';



/*Check*/
-- SELECT *
-- FROM v_persons_female
-- ORDER BY id;
--
-- SELECT *
-- FROM v_persons_male
-- ORDER BY id;

/*Delete*/
-- DROP VIEW v_persons_female;
-- DROP VIEW v_persons_male;

/*Day_03_07-13*/
-- INSERT INTO menu(id, pizzeria_id, pizza_name, price)
-- SELECT COALESCE(MAX(m.id), 0) + 1,
--        (SELECT pizz.id FROM pizzeria pizz WHERE pizz.name = 'Dominos'),
--        'sicilian pizza',
--        900
-- FROM menu m;
--
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
--
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



/* ex01_Please use 2 Database Views from Exercise #00 and write SQL to get female and male person names in one list.
Please specify the order by person name. The sample data is shown below.*/

SELECT name
FROM v_persons_male
UNION
SELECT name
FROM v_persons_female
ORDER BY 1;



/* ex02_Please create a Database View (with name v_generated_dates)
which should "store" generated
dates from January 1st to January 31st, 2022 in type DATE.
Don't forget the order of the generated_date column*/

CREATE VIEW v_generated_dates AS
    SELECT generate_series::date
    FROM GENERATE_SERIES('2022-01-01', '2022-01-31', '1 day'::interval)
    ORDER BY 1;


/*Check*/
-- SELECT *
-- FROM v_generated_dates;

/*Delete*/
-- DROP VIEW v_generated_dates;



/* ex03_Write a SQL statement that returns missing days for people's visits in
January 2022. Use the v_generated_dates view for this task
and sort the result by the missing_date column. The sample data is shown below.*/

SELECT vg.generate_series
FROM person_visits pv
RIGHT JOIN v_generated_dates vg ON pv.visit_date = vg.generate_series
WHERE pv.visit_date IS NULL
ORDER BY 1;

/*Sets*/
-- SELECT *
-- FROM v_generated_dates
-- EXCEPT
-- SELECT visit_date
-- FROM person_visits
-- ORDER BY 1;


/* ex04_Write an SQL statement that satisfies the formula (R - S)∪(S - R) .
Where R is the person_visits table with a filter through January 2, 2022,
S is also the person_visits table but with a different filter through January 6, 2022.
Please do your calculations with sets under the person_id column and this
column will be alone in a result. Please sort the result by the person_id
column and present your final SQL in the v_symmetric_union (*) database view.*/


CREATE VIEW v_symmetric_union AS
(
WITH R AS (SELECT person_id
           FROM person_visits
           WHERE visit_date = '2022-01-02'),
     S AS (SELECT person_id
           FROM person_visits
           WHERE visit_date = '2022-01-06')

(SELECT *
 FROM R
 EXCEPT
 SELECT *
 FROM S)
UNION
(SELECT *
 FROM S
 EXCEPT
 SELECT *
 FROM R)
ORDER BY 1
);


/*Check*/
-- SELECT *
-- FROM v_symmetric_union;

/*Delete*/
-- DROP VIEW v_symmetric_union;




/* ex05_Please create a Database View v_price_with_discount that returns the orders
of a person with person name, pizza name, real price and calculated column
discount_price (with applied 10% discount and satisfying formula price - price*0.1).
Please sort the result by person names and pizza names and convert the discount_price
column to integer type. See a sample result below.*/
CREATE VIEW v_price_with_discount AS
(
SELECT p.name, m.pizza_name, m.price, (m.price * 0.9)::INT AS "discount_price"
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
ORDER BY p.name, m.pizza_name
    );

/*Check*/
-- SELECT *
-- FROM v_price_with_discount;

/*Delete*/
-- DROP VIEW v_price_with_discount;



/* ex06_Please create a Materialized View mv_dmitriy_visits_and_eats
(with data included) based on the SQL statement that finds the
name of the pizzeria where Dmitriy visited on January 8, 2022
and could eat pizzas for less than 800 rubles
(this SQL can be found at Day #02 Exercise #07).*/
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

/*Check*/
-- SELECT *
-- FROM mv_dmitriy_visits_and_eats;

/*Delete*/
-- DROP MATERIALIZED VIEW mv_dmitriy_visits_and_eats;




/* ex07_Let's refresh the data in our Materialized View mv_dmitriy_visits_and_eats
from Exercise #06. Before this action, please create another Dmitriy visit
that satisfies the SQL clause of the Materialized View except pizzeria,
which we can see in a result from Exercise #06.
After adding a new visit, please update a data state for mv_dmitriy_visits_and_eats.*/


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

/*Check*/
-- SELECT *
-- FROM mv_dmitriy_visits_and_eats;
--
-- SELECT *
-- FROM person_visits
-- WHERE person_id = 9 AND visit_date = '2022-01-08';

/*Delete*/
-- DELETE FROM person_visits
-- WHERE person_id = 9 AND pizzeria_id IN (3, 5);



/* ex08_After all our exercises,
  we have a couple of Virtual Tables and a Materialized View. Let's drop them!*/


DROP VIEW v_persons_male,
    v_persons_female,
    v_generated_dates,
    v_symmetric_union,
    v_price_with_discount;

DROP MATERIALIZED VIEW mv_dmitriy_visits_and_eats;