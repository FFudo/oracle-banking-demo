-- 02_sample_data.sql
-- Purpose : creates 10 customers and 21 accounts, as well as transactions and updates balances
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
          systimestamp - INTERVAL '365' DAY ( 3 )
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
          systimestamp - INTERVAL '365' DAY ( 3 )
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
          systimestamp - INTERVAL '365' DAY ( 3 ),
          systimestamp - INTERVAL '30' DAY ( 3 )
     FROM customers
    WHERE email = 'customer1@example.com';

pro    Inserting transactions...
DECLARE
   l_balance NUMBER(
      15,
      2
   );
   l_amount  NUMBER(
      15,
      2
   );
   l_type    transactions.txn_type%TYPE;
BEGIN
   dbms_random.seed(42);
   FOR r IN (
      SELECT account_id,
             opened_at
        FROM accounts
       WHERE status = 'OPEN'
       ORDER BY account_id
   ) LOOP
      l_balance := 0;
      FOR i IN 1..15 LOOP
         IF i = 1
         OR l_balance < 100
         OR dbms_random.value < 0.6 THEN
            l_type := 'DEPOSIT';
            l_amount := round(
               dbms_random.value(
                  50,
                  1000
               ),
               2
            );
            l_balance := l_balance + l_amount;
         ELSE
            l_type := 'WITHDRAWAL';
            l_amount := round(
               dbms_random.value(
                  10,
                  l_balance / 2
               ),
               2
            );
            l_balance := l_balance - l_amount;
         END IF;

         INSERT INTO transactions (
            account_id,
            txn_type,
            amount,
            description,
            txn_date
         ) VALUES
            ( r.account_id,
              l_type,
              l_amount,
              'Sample data',
              r.opened_at + ( i - 1 ) * 24 + dbms_random.value(
                 0,
                 24
              ) );
      END LOOP;
   END LOOP;
END;
/

pro    Calculating balances...
UPDATE accounts a
   SET
   balance = (
      SELECT nvl(
         sum(
            CASE
               WHEN t.txn_type IN('DEPOSIT',
                                  'TRANSFER_IN',
                                  'INTEREST') THEN
                  t.amount
               ELSE
                  - t.amount
            END
         ),
         0
      )
        FROM transactions t
       WHERE t.account_id = a.account_id
   );

COMMIT;
