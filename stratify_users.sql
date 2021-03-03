/* 
Stratifies customers into 3 tranches across each month:
    - new
    - retained
    - returning
*/

-- Set constant
WITH const AS (
    SELECT '2019-09-01'::DATE AS start_date
    ),
-- Get deltas between times played, and start of observation period
user_activity AS (
    SELECT  display_name AS user,
            t.date AS date,
            (DATE_PART('year', t.date) 
            - DATE_PART('year', start_date)) 
            * 12
            + (DATE_PART('month', t.date)
            - DATE_PART('month', start_date))
            AS month
    FROM transactions AS t 
    CROSS JOIN const
    WHERE transaction_type = 'League Entry'
        AND date >= start_date
    ),
-- Get lead time between user activity in months
user_lags AS (
    SELECT  u.user,
            month,
            LAG(u.month, 1)
            OVER(PARTITION BY u.user ORDER BY u.month)
            AS lag_month
            FROM user_activity AS u
    ),
-- Get time deltas between activities
time_deltas AS (
    SELECT u.user,
           month,
           lag_month,
           month - lag_month AS delta
           FROM user_lags AS u
    ),
-- Generate customer state categorical column
retention AS (
    SELECT t.user, 
        month, 
        lag_month, 
        delta,
        CASE WHEN delta IS NULL THEN 'new'
        WHEN delta = 1 THEN 'retained'
        WHEN delta >= 2 THEN 'returning'
        END AS cust_state
        FROM time_deltas AS t
    ),
-- Grab full month commencing dates
full_dates AS (
    SELECT month,
           DATE_TRUNC('month', MIN(date)) AS full_date
    FROM user_activity
    GROUP BY month
)
-- Calculate customer state
SELECT r.month,
       MIN(f.full_date) AS date,
       COUNT(DISTINCT r.user) AS num_users,
       SUM(CASE WHEN cust_state = 'new' THEN 1
           ELSE 0 END)::DECIMAL / COUNT(DISTINCT r.user)
       AS new,
       SUM(CASE WHEN cust_state = 'retained' THEN 1
           ELSE 0 END)::DECIMAL / COUNT(DISTINCT r.user)
       AS retained,
       SUM(CASE WHEN cust_state = 'returning' THEN 1
           ELSE 0 END)::DECIMAL / COUNT(DISTINCT r.user)
       AS returning
       FROM retention AS r
       INNER JOIN full_dates AS f
       ON r.month = f.month
       GROUP BY r.month;
