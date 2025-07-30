-- Deadlock, процессы блокируют друг друга, так как в 1 изменяется
-- значения, которое до этого без коммита было изменено во 2,
-- а во второй также изменяется значение 1. То есть 1 транзакция
-- ждет коммита 2, а 2 транзакция ждет коммита 1

-- Session #1
BEGIN;
UPDATE pizzeria SET rating = 2.5 WHERE id = 1;
UPDATE pizzeria SET rating = 1.3 WHERE id = 2;
COMMIT;
SELECT * FROM pizzeria;

-- Session #2
BEGIN;
UPDATE pizzeria SET rating = 1.4 WHERE id = 2;
UPDATE pizzeria SET rating = 2.8 WHERE id = 1;
COMMIT;


