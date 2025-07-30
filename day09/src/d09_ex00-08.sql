-- ex00
CREATE TABLE IF NOT EXISTS person_audit(
    created TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT CURRENT_TIMESTAMP,
    type_event CHAR(1) NOT NULL DEFAULT 'I',
    row_id BIGINT NOT NULL,
    name VARCHAR,
    age INTEGER,
    gender VARCHAR,
    address VARCHAR,
    CONSTRAINT ch_type_event CHECK(type_event IN ('I', 'D', 'U'))
);

-- DROP TABLE IF EXISTS person_audit;
-- DELETE FROM person_audit;

CREATE OR REPLACE FUNCTION fnc_trg_person_insert_audit()
RETURNS TRIGGER
AS $$
    BEGIN
        INSERT INTO person_audit(type_event, row_id, name, age, gender, address)
        VALUES('I', NEW.id, NEW.name, NEW.age, NEW.gender, NEW.address);
        RETURN NEW;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_insert_audit
AFTER INSERT ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_insert_audit();

INSERT INTO person(id, name, age, gender, address) VALUES (10,'Damir', 22, 'male', 'Irkutsk');

-- DELETE FROM person
-- WHERE id = 10;

-- DROP TRIGGER trg_person_insert_audit ON person;
-- DROP FUNCTION IF EXISTS fnc_trg_person_insert_audit CASCADE;





-- ex01
CREATE OR REPLACE FUNCTION fnc_trg_person_update_audit()
RETURNS TRIGGER
AS $$
    BEGIN
        INSERT INTO person_audit(type_event, row_id, name, age, gender, address)
        VALUES('U', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
        RETURN OLD;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_update_audit
AFTER UPDATE ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_update_audit();

UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;

-- DROP FUNCTION IF EXISTS fnc_trg_person_update_audit CASCADE;




-- ex02
CREATE OR REPLACE FUNCTION fnc_trg_person_delete_audit()
RETURNS TRIGGER
AS $$
    BEGIN
        INSERT INTO person_audit(type_event, row_id, name, age, gender, address)
        VALUES('D', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
        RETURN OLD;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_delete_audit
BEFORE DELETE ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_delete_audit();

DELETE FROM person WHERE id = 10;

-- DROP FUNCTION IF EXISTS fnc_trg_person_delete_audit CASCADE;




--ex03

-- SELECT *
-- FROM pg_trigger;


DROP TRIGGER IF EXISTS trg_person_insert_audit ON person;
DROP TRIGGER IF EXISTS trg_person_update_audit ON person;
DROP TRIGGER IF EXISTS trg_person_delete_audit ON person;

DROP FUNCTION IF EXISTS fnc_trg_person_insert_audit;
DROP FUNCTION IF EXISTS fnc_trg_person_update_audit;
DROP FUNCTION IF EXISTS fnc_trg_person_delete_audit;

DELETE FROM person_audit;

CREATE OR REPLACE FUNCTION fnc_trg_person_audit()
RETURNS TRIGGER
AS $$
    BEGIN
        IF (TG_OP = 'INSERT') THEN
            INSERT INTO person_audit(type_event, row_id, name, age, gender, address)
            VALUES('I', NEW.id, NEW.name, NEW.age, NEW.gender, NEW.address);
        ELSIF (TG_OP = 'UPDATE') THEN
            INSERT INTO person_audit(type_event, row_id, name, age, gender, address)
            VALUES('U', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
        ELSIF (TG_OP = 'DELETE') THEN
            INSERT INTO person_audit(type_event, row_id, name, age, gender, address)
            VALUES('D', OLD.id, OLD.name, OLD.age, OLD.gender, OLD.address);
        END IF;
        RETURN NULL;
    END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_person_audit
AFTER INSERT OR UPDATE OR DELETE ON person
FOR EACH ROW
EXECUTE FUNCTION fnc_trg_person_audit();


INSERT INTO person(id, name, age, gender, address) VALUES (10,'Damir', 22, 'male', 'Irkutsk');
UPDATE person SET name = 'Bulat' WHERE id = 10;
UPDATE person SET name = 'Damir' WHERE id = 10;
DELETE FROM person WHERE id = 10;



/* ex04_As you recall, we created 2 database views to separate data from the person t
tables by gender attribute. Please define 2 SQL functions (note, not pl/pgsql functions)
with the names:
fnc_persons_female (should return female persons),
fnc_persons_male (should return male persons).
To check yourself and call a function, you can make a statement like
this (Amazing! You can work with a function like a virtual table!):*/

CREATE OR REPLACE FUNCTION fnc_persons_female()
    RETURNS SETOF person
AS
$$
SELECT *
FROM person
WHERE gender = 'female';
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fnc_persons_male()
    RETURNS TABLE
            (
                id     BIGINT,
                name   VARCHAR,
                age    INTEGER,
                gender VARCHAR,
                address VARCHAR
            )
AS
$$
SELECT *
FROM person
WHERE gender = 'male';
$$ LANGUAGE SQL;



SELECT *
FROM fnc_persons_male();

SELECT *
FROM fnc_persons_female();




/* ex05_Looks like 2 functions from Exercise 04 need a more generic approach.
Please remove these functions from the database before proceeding.
Write a generic SQL function (note, not pl/pgsql-function) called fnc_persons.
This function should have an IN parameter pgender with the default value = 'female'.

To check yourself and call a function, you can make a statement like this
(Wow! You can work with a function like with a virtual table, but with more flexibility!):*/

DROP FUNCTION IF EXISTS fnc_persons_female;
DROP FUNCTION IF EXISTS fnc_persons_male;

CREATE OR REPLACE FUNCTION fnc_persons(pgender VARCHAR DEFAULT 'female')
RETURNS SETOF person
AS $$
    SELECT *
    FROM person
    WHERE gender = pgender;
$$ LANGUAGE sql;

select *
from fnc_persons(pgender := 'male');

select *
from fnc_persons();

-- select *
-- from fnc_persons('male');


CREATE OR REPLACE FUNCTION fnc_person_visits_and_eats_on_date
(pperson VARCHAR DEFAULT 'Dmitriy',
 pprice INTEGER DEFAULT 500,
 pdate date DEFAULT '2022-01-08')
RETURNS TABLE (pizzeria_name VARCHAR)
AS $$
    BEGIN
        RETURN QUERY
        WITH person_visits_date AS
                 (SELECT pv.pizzeria_id, visit_date, p.name
                  FROM person_visits pv
                  JOIN person p ON pv.person_id = p.id
                  WHERE pv.visit_date = pdate
                    AND p.name = pperson)

        SELECT pizz.name AS "pizzeria_name"
        FROM person_visits_date AS pvd
        JOIN menu m ON m.pizzeria_id = pvd.pizzeria_id
        JOIN pizzeria pizz ON m.pizzeria_id = pizz.id
        WHERE m.price < pprice;
    END;
$$ LANGUAGE plpgsql;

-- DROP FUNCTION fnc_person_visits_and_eats_on_date;

SELECT *
FROM fnc_person_visits_and_eats_on_date(pprice := 800);

select *
from fnc_person_visits_and_eats_on_date(pperson := 'Anna',pprice := 1300,pdate := '2022-01-01');



/* ex07_Please write an SQL or pl/pgsql function func_minimum (it is up to you)
that has an input parameter that is an array of numbers and the function should
return a minimum value.

To check yourself and call a function, you can make a statement like the one below.*/

CREATE OR REPLACE FUNCTION func_minimum(VARIADIC arr NUMERIC[])
RETURNS NUMERIC
AS $$
    SELECT MIN(values)
    FROM unnest(arr) AS values;
$$ LANGUAGE SQL;

SELECT func_minimum(VARIADIC arr => ARRAY[10.0, -1.0, 5.0, 4.4]);

-- SELECT func_minimum(10.0, -2.0, 5.0, 4.4);




/* ex08_Write an SQL or pl/pgsql function fnc_fibonacci (it's up to you)
that has an input parameter pstop of type integer (default is 10) and the function
output is a table of all Fibonacci numbers less than pstop.*/

CREATE OR REPLACE FUNCTION fnc_fibonacci(pstop INTEGER DEFAULT 10)
RETURNS TABLE (a INTEGER)
AS $$
    WITH RECURSIVE fib AS
    (
    SELECT 0 AS a, 1 AS b, 1 as lvl
    UNION ALL
    SELECT b AS a, a + b AS b, lvl + 1 as lvl
    FROM fib
    WHERE b < pstop
    )
    SELECT a FROM fib;
$$ LANGUAGE SQL;

SELECT *
FROM fnc_fibonacci();
