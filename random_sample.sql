/* 
Grabs a random sample of user transactions 
who joined within a certain time period. 

Allows for rudimentary scalable EDA.
*/

WITH const AS (
    SELECT '2021-01-01'::DATE AS cutoff
),
valid_users AS (
    SELECT a.user_id, 
        display_name,
        first_deposit
    FROM accounts AS a
    INNER JOIN user_aggs AS u
    ON a.user_id = u.user_id
    CROSS JOIN const
    WHERE  u.first_deposit >= cutoff
),
sample_users AS (
    SELECT user_id, display_name 
    FROM valid_users 
    ORDER BY random()
    LIMIT 1000
)
SELECT *
FROM transactions AS t
INNER JOIN sample_users AS s
ON t.display_name = s.display_name;
