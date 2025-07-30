-- Non-repeatable read, не происходит, так как в уровне изоляции
-- Serializable транзакции при просмотре делают SELECT из 
-- снапшота БД до транзакции(до всех изменений)

-- Session #1
BEGIN;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';
COMMIT;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

-- Session #2

BEGIN;
UPDATE pizzeria SET rating = 3.6 WHERE name = 'Pizza Hut';
COMMIT;
SELECT * FROM pizzeria WHERE name = 'Pizza Hut';