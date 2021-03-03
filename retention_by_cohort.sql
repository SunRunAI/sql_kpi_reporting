
/* 
Retention decay by cohort 
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
-- Get each user's month of acquisition  
acquisition_months AS (
    SELECT u.user,
        MIN(month) AS acquisition_month
    FROM user_activity AS u
    GROUP BY u.user
    ),
-- Get acquisition numbers for each month
cohort_sizes AS (
    SELECT acquisition_month,
        COUNT(a.user) AS num_acquired_users
    FROM acquisition_months AS a
    GROUP BY acquisition_month
    ORDER BY acquisition_month
    ),
-- Get number of actives from each cohort in a given month
cohort_actives AS (
    SELECT acquisition_month,
        month - acquisition_month AS retention_month,
        COUNT(DISTINCT u.user) AS num_cohort_actives
        FROM user_activity AS u
        LEFT JOIN acquisition_months as a
        ON u.user = a.user
        GROUP BY acquisition_month, retention_month
    )
-- Gen retention figure
SELECT s.acquisition_month,
       retention_month,
       num_acquired_users,
       num_cohort_actives,
       (num_cohort_actives::DECIMAL
       / num_acquired_users)
       AS retention
       FROM cohort_sizes AS s
       LEFT JOIN cohort_actives AS a
       ON s.acquisition_month = a.acquisition_month;
