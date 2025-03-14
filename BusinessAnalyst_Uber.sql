-- These are questions asked in UBer BA role as per the post https://www.linkedin.com/feed/update/urn:li:activity:7306150836819148801/
-- Q1. Write an SQL query to extract the third transaction of every user, displaying user ID, spend, and transaction date.

WITH RankedTransactions AS (
    SELECT user_id, transaction_amount AS spend, transaction_date,
           ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY transaction_date) AS txn_rank
    FROM transactions
)
SELECT user_id, spend, transaction_date
FROM RankedTransactions
WHERE txn_rank = 3;


-- Q2.Calculate the average ratings for each driver across different cities using data from rides and ratings tables.
SELECT r.driver_id, r.city, AVG(rt.rating) AS avg_rating
FROM rides r
JOIN ratings rt ON r.ride_id = rt.ride_id
GROUP BY r.driver_id, r.city;

-- Q3  Create an SQL query to identify customers registered with Gmail addresses from the 'users' database.
SELECT user_id, username, email
FROM users
WHERE email LIKE '%@gmail.com';


-- Q4. What is database denormalization
/*
Denormalization is the **process of introducing redundancy** into a **normalized database** to improve **read performance** at the cost of **increased storage** and **potential data inconsistencies**.

---

### **Key Points:**
✅ **Trade-off Between Speed & Storage:** It **reduces JOINs** by storing redundant data, making queries faster.  
✅ **Common in OLAP (Analytical) Systems:** Used in **data warehouses** where read performance is more important than write efficiency.  
✅ **Increases Redundancy:** Some data is **stored multiple times** to speed up access.  
✅ **Risk of Data Inconsistencies:** Requires careful handling of **updates and deletions**.

---

### **Example:**
#### **Normalized (3rd Normal Form) - Separate Tables**
| Order_ID | Customer_ID | Product_ID |  
|----------|------------|------------|  
| 101      | 1          | P001       |  
| 102      | 2          | P002       |  

| Customer_ID | Customer_Name |  
|------------|--------------|  
| 1          | Alice        |  
| 2          | Bob          |  

🔹 **Requires a JOIN** to get the customer name in an order query.

#### **Denormalized - Combined Data**
| Order_ID | Customer_Name | Product_ID |  
|----------|--------------|------------|  
| 101      | Alice        | P001       |  
| 102      | Bob          | P002       |  

🔹 **Faster queries, but redundant `Customer_Name` values.**

---

### **When to Use Denormalization?**
- **For faster read-heavy queries (OLAP, Reporting, Analytics).**
- **To reduce expensive JOIN operations.**
- **When performance is prioritized over storage efficiency.**
*/
