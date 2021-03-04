/* 
Set of queries returning key performance indicator (KPI) 
data for an app based company with information stored in 3 
tables. Queries are written in postgres.

accounts - Contains info relating to user accounts (usernames, emails, date of birth etc...) 
transactions - Contains info relating to transactions happening within the app (date transaction occured, amount transacted etc...)
user_aggs - Contains aggregate data relating to a user's account (date of first deposit, account balance etc...)
*/

-- First time depositors (FTD's) by month
SELECT DATE_TRUNC('month', first_deposit) AS month, COUNT(*) AS FTDs
FROM user_aggs
GROUP BY month
ORDER BY month;

-- Active users by month
SELECT DATE_TRUNC('month', date) AS month, 
COUNT(DISTINCT display_name) AS actives
FROM transactions
WHERE transaction_type = 'League Entry'
GROUP BY month
ORDER BY month;

--  Average revenue per user (ARPU) by month
SELECT DATE_TRUNC('month', date) AS month, 
SUM(amount) / COUNT(DISTINCT display_name) AS ARPU
FROM transactions
WHERE transaction_type = 'League Entry'
GROUP BY month
ORDER BY month;

/*
Rank most valuable customers by spend
in the last 30 day period. 
*/

WITH const AS (
    SELECT current_date - 30 AS cutoff
    )
SELECT RANK() 
       OVER(ORDER BY 
            SUM(amount) DESC) 
       AS spend_ranking,
       display_name,
       SUM(amount) AS total_entry_value,
       COUNT(*) AS total_league_entries
FROM transactions
CROSS JOIN const
WHERE date >= cutoff
    AND transaction_type = 'League Entry'
GROUP BY display_name
LIMIT 25;

/*
First time entries ranked by league name
to generate an acquisition by league proxy.
*/

WITH const AS (
    SELECT current_date - 30 AS cutoff
    ),
-- Grab each user's first entries
first_entries AS (
    SELECT row_number() OVER (PARTITION BY display_name ORDER BY date),
        date,
        display_name,
        league_name
    FROM transactions 
    WHERE transaction_type = 'League Entry'
)
-- Aggregate by league name 
SELECT RANK() OVER(ORDER BY COUNT(*) DESC),
       league_name,
       COUNT(*) AS acquisition_by_league
FROM first_entries
CROSS JOIN const
WHERE row_number = 1
      AND date >= cutoff
GROUP BY league_name
LIMIT 10;
