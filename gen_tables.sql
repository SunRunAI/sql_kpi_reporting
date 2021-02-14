/* Generate and populate WKW mock up tables from csv files
*/

-- TRANSACTIONS

-- Create transactions table
CREATE TABLE transactions (
  transaction_id INT,
  date DATE,
  transaction_type VARCHAR(20),
  display_name VARCHAR(20),
  league_name VARCHAR(100),
  league_id VARCHAR(73),
  amount NUMERIC(8, 2),
  status VARCHAR(15),
  PRIMARY KEY (transaction_id)
);

-- Import csv data file
COPY transactions (
    transaction_id,
    date,
    transaction_type, 
    display_name,
    league_name,
    league_id,
    amount,
    status
    )
FROM 'C:/Users/Public/wkw_transactions_table.csv'
DELIMITER ','
CSV HEADER;


-- USER ACCOUNT INFO

-- Create users table
CREATE TABLE accounts (
  user_id VARCHAR(36),
  display_name VARCHAR(25),
  first_name VARCHAR(25),
  last_name VARCHAR(25),
  email VARCHAR(50),
  dob DATE,
  gender VARCHAR(25),
  city VARCHAR(50),
  country VARCHAR(50),
  email_verified BOOLEAN,
  terms_version NUMERIC(4, 2),
  marketing_permission BOOLEAN,
  identity_verified VARCHAR(25),
  account_enabled BOOLEAN,
  gamstop_state VARCHAR(5),
  PRIMARY KEY (user_id)
);

-- Import csv file
COPY accounts (
  user_id,
  display_name,
  first_name,
  last_name,
  email,
  dob,
  gender,
  city,
  country,
  email_verified,
  terms_version,
  marketing_permission,
  identity_verified,
  account_enabled,
  gamstop_state
)
FROM 'C:/Users/Public/user_accounts.csv'
DELIMITER ','
CSV HEADER;


-- USER AGGREGATES INFO

-- Create user aggregates table
CREATE TABLE user_aggs (
  user_id VARCHAR(36),
  balance NUMERIC(8, 2),
  first_deposit DATE,
  last_deposit DATE,
  first_withdrawal DATE,
  last_withdrawal DATE,
  first_entry DATE,
  last_entry DATE,
  total_deposits INT,
  total_withdrawals INT,
  total_entries INT,
  total_deposit_amount NUMERIC(8, 2),
  total_withdrawal_amount NUMERIC(8, 2),
  total_entry_amount NUMERIC(8, 2),
  PRIMARY KEY (user_id)
);

-- Import csv file
COPY user_aggs (
  user_id,
  balance,
  first_deposit,
  last_deposit,
  first_withdrawal,
  last_withdrawal,
  first_entry,
  last_entry,
  total_deposits,
  total_withdrawals,
  total_entries,
  total_deposit_amount,
  total_withdrawal_amount,
  total_entry_amount
)
FROM 'C:/Users/Public/user_aggs.csv'
DELIMITER ','
CSV HEADER;


-- TEST

-- Test data imported correctly
SELECT *
FROM transactions
LIMIT 5;

SELECT *
FROM accounts 
LIMIT 5;

SELECT *
FROM user_aggs
LIMIT 5;
