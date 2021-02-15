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
