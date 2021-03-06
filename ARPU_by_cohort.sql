/* 
ARPU decay by cohort 
*/

-- Set constants to round off start/end dates to full months of data
WITH const AS (
    SELECT '2019-09-01'::DATE AS start_date,
        DATE_TRUNC('month', NOW()) AS end_date
    ),
-- Count league entries
entries_counts AS (
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
-- Calculate league commission per user
commiss_per_user AS (
    SELECT e.league_id,
        total_commission::DECIMAL / num_entries
        AS commission_per_entry
    FROM entries_counts AS e
    LEFT JOIN commissions AS c
    ON e.league_id = c.league_id
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
            AS month,
            commission_per_entry
    FROM transactions AS t
    LEFT JOIN commiss_per_user AS c
    ON t.league_id = c.league_id
    CROSS JOIN const
    WHERE transaction_type = 'League Entry'
        AND date >= start_date
        AND date <= end_date
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
-- Get total entry spend from each cohort in a given month
cohort_spend AS (
    SELECT acquisition_month,
        month - acquisition_month AS months_since_acq,
        SUM(u.commission_per_entry) AS total_cohort_spend
        FROM user_activity AS u
        LEFT JOIN acquisition_months as a
        ON u.user = a.user
        GROUP BY acquisition_month, months_since_acq
    ),
full_dates AS (
    SELECT month,
           DATE_TRUNC('month', MIN(date)) AS full_date
    FROM user_activity
    GROUP BY month
    )
-- Gen final table
SELECT f.full_date,
       sp.acquisition_month,
       sp.months_since_acq,
       num_acquired_users,
       total_cohort_spend,
       (total_cohort_spend::DECIMAL
       / num_acquired_users)
       AS spend_per_user
       FROM cohort_sizes AS si
       LEFT JOIN cohort_spend AS sp
       ON si.acquisition_month = sp.acquisition_month
       LEFT JOIN full_dates AS f
       ON si.acquisition_month = f.month
       ORDER BY acquisition_month, months_since_acq;
