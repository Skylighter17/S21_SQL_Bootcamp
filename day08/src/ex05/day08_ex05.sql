-- Phantom read, хоть и никакие записи через update не изменялись,
-- однако из-за вставки нового значения 
-- результат агрегирующей функции изменился

-- Session #1

BEGIN;
SELECT SUM(rating) FROM pizzeria;
SELECT SUM(rating) FROM pizzeria;
COMMIT;
SELECT SUM(rating) FROM pizzeria;
-- Session #2
BEGIN;
INSERT INTO pizzeria(id, name, rating) VALUES (10, 'Kazan Pizza', 5);
COMMIT;
SELECT SUM(rating) FROM pizzeria;
