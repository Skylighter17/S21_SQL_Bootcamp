-- Phantom read не происходит, 1 транзакция считает сумму из снапшота
-- который был сделан на момент начала транзакции

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
