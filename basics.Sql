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




-- Q 6: Unique Money Transfer Relationships (**)
--Write a SQL query to determine the number of unique two-way money transfer relationships, where a two-way relationship is established if a user has sent money to another user and also received money from the same user.

-- Input Table:
 -- payments table:
 -- payer_id (integer)
 -- recipient_id (integer)
 -- amount (integer)

SELECT 
  --COUNT(DISTINCT CASE WHEN AMOUNT IS NOT NULL THEN 1 ELSE 0 END) as Count_usersCOUNT(DISTINCT 
    COUNT(DISTINCT
      CASE 
           WHEN p.payer_id < p.recipient_id THEN CONCAT(p.payer_id, '-', p.recipient_id)
           ELSE CONCAT(p.recipient_id, '-', p.payer_id)
       END) AS two_way_relationships
FROM
PAYMENTS P SELF JOIN PAYMENTS Q 
ON p.payer_id = q.recipient_id AND q.recipient_id = q.payer_id

Note: Here, take a note of the multiple join condition. There are 2 keys on which join is happening. Also, make sure we are handling the 2 way counting. 
--Avoid double counting:
--p.payer_id < p.recipient_id ensures that we always count pairs (A, B) and not (B, A) separately.
--CONCAT(p.payer_id, '-', p.recipient_id) creates a unique key for each pair.
--COUNT(DISTINCT ...) ensures that duplicate transactions don't inflate the count.

'''
How We Avoid Double Counting
We ensure each unique relationship (A, B) is counted only once, not twice as (A, B) and (B, A). We achieve this using three key techniques:

1️⃣ Using p.payer_id < p.recipient_id
This ensures that we only count one order of the pair.

If we encounter a pair (A → B), we count it only if A < B.
When we find (B → A), we skip it because B > A is not allowed.
Example:

payer_id	recipient_id	Condition payer_id < recipient_id	Counted?
A	B	✅ Yes (A < B)	✅ Counted
B	A	❌ No (B > A)	❌ Skipped
Thus, we only count one instance of (A, B).

2️⃣ Creating a Unique Key using CONCAT(p.payer_id, '-', p.recipient_id)
To make sure that each relationship is treated as a single entity, we generate a unique string identifier for each user pair.

sql
Copy
Edit
CONCAT(p.payer_id, '-', p.recipient_id)
Example:

payer_id	recipient_id	Generated Key
1	2	"1-2"
2	1	"2-1"
However, to ensure both (1-2) and (2-1) are treated the same, we modify this logic:

sql
Copy
Edit
CASE 
    WHEN p.payer_id < p.recipient_id THEN CONCAT(p.payer_id, '-', p.recipient_id)
    ELSE CONCAT(p.recipient_id, '-', p.payer_id)
END
This ensures:

(1-2) and (2-1) always get converted into the same key: "1-2"
(3-4) and (4-3) become "3-4"
Thus, only one unique key is generated per user pair.

3️⃣ Using COUNT(DISTINCT ...) to Remove Duplicates
Finally, we apply COUNT(DISTINCT ...) to count only unique relationships and avoid counting duplicates.

sql
Copy
Edit
COUNT(DISTINCT <generated unique key>)
This ensures that if the same users (A and B) transfer money multiple times, we still count only one relationship.

Example:

payer_id	recipient_id	Unique Key
1	2	"1-2"
2	1	"1-2"
1	2	"1-2"
Since all transactions generate the same key, COUNT(DISTINCT "1-2") only counts it once.
'''


Question 4: Determining High-Value Customers
Write a SQL query to identify users who, in the last month, have either sent payments over 1000 or received payments over 5000, excluding those flagged as fraudulent.

Input Tables:
• transactions table:
 - transaction_id (integer)
 - user_id (integer)
 - transaction_date (date)
 - transaction_type (varchar)
 - amount (decimal)

• users table:
 - user_id (integer)
 - username (text)
 - is_fraudulent (boolean)

Question 5: Analyzing User Transaction Data
Write a SQL query that calculates the total and average transaction amount for each user, including only those users who have made at least two transactions.

Input Tables:
• Users table:
 - user_id (integer)
 - signup_date (date)

• Transactions table:
 - transaction_id (integer)
 - user_id (integer)
 - transaction_date (date)
 - transaction_amount (decimal)



-- As per solutions found on Internet
3) SELECT COUNT(*) AS unique_relationships
FROM (
 SELECT LEAST(payer_id, recipient_id) AS user1,
 GREATEST(payer_id, recipient_id) AS user2
 FROM payments3
 WHERE (payer_id, recipient_id) IN (
 SELECT recipient_id, payer_id FROM payments3
 )
 GROUP BY LEAST(payer_id, recipient_id), GREATEST(payer_id, recipient_id)
) AS unique_pairs;

4) SELECT a.user_id, b.username, a.transaction_date, a.transaction_type, a.amount
FROM transactions a
INNER JOIN users b ON a.user_id = b.user_id
WHERE b.is_fraudulent = 0
AND a.transaction_date >= DATE_SUB(CURDATE(), INTERVAL 1 MONTH)
AND (
 (a.transaction_type = 'send' AND a.amount > 1000) 
 OR 
 (a.transaction_type = 'receive' AND a.amount > 5000)
);

5) SELECT user_id, 
 SUM(transaction_amount) AS total_amount, 
 AVG(transaction_amount) AS average_amount 
FROM transactions4
GROUP BY user_id
