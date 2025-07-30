/* ex00_Think about personal discounts for people from one side
and pizza restaurants from the other.
Need to create a new relational table (please set a name person_discounts) with the following rules.
Set id attribute like a Primary Key
(please have a look at id column in existing tables and choose the same data type).
Set attributes person_id and pizzeria_id
as foreign keys for corresponding tables
(data types should be the same as for id columns in corresponding parent tables).
Please set explicit names for foreign key constraints using
the pattern fk_{table_name}_{column_name}, for example fk_person_discounts_person_id.
Add a discount attribute to store a discount value in percent.
Remember that the discount value can be a floating-point number
(just use the numeric datatype). So please choose the appropriate datatype to cover this possibility.*/

CREATE TABLE IF NOT EXISTS person_discounts(
    id BIGINT PRIMARY KEY,
    person_id BIGINT,
    pizzeria_id BIGINT,
    discount_value DECIMAL,
    CONSTRAINT fk_person_discounts_person_id FOREIGN KEY (person_id) REFERENCES person(id),
    CONSTRAINT fk_person_discounts_pizzeria_id FOREIGN KEY (pizzeria_id) REFERENCES pizzeria(id)
);


/* ex01_So, there is a table person_order which stores the history of a person's orders.
  Please write a DML statement (INSERT INTO ... SELECT ...)
  that makes inserts new records into the person_discounts table based on the following rules.
Take aggregated state from person_id and pizzeria_id columns.
Calculate personal discount value by the next pseudo code:
if “amount of orders” = 1 then “discount” = 10.5
else if “amount of orders” = 2 then “discount” = 22
else “discount” = 30
To create a primary key for the person_discounts table,
use the following SQL construct (this construct is from the WINDOW FUNCTION SQL section).
... ROW_NUMBER( ) OVER ( ) AS id ...*/
INSERT INTO person_discounts(id, person_id, pizzeria_id, discount_value)
SELECT ROW_NUMBER() OVER (ORDER BY po.person_id) AS "id",
       po.person_id,
       m.pizzeria_id,
       CASE COUNT(po.person_id)
         WHEN 1 THEN 10.5
         WHEN 2 THEN 22
         ELSE 30
       END AS "discount_value"
FROM person_order po
JOIN menu m ON po.menu_id = m.id
GROUP BY po.person_id, m.pizzeria_id
ORDER BY 1;

-- DELETE FROM person_discounts;



/* ex02_Write a SQL statement that returns the orders with actual
price and price with discount applied for each person
in the corresponding pizzeria restaurant, sorted by person name and pizza name.
Please see the sample data below.*/
SELECT p.name,
       m.pizza_name,
       m.price,
       (m.price * (1 - pd.discount_value / 100)) AS "discount_price",
       pizz.name AS "pizzeria_name"
FROM person_order po
JOIN person p ON po.person_id = p.id
JOIN menu m ON po.menu_id = m.id
JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
JOIN person_discounts pd ON po.person_id = pd.person_id
    AND m.pizzeria_id = pd.pizzeria_id
ORDER BY p.name, m.pizza_name;



/* ex03_Actually, we need to improve data consistency from one side and performance
tuning from the other side. Please create a multi-column unique index
(named idx_person_discounts_unique) that prevents duplicates of
the person and pizzeria identifier pairs.

After creating a new index, please provide any simple SQL statement
that shows proof of the index usage (using EXPLAIN ANALYZE).*/

CREATE UNIQUE INDEX IF NOT EXISTS idx_person_discounts_unique
    ON person_discounts (person_id, pizzeria_id);

-- DROP INDEX idx_person_discounts_unique;

SET enable_seqscan = off;

EXPLAIN ANALYZE
SELECT *
FROM person_discounts
WHERE person_id = 1
  AND pizzeria_id = 1;

-- INSERT INTO person_discounts(id, person_id, pizzeria_id, discount_value)
-- SELECT MAX(id) + 1 AS id, 1, 1, 22
-- FROM person_discounts;



/* ex04_Please add the following constraint
rules for existing columns of the person_discounts table.

person_id column should not be NULL (use constraint name ch_nn_person_id);
pizzeria_id column should not be NULL (use constraint name ch_nn_pizzeria_id);
discount column should not be NULL (use constraint name ch_nn_discount);
discount column should be 0 percent by default;
discount column should be in a range values from 0 to 100
(use constraint name ch_range_discount).*/

ALTER TABLE person_discounts
ADD CONSTRAINT ch_nn_person_id CHECK (person_id IS NOT NULL),
ADD CONSTRAINT ch_nn_pizzeria_id CHECK (pizzeria_id IS NOT NULL),
ADD CONSTRAINT ch_nn_discount CHECK(discount_value IS NOT NULL),
ADD CONSTRAINT ch_range_discount CHECK(discount_value BETWEEN 0 AND 100),
ALTER COLUMN discount_value SET DEFAULT 0;

-- ALTER TABLE person_discounts
-- DROP CONSTRAINT ch_nn_person_id;
--
-- ALTER TABLE person_discounts
-- DROP CONSTRAINT ch_nn_pizzeria_id;
--
-- ALTER TABLE person_discounts
-- DROP CONSTRAINT ch_nn_discount;
--
-- ALTER TABLE person_discounts
-- DROP CONSTRAINT ch_range_discount;




/* ex05_To comply with Data Governance Policies, you need to add comments
for the table and the table's columns. Let's apply this policy
to the person_discounts table. Please add English or Russian comments
(it is up to you) explaining what is a business goal of a table and all its attributes.*/

COMMENT ON TABLE person_discounts IS 'Table for discounts. I know my worth, and right now I''m on sale.';
COMMENT ON COLUMN person_discounts.id IS 'Primary key ID. PID OR FKID? That''s the question';
COMMENT ON COLUMN person_discounts.person_id IS 'FK references person.id, The lucky person who gets to enjoy the discount. Or the one we are tracking.';
COMMENT ON COLUMN person_discounts.pizzeria_id IS 'FK references pizzeria.id, Pizza Mozarrrella-rella-rella ''s place';
COMMENT ON COLUMN person_discounts.discount_value IS 'The percentage of your savings. Or the amount you’ll spend on extra cheese.';



/* ex06_Let’s create a Database Sequence named seq_person_discounts
(starting with a value of 1) and set a default value for the id attribute of
the person_discounts table to automatically take a value from seq_person_discounts
each time. Please note that your next sequence number is 1, in this case please
set an actual value for database sequence based on formula "number of rows
in person_discounts table" + 1. Otherwise you will get errors about
Primary Key violation constraint.*/


CREATE SEQUENCE IF NOT EXISTS seq_person_discounts START WITH 1;

SELECT SETVAL('seq_person_discounts', (SELECT MAX(id) FROM person_discounts), TRUE);

ALTER TABLE person_discounts
    ALTER COLUMN id SET DEFAULT NEXTVAL('seq_person_discounts');

-- INSERT INTO person_discounts(person_id, pizzeria_id, discount_value)
-- VALUES (1, 2, 22)
-- ON CONFLICT (person_id, pizzeria_id) DO NOTHING;
--
-- SELECT CURRVAL('seq_person_discounts'::regclass);
--
-- DELETE
-- FROM person_discounts
-- WHERE id IN (16, 17, 18);
--
-- SELECT *
-- FROM pg_sequences;
--
-- SELECT * FROM seq_person_discounts;


