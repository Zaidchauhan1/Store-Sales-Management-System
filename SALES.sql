use sales
select*from sales_store

set dateformat dmy
bulk insert sales_store
from 'C:\Users\Redmi\OneDrive\Desktop\sales_store_updated_allign_with_video.csv'
with(
		firstrow=2,
		fieldterminator=',',
		rowterminator='\n'
	);

ALTER TABLE sales_store
ALTER COLUMN customer_name VARCHAR(100)


--for data cleaning, create a duplicate table same as.
select* into Sales from sales_store

select*from Sales
select*from sales_store


--Data Cleaning
--Step:1- To check for duplicate

select transaction_id
from Sales
group by transaction_id
having count(transaction_id)>1

TXN240646
TXN342128
TXN855235
TXN981773

WITH CTE AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM Sales
)
SELECT*FROM CTE
WHERE  Row_Num>1


WITH CTE AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM Sales
)
SELECT*FROM CTE
WHERE  transaction_id IN ('TXN240646','TXN342128','TXN855235','TXN981773')


WITH CTE AS(
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM Sales
)
DELETE FROM CTE
WHERE Row_Num=2


--STEP:2- Correction of Headers.

select*from Sales

EXEC sp_rename'Sales.prce','price','COLUMN'

--STEP:3- To check Datatypes.

SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME='Sales'

--STEP:4- To check NULL VALUES.

----to check null count

DECLARE @SQL NVARCHAR(MAX) ='';

