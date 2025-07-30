-- Dirty Read не произошло. 2 транзакция может видеть только 
-- закоммиченые изменения (т.к. уровень изоляции READ COMMITTED)



-- Session #1

BEGIN;

UPDATE pizzeria SET rating = 5 WHERE name = 'Pizza Hut';

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

COMMIT;

-- Session #2

BEGIN;

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

SELECT * FROM pizzeria WHERE name = 'Pizza Hut';

COMMIT;