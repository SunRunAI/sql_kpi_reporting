-- Create transactions table
CREATE TEMPORARY TABLE transactions (
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

-- Test data imported correctly
SELECT *
FROM transactions 
LIMIT 5;
