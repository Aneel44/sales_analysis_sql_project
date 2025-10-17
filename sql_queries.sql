-- drop table if exists
DROP TABLE IF EXISTS SALES_DATA;

-- create table
CREATE TABLE SALES_DATA (
	TRANSACTIONS_ID INT PRIMARY KEY,
	SALE_DATE DATE,
	SALE_TIME TIME,
	CUSTOMER_ID INT,
	GENDER VARCHAR(15),
	AGE INT,
	CATEGORY VARCHAR(25),
	QUANTITY INT,
	PRICE_PER_UNIT FLOAT,
	COGS FLOAT,
	TOTAL_SALE FLOAT
);

-- view the first 10 rows data
SELECT
	*
FROM
	SALES_DATA
LIMIT
	10;

-- count the total number of rows
SELECT
	COUNT(*)
FROM
	SALES_DATA;

-- Data Cleaning
-- checking/ handling null values
SELECT
	*
FROM
	SALES_DATA
WHERE
	TRANSACTIONS_ID IS NULL
	OR SALE_DATE IS NULL
	OR SALE_TIME IS NULL
	OR CUSTOMER_ID IS NULL
	OR GENDER IS NULL
	OR AGE IS NULL
	OR CATEGORY IS NULL
	OR QUANTITY IS NULL
	OR PRICE_PER_UNIT IS NULL
	OR COGS IS NULL
	OR TOTAL_SALE IS NULL;

-- fill age column null value with average age value
SELECT
	ROUND(AVG(AGE))
FROM
	SALES_DATA
WHERE
	AGE IS NOT NULL;

-- update age column with null values
UPDATE SALES_DATA
SET
	AGE = (
		SELECT
			ROUND(AVG(AGE))
		FROM
			SALES_DATA
		WHERE
			AGE IS NOT NULL
	)
WHERE
	AGE IS NULL;

-- drop the record with null value
DELETE FROM SALES_DATA
WHERE
	TRANSACTIONS_ID IS NULL
	OR SALE_DATE IS NULL
	OR SALE_TIME IS NULL
	OR CUSTOMER_ID IS NULL
	OR GENDER IS NULL
	OR AGE IS NULL
	OR CATEGORY IS NULL
	OR QUANTITY IS NULL
	OR PRICE_PER_UNIT IS NULL
	OR COGS IS NULL
	OR TOTAL_SALE IS NULL;

-- Data Exploration

-- How many sales we have?
SELECT
	COUNT(*) AS TOTAL_SALES
FROM
	SALES_DATA;

-- What is the total sales amount?
SELECT
	SUM(TOTAL_SALE) AS TOTAL_SALE
FROM
	SALES_DATA;

-- What is the average sale value per transaction?
SELECT
	AVG(TOTAL_SALE) AS AVG_SALE_PER_TRANSACTION
FROM
	SALES_DATA;

-- how many unique customer we have?
SELECT
	COUNT(DISTINCT (CUSTOMER_ID)) AS TOTAL_CUSTOMER
FROM
	SALES_DATA;

-- how many category we have?
SELECT DISTINCT
	CATEGORY
FROM
	SALES_DATA;

-- Data Analysis & Business problem
-- Write a SQL query to retrieve all columns for sales made on '2022-11-05:
SELECT
	*
FROM
	SALES_DATA
WHERE
	SALE_DATE = '2022-11-05';

-- Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 4 in the month of Nov-2022:
SELECT
	*
FROM
	SALES_DATA
WHERE
	CATEGORY = 'Clothing'
	AND QUANTITY >= 4
	AND TO_CHAR(SALE_DATE, 'YYYY-MM') = '2022-11';

-- Write a SQL query to calculate the total sales (total_sale) for each category.:
SELECT
	CATEGORY,
	SUM(TOTAL_SALE) AS TOTAL_SALES,
	COUNT(*) AS TOTAL_ORDER
FROM
	SALES_DATA
GROUP BY
	CATEGORY;

-- Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.:
SELECT
	ROUND(AVG(AGE), 2) AS AVG_GE
FROM
	SALES_DATA
WHERE
	CATEGORY = 'Beauty';

-- Write a SQL query to find all transactions where the total_sale is greater than 1000.:
SELECT
	*
FROM
	SALES_DATA
WHERE
	TOTAL_SALE > 1000;

-- Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.:
SELECT
	CATEGORY,
	GENDER,
	COUNT(*) AS TOTAL
FROM
	SALES_DATA
GROUP BY
	CATEGORY,
	GENDER
ORDER BY
	1;

-- Write a SQL query to calculate the average sale for each month. Find out best selling month in each year:
SELECT
	YEAR,
	MONTH,
	AVG_SALE
FROM
	(
		SELECT
			EXTRACT(
				YEAR
				FROM
					SALE_DATE
			) AS YEAR,
			EXTRACT(
				MONTH
				FROM
					SALE_DATE
			) AS MONTH,
			AVG(TOTAL_SALE) AS AVG_SALE,
			RANK() OVER (
				PARTITION BY
					EXTRACT(
						YEAR
						FROM
							SALE_DATE
					)
				ORDER BY
					AVG(TOTAL_SALE) DESC
			) AS RANK
		FROM
			SALES_DATA
		GROUP BY
			1,
			2
	) AS TAB1
WHERE
	RANK = 1;

-- Write a SQL query to find the top 5 customers based on the highest total sales 
SELECT
	CUSTOMER_ID,
	SUM(TOTAL_SALE) AS TOTAL
FROM
	SALES_DATA
GROUP BY
	CUSTOMER_ID
ORDER BY
	TOTAL DESC
LIMIT
	5;

-- Write a SQL query to find the number of unique customers who purchased items from each category.:
SELECT
	CATEGORY,
	COUNT(DISTINCT (CUSTOMER_ID)) AS UNIQUE_CUS
FROM
	SALES_DATA
GROUP BY
	CATEGORY;

-- Write a SQL query to create each shift and number of orders 
-- (Example Morning <12, Afternoon Between 12 & 17, Evening >17):
WITH
	HOURLY_RATE AS (
		SELECT
			*,
			CASE
				WHEN EXTRACT(
					HOUR
					FROM
						SALE_TIME
				) < 12 THEN 'morning'
				WHEN EXTRACT(
					HOUR
					FROM
						SALE_TIME
				) BETWEEN 12 AND 17  THEN 'afternoon'
				ELSE 'evening'
			END AS SHIFT
		FROM
			SALES_DATA
	)
SELECT
	SHIFT,
	COUNT(*) AS TOTAL_ORDERS
FROM
	HOURLY_RATE
GROUP BY
	SHIFT;