/* ex00_Please make a select statement which returns all person's names and person's ages from the city ‘Kazan’. */
SELECT
	name,
	age
FROM
	person
WHERE
	address = 'Kazan';


/* ex01_Please make a select statement which returns names , ages for all women from the city ‘Kazan’. 
Yep, and please sort result by name. */
SELECT
	name,
	age
FROM
	person
WHERE
	address = 'Kazan'
	AND gender = 'female'
ORDER BY
	name;



/* ex02_Please make 2 syntax different select statements which return a list of pizzerias (pizzeria name and rating) 
with rating between 3.5 and 5 points (including limit points) and ordered by pizzeria rating */
SELECT
	name,
	rating
FROM
	pizzeria
WHERE
	rating >= 3.5
	AND rating <= 5
ORDER BY
	rating;

SELECT
	name,
	rating
FROM
	pizzeria
WHERE
	rating BETWEEN 3.5 AND 5
ORDER BY
	rating;



/* ex03_Please make a select statement that returns the person identifiers (without duplicates) 
who visited pizzerias in a period from January 6, 2022 to January 9, 2022 (including all days) 
or visited pizzerias with identifier 2. 
Also include ordering clause by person identifier in descending mode. */
SELECT DISTINCT
	person_id
FROM
	person_visits
WHERE
	visit_date BETWEEN '2022-01-06' AND '2022-01-09'
	OR pizzeria_id = 2
ORDER BY
	person_id DESC;



/* ex04_Please make a select statement which returns one calculated field with name 
‘person_information’ in one string like described in the next sample:
Anna (age:16,gender:'female',address:'Moscow')
Finally, please add the ordering clause by calculated column in ascending mode.
Please pay attention to the quotation marks in your formula! */
SELECT
	(
		name || ' (age:' || age || ',gender:' || '''' || gender || '''' || ',address:' || '''' || address || '''' || ')'
	) AS person_information
FROM
	person
ORDER BY
	person_information;



/* ex05_Write a select statement that returns the names of people (based on an internal query in the SELECT clause) 
who placed orders for the menu with identifiers 13, 14, and 18, 
and the date of the orders should be January 7, 2022. */
SELECT (
		SELECT name 
		FROM person p 
		WHERE p.id = po.person_id
		) AS name
FROM person_order po
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18)
	   AND order_date = '2022-01-07';



/* ex06_Use the SQL construction from Exercise 05 and add a new calculated column 
(use column name ‘check_name’) with a check statement 
a pseudocode for this check is given below) in the SELECT clause.
if (person_name == 'Denis') then return true
    else return false */
SELECT (SELECT name FROM person p WHERE p.id = po.person_id) AS name,
		CASE
			WHEN (SELECT name FROM person p WHERE p.id = po.person_id) = 'Denis' THEN true
			ELSE false
		END as check_name
FROM  person_order po
WHERE (menu_id = 13 OR menu_id = 14 OR menu_id = 18)
	   AND order_date = '2022-01-07';




/* ex07_Let's apply data intervals to the person table.
Please make an SQL statement that returns the identifiers of a person, the person's names, 
and the interval of the person's ages (set a name of a new calculated column as 'interval_info') 
based on the pseudo code below.

if (age >= 10 and age <= 20) then return 'interval #1'
else if (age > 20 and age < 24) then return 'interval #2'
else return 'interval #3'

And yes... please sort a result by ‘interval_info’ column in ascending mode.
*/
SELECT id, name,
	   CASE
			WHEN (age >= 10 AND age <= 20) THEN 'interval #1'
			WHEN (age > 20 AND age < 24) THEN 'interval #2'
			ELSE 'interval #3'
		END AS interval_info
FROM person
ORDER BY interval_info ASC;




/* ex08_Create an SQL statement that returns all columns from the person_order 
table with rows whose identifier is an even number. 
The result must be ordered by the returned identifier. */

SELECT *
FROM person_order
WHERE id % 2 = 0
ORDER BY 1;



/* ex09_Please make a select statement that returns person names 
and pizzeria names based on the person_visits table 
with a visit date in a period from January 07 to January 09, 2022 (including all days) 
(based on an internal query in the `FROM' clause).
Please take a look at the pattern of the final query.

SELECT (...) AS person_name ,  -- this is an internal query in a main SELECT clause
        (...) AS pizzeria_name  -- this is an internal query in a main SELECT clause
FROM (SELECT … FROM person_visits WHERE …) AS pv -- this is an internal query in a main FROM clause
ORDER BY ...

Please add a ordering clause by person name in ascending mode and by pizzeria name in descending mode. */
SELECT (
			SELECT name 
			FROM person p 
			WHERE p.id = pv.person_id
		) AS person_name,
		(
			SELECT name
			FROM pizzeria pizz
			WHERE pizz.id = pv.pizzeria_id 
		) AS pizzeria_name
FROM    (
			SELECT * 
			FROM person_visits pv 
			WHERE visit_date 
			BETWEEN '2022-01-07' AND '2022-01-09'
		) AS pv
ORDER BY person_name ASC, pizzeria_name DESC;




