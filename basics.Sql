-- Q1. Find total revenue for last 12 months of client. Date may contain values across years.

SELECT 
  SUM(REVENUE) AS TOTAL_REVENUE
FROM
  REVENUE_ACTUAL
WHERE TRANSACTION_DATE >= DATEADD(MONTH,12,CURRENT_DATE)

-- Note: DateAdd works in MYSQL but not in PostGraceSQL so make sure to use alternatives for cases where DATEADD is not working. 
-- Alternatively
-- WHERE TRANSACTION_DATE >= CURRENT_DATE - INTERVAL '12 months'

-- Q2. Find top 5 customer names based on their transactions last 12 months
SELECT 
  c.account_name, 
  sum(r.revenue) as TOTAL_REVENUE
FROM REVENUE r
LEFT JOIN CUSTOMER_DETAILS c
ON r.account_id = c.account_id
WHERE transaction_date >= DATEDADD(MONTH,12, CURRENT_DATE)
GROUP BY 1 ORDER BY 2 DESC LIMIT 5;
