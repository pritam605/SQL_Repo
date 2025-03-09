-- Q1. Find total revenue for last 12 months of client's Date may contain across year values. 

SELECT 
  SUM(REVENUE) AS TOTAL_REVENUE
FROM
  REVENUE_ACTUAL
WHERE TRANSACTION_DATE >= DATEADD(MONTH,12,CURRENT_DATE)

-- Note: DateAdd works in MYSQL but not in PostGraceSQL so make sure to use alternatives for cases where DATEADD is not working. 
-- Alternatively
-- WHERE TRANSACTION_DATE >= CURRENT_DATE - INTERVAL '12 months'
