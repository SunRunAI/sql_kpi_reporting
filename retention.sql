/* 
Calculate month on month + week on week user retention
A user is considered to be active in a given period if 
they enter at least 1 league.
*/

-- Set hardcoded constant
WITH obs_period AS (
    SELECT '2019-09-01'::DATE AS start_date
    ),
-- Get deltas between times played, and start of observation period
user_activity AS (
    SELECT  display_name AS user,
            (DATE_PART('year', t.date) 
            - DATE_PART('year', start_date)) 
            * 12
            + (DATE_PART('month', t.date)
            - DATE_PART('month', start_date))
            AS month
    FROM transactions AS t 
    CROSS JOIN obs_period
    WHERE transaction_type = 'League Entry'
        AND date >= start_date
    ),
-- Get lead time between user activity in months
user_lags AS (
    SELECT  u.user,
            month,
            LEAD(u.month, 1)
            OVER(PARTITION BY u.user ORDER BY u.month)
            AS lead_month
            FROM user_activity AS u
    ),
-- Get time deltas between activities
time_deltas AS (
    SELECT u.user,
           month,
           lead_month,
           lead_month - month AS delta
           FROM user_lags AS u
    ),
-- Generate customer state categorical column
retention AS (
    SELECT t.user, 
        month, 
        lead_month, 
        delta,
        CASE WHEN delta IS NULL THEN 'churned'
        WHEN delta = 1 THEN 'retained'
        WHEN delta >= 2 THEN 'lagged'
        END AS cust_state
        FROM time_deltas AS t
    )
-- Calculate retention rate
SELECT month,
       COUNT(DISTINCT r.user) AS num_users,
       SUM(CASE WHEN cust_state = 'retained' THEN 1
           ELSE 0 END)
       AS num_retained,
       SUM(CASE WHEN cust_state = 'retained' THEN 1
           ELSE 0 END)::DECIMAL / COUNT(DISTINCT r.user)
       AS retention_rate
       FROM retention AS r
       GROUP BY month;