SELECT @SQL = STRING_AGG(
	'SELECT ''' + COLUMN_NAME + ''' AS ColumnName,
	COUNT(*) AS NullCount
	FROM ' + QUOTENAME(TABLE_SCHEMA) + '.Sales
	WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL',
	' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sales';

--Execute the dynamic SQL
EXEC sp_executesql @SQL;

----treating null values.

SELECT *FROM Sales
WHERE transaction_id IS NULL
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR 
product_name IS NULL
OR 
product_category IS NULL
OR 
quantity IS NULL
OR 
price IS NULL
OR 
payment_mode IS NULL
OR 
purchase_date IS NULL
OR 
time_of_purchase IS NULL
OR 
status IS NULL

DELETE FROM Sales
WHERE transaction_id IS NULL

SELECT*FROM Sales
WHERE customer_name='Ehsaan Ram'

UPDATE Sales SET customer_id='CUST9494'
WHERE transaction_id='TXN977900'

SELECT*FROM Sales
WHERE customer_name='Damini Raju'

UPDATE Sales SET customer_id='CUST1401'
WHERE transaction_id='TXN985663'

SELECT*FROM Sales
WHERE customer_id='CUST1003'

UPDATE Sales SET customer_name='Mahika Saini',customer_age=35, gender='Male'
WHERE transaction_id='TXN432798'

--STEP:5-> Data Cleaning

SELECT DISTINCT gender
FROM Sales

UPDATE Sales SET gender='M'
WHERE gender='Male'

UPDATE Sales SET gender='F'
WHERE gender='Female'


SELECT DISTINCT payment_mode 
FROM Sales

UPDATE Sales SET payment_mode='Credit Card'
WHERE payment_mode='CC'

--                           SOLVING BUSINESS INNSIGHTS QUESTIONS.

--DATA ANALYSIS.

--💧1. What are the top 5 most selling products by Quantity?

SELECT*FROM Sales

SELECT DISTINCT status 
FROM Sales

SELECT TOP 5 product_name, SUM(quantity) AS TOTAL_QUANTITY_SOLD
FROM Sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY TOTAL_QUANTITY_SOLD DESC

SELECT TOP 5 product_name, COUNT(quantity) AS TOTAL_QUANTITY_SOLD
FROM Sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY TOTAL_QUANTITY_SOLD DESC
--Business Problems: We don't know which products are most in demand.
--Business Impacts:  Helps prioritize stock and boost sales through targeed promotions.
-----------------------------------------------------------------------------------------------------------
--💧2. Which products are most frequently cancelled.

SELECT*FROM Sales

SELECT DISTINCT status 
FROM Sales

SELECT TOP 5 product_name, COUNT(*) AS TOTAL_CANCELLED
FROM Sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY TOTAL_CANCELLED DESC

--Business Problem:- Frequent cancellations affect revenue and customer trust.
--Business Impacts:- Identity poor-performing products to improve quality or remove from catalog.
------------------------------------------------------------------------------------------------------------------

--⌚3:- What time of the day has the highest number of purchase?

SELECT*FROM Sales
		
		SELECT
			CASE
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
			END AS TIME_OF_DAY,
			COUNT(*) AS TOTAL_ORDERS
		FROM Sales
		GROUP BY
		    CASE
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
				WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
			END 
ORDER BY TOTAL_ORDERS DESC

--Business Problems:- Find peak sales times.
--Business Impacts:-  Optimize staffing, promotes and server loads.
------------------------------------------------------------------------------------------------------------------
--4:- Who are the top 5 highest spending customers?

select*from Sales

SELECT TOP 5 customer_name,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS TOTAL_SPEND
FROM Sales
GROUP BY customer_name
ORDER BY SUM(price*quantity) DESC

--Business Problems:- Idenity VIP customers.
--Business Impacts:-  Personalized offers, loyalty rewards and retention.
--------------------------------------------------------------------------------------------------------------------
--5:- Which products categories generate the highest revenue?

SELECT product_category, SUM(price*quantity) AS 'TOTAL_REVENUE'
FROM Sales
GROUP BY product_category
ORDER BY TOTAL_REVENUE DESC

SELECT product_category, 
	FORMAT(SUM(price*quantity), 'C0','en-IN') AS 'TOTAL_REVENUE'
FROM Sales
GROUP BY product_category
ORDER BY SUM(price*quantity) DESC

--Business Problems:- Identify top-performing product categories.
--Business Impacts:-  Refine Product strategy, supply chain and promotion.
--                    allowing the  business to invert more in high-margin or high-demand categories.

--6:- What is the return/cancellation rate per product category?

SELECT product_category,
	COUNT(CASE WHEN status='cancelled'THEN 1 END)*100.0/COUNT(*)AS CANCELLED_PAYMENT
FROM Sales
GROUP BY product_category
ORDER BY CANCELLED_PAYMENT DESC

SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='cancelled'THEN 1 END)*100.0/COUNT(*),'N3')+ '%' AS CANCELLED_PAYMENT
FROM Sales
GROUP BY product_category
ORDER BY CANCELLED_PAYMENT DESC

--RETURN
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='returned'THEN 1 END)*100.0/COUNT(*),'N3')+ '%' AS RETURNED_PAYMENT
FROM Sales
GROUP BY product_category
ORDER BY RETURNED_PAYMENT DESC

--Business problems:- moniter dissatisfacton trends per category.
--Business Impacts:-  reduce returns, improve oroduct description/expectations
--                    helps identify and fix product or logistics issues.

-------------------------------------------------------------------------------------------------------------------------
--7:- What is the most preferred payment mode?

SELECT payment_mode,COUNT(payment_mode) AS 'TOTAL_COUNT'
FROM Sales
GROUP BY payment_mode
ORDER BY TOTAL_COUNT DESC

--Business Problems:- Know which payment options customers prefer.
--Business Impact:-   Streamline payment processing, prioritize popular modes.
-------------------------------------------------------------------------------------------------------------------------

--8:- How does age group affect purchasing behaviour.

SELECT*FROM Sales

SELECT MIN(customer_age), MAX(customer_age)
FROM Sales


SELECT 
	CASE
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS customer_age,
	FORMAT(SUM(price*quantity) ,'C0','en-IN')AS TOTAL_PURCHASE
FROM Sales
GROUP BY CASE
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END 
ORDER BY TOTAL_PURCHASE DESC

--Business Problems:- Understand customer demographics.
--Business Impacts:-  Targeted marketing and product recommendations by age group.
------------------------------------------------------------------------------------------------------------------------

--9:- What's The Monthly sales trend?

SELECT*FROM Sales

--METHOD:-1

SELECT 
	FORMAT(purchase_date,'yyyy-MM') AS MONTH_YEAR,
	FORMAT(SUM(price*quantity) ,'C0','en-IN')AS TOTAL_SALES,
	SUM(quantity) AS TOTAL_QUANTITY
FROM Sales
GROUP BY FORMAT(purchase_date,'yyyy-MM')

--METHOD:-2

SELECT 
	YEAR(purchase_date) AS YEARS,
	MONTH(purchase_date) AS MONTHS,
	FORMAT(SUM(price*quantity) ,'C0','en-IN')AS TOTAL_SALES,
	SUM(quantity) AS TOTAL_QUANTITY
FROM Sales
GROUP BY YEAR(purchase_date),MONTH(purchase_date)
ORDER BY MONTHS 

--2023	1	₹ 46,28,608
--2024	1	₹ 3,39,442
SELECT(4628608+339442)--4968050

SELECT 
	MONTH(purchase_date) AS MONTHS,
	FORMAT(SUM(price*quantity) ,'C0','en-IN')AS TOTAL_SALES,
	SUM(quantity) AS TOTAL_QUANTITY
FROM Sales
GROUP BY MONTH(purchase_date)
ORDER BY MONTHS

--Business Problems:- sales fluctuation go unnoticed.

--Business Impacts:-  Plan inventory and marketing according to seasonal trends.
--------------------------------------------------------------------------------------------------------------------

--10:- Are certain genders buying more specific product categories?

SELECT gender,product_category,COUNT(product_category) AS TOTAL_PURCHASE
FROM Sales
GROUP BY gender,product_category
ORDER BY TOTAL_PURCHASE DESC

SELECT gender,product_category,COUNT(product_category) AS TOTAL_PURCHASE
FROM Sales
GROUP BY gender ,product_category
ORDER BY gender 


--METHOD_2

SELECT*
FROM(
	SELECT gender,product_category
	FROM Sales
	)AS SOURCE_TABLE
PIVOT(
	COUNT(gender)
	FOR gender IN ([M],[F])
	) AS PIVOT_TABLE
ORDER BY product_category

--Business Problems:- Gender_based product preferences
--Business impacts:-  Personalized ads, gender-focused campaigns.