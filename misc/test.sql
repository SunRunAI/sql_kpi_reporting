-- File for testing new sql scripts...

/* 
Get league commission per entry col for all closed leagues.


SELECT *
FROM transactions
WHERE transaction_type = 'League Commission'
LIMIT 2; 
*/

-- Count league entries
WITH entries_counts AS (
    SELECT league_id,
        COUNT(*) AS num_entries
    FROM transactions
    WHERE transaction_type = 'League Entry'
    GROUP BY league_id
    ),
-- Get total commission
commissions AS (
    SELECT league_id,
        amount AS total_commission
    FROM transactions
    WHERE transaction_type = 'League Commission'
    ),
commiss_per_user AS (
    SELECT e.league_id,
        total_commission::DECIMAL / num_entries
        AS commission_per_entry
    FROM entries_counts AS e
    LEFT JOIN commissions AS c
    ON e.league_id = c.league_id
)
SELECT *
FROM transactions AS t
LEFT JOIN commiss_per_user AS c
ON t.league_id = c.league_id
LIMIT 10;
