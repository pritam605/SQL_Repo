-- Q1. Find total revenue for last 12 months of client. Date may contain values across years. (Snowflake)
SELECT 
  SUM(REVENUE) AS TOTAL_REVENUE
FROM
  REVENUE_ACTUAL
WHERE TRANSACTION_DATE >= DATEADD(MONTH,12,CURRENT_DATE)

-- Note: DateAdd works in MYSQL but not in PostGraceSQL so make sure to use alternatives for cases where DATEADD is not working. 
-- Alternatively
-- WHERE TRANSACTION_DATE >= CURRENT_DATE - INTERVAL '12 months'

-- Q2. Find top 5 customer names based on their transactions last 12 months (Snowflake)
SELECT 
  c.account_name, 
  sum(r.revenue) as TOTAL_REVENUE
FROM REVENUE r
LEFT JOIN CUSTOMER_DETAILS c
ON r.account_id = c.account_id
WHERE transaction_date >= DATEDADD(MONTH,12, CURRENT_DATE)
GROUP BY 1 ORDER BY 2 DESC LIMIT 5;


--Q3. Calculate MoM values for revenue for each Client. (Snowflake)
SELECT 
  account_id, 
  SUM(REVENUE) AS TOTAL_REVENUE,
  (SUM(REVENUE) - LAG(SUM(REVENUE)) OVER (ORDER BY account_id)) AS LAGGED_REVENUE -- No need to partition by account_id because it is already partitioned.
FROM
  REVENUE
WHERE TRANSACTION_DATE >= DATEADD(MONTH,12,CURRENT_DATE)
group by 1;


-- Q4. Write a SQL query to retrieve the final account balance for each account by calculating the net amount from deposits and withdrawals. (Paypal)
-- Input Table:
-- transactions table:
 -- transaction_id (integer)
 -- account_id (integer)
 -- amount (decimal)
 -- transaction_type (varchar)

SELECT 
  ACCOUNT_ID,
  (SUM(CASE WHEN TRANSACTION_TYPE = 'Deposit' then AMOUNT ELSE 0 END) - SUM(CASE WHEN TRANSACTION_TYPE = 'Withdrawl' then AMOUNT ELSE 0 END)) 
AS Final_Account_Balance
FROM TRANSACTIONS
GROUP BY 1;

-- Q5. Average Transaction Amount per User
-- Write a SQL query to compute the average transaction amount for each user and rank the users in descending order based on their average transaction amount.

--Input Table:
-- transactions table:
 -- transaction_id (integer)
 -- user_id (integer)
 -- transaction_date (date)
 -- amount (decimal)

-- Self Attempt
SELECT
  user_id,
  avg(amount) over (order by user_id) as ord
FROM transactions
group by user_id;

--Solution found on internet - 
WITH avg_trans AS (
 SELECT user_id, 
 ROUND(AVG(amount), 2) AS avg_trans_amt 
 FROM transactions2
 GROUP BY user_id
)
SELECT user_id, 
 avg_trans_amt, 
 DENSE_RANK() OVER(ORDER BY avg_trans_amt DESC) AS rnk 
FROM avg_trans
ORDER BY rnk;
