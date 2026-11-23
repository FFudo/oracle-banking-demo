-- 02_sample_data.sql
-- Purpose : creates 10 customers and 21 accounts, 10 Checking, 10 Savings and one closed
-- Run as  : BANK_APP

pro Inserting customers...
INSERT INTO customers (
   first_name,
   last_name,
   email
)
   SELECT 'Customer_' || level,
          'CustomerName_' || level,
          'customer'
          || level
          || '@example.com'
     FROM dual
   CONNECT BY
      level <= 10;

pro Inserting accounts...
INSERT INTO accounts (
   customer_id,
   account_type,
   interest_rate,
   opened_at
)
   SELECT customer_id,
          'CHECKING',
          0,
          systimestamp - INTERVAL '365' DAY
     FROM customers;

INSERT INTO accounts (
   customer_id,
   account_type,
   interest_rate,
   opened_at
)
   SELECT customer_id,
          'SAVINGS',
          0.01 + MOD(
             customer_id,
             5
          ) * 0.005,
          systimestamp - INTERVAL '365' DAY
     FROM customers;

INSERT INTO accounts (
   customer_id,
   account_type,
   status,
   opened_at,
   closed_at
)
   SELECT customer_id,
          'CHECKING',
          'CLOSED',
          systimestamp - INTERVAL '365' DAY,
          systimestamp - INTERVAL '30' DAY
     FROM customers
    WHERE email = 'customer1@example.com';
