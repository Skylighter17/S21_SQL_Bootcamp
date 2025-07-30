--ex00
WITH 
last_rate AS (
	SELECT 
		id,
		name,
		rate_to_usd
	FROM
		(SELECT 
			c.*,
			ROW_NUMBER() OVER (PARTITION BY name ORDER BY updated DESC) AS rn
		 FROM currency c)
	WHERE rn = 1
	),
	
user_x_balance AS (
	SELECT DISTINCT
		COALESCE (u.name, 'not defined') AS name,
		COALESCE (u.lastname, 'not defined') AS lastname,
		b.type,
		SUM (money) OVER (PARTITION BY u.id, b.type) AS volume,
		b.currency_id
	FROM balance b
	LEFT JOIN public.user u
	ON b.user_id = u.id
	)

SELECT 
	uxb.name,
	uxb.lastname,
	uxb.type,
	uxb.volume,
	COALESCE (lr.name, 'not defined') AS currency_name,
	COALESCE (lr.rate_to_usd, 1) AS rate_to_usd,
	COALESCE ((volume * rate_to_usd), volume)::real AS total_volume_in_usd
FROM user_x_balance uxb
LEFT JOIN last_rate lr
ON uxb.currency_id = lr.id
ORDER BY uxb.name DESC, uxb.lastname, uxb.type;


--ex01
WITH cleaned_currency AS (
    SELECT c.id,
        c.name
    FROM currency c
    GROUP BY c.id,
        c.name
)
SELECT name,
    lastname,
    currency_name,
    (money * final_rate)::real AS currency_in_usd
FROM (
        SELECT COALESCE(u.name, 'not defined') AS name,
            COALESCE(u.lastname, 'not defined') AS lastname,
            cc.name AS currency_name,
            b.money,
            COALESCE(
                (
                    SELECT rate_to_usd
                    FROM currency c
                    WHERE c.id = b.currency_id
                        AND c.updated < b.updated
                    ORDER BY c.updated DESC
                    LIMIT 1
                ), (
                    SELECT rate_to_usd
                    FROM currency c
                    WHERE c.id = b.currency_id
                        AND c.updated > b.updated
                    ORDER BY c.updated
                    LIMIT 1
                )
            ) AS "final_rate"
        FROM balance b
            FULL JOIN "user" u ON b.user_id = u.id
            JOIN cleaned_currency cc ON b.currency_id = cc.id
    ) AS final
ORDER BY 1 DESC,
    2,
    3;