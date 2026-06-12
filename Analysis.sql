SELECT * FROM sales LIMIT 10;

-- SQL Queries to Include:

-- Basic KPIs:
-- Total Revenue:
SELECT 
	ROUND(SUM(revenue),2) AS total_revenue
FROM sales

-- Total Orders:
SELECT 
	COUNT(DISTINCT Invoice) AS total_orders
FROM sales

-- Total Customers:
SELECT 
	COUNT(DISTINCT customer_id) AS total_orders
FROM sales

-- Time Analysis:
-- Monthly Revenue Trend:
SELECT 
	DATE_TRUNC('MONTH',invoice_date)::DATE AS months,
	SUM(revenue) AS total_revenue
FROM sales
GROUP BY DATE_TRUNC('MONTH',invoice_date)
ORDER BY total_revenue DESC;

-- Monthly Order Trend:
SELECT 
	DATE_TRUNC('MONTH',invoice_date)::DATE AS months,
	COUNT(DISTINCT invoice) AS total_orders
FROM sales
GROUP BY DATE_TRUNC('MONTH',invoice_date)
ORDER BY total_orders DESC;

-- Product Analysis:
-- Top 10 Products by Revenue:
SELECT 
	description,
	SUM(revenue) AS total_revenue
FROM sales
GROUP BY description
ORDER BY total_revenue DESC
LIMIT 10

-- Top 10 Products by Quantity:
SELECT 
	description,
	SUM(quantity) AS total_quantity
FROM sales
GROUP BY description
ORDER BY total_quantity DESC
LIMIT 10

-- Customer Analysis:
-- Top 10 Customers by Revenue:
SELECT 
	customer_id,
	SUM(revenue) AS total_revenue
FROM sales
GROUP BY customer_id
ORDER BY total_revenue DESC
LIMIT 10

-- Repeat Customers:
SELECT
	COUNT(*) AS repeat_customer
FROM 
(SELECT 
	customer_id
FROM sales
GROUP BY customer_id
HAVING COUNT(DISTINCT invoice)>1) t

-- Average Order Value:
SELECT
    ROUND(
        SUM(revenue) / COUNT(DISTINCT invoice),
        2
    ) AS average_order_value
FROM sales;

-- Geography:
-- Revenue by Country:
SELECT
	country,
	SUM(revenue) AS total_revenue
FROM sales
GROUP BY country
ORDER BY total_revenue DESC

-- Orders by Country:
SELECT
	country,
	COUNT(invoice) AS total_orders
FROM sales
GROUP BY country
ORDER BY total_orders DESC

-- Advanced:
-- Revenue Contribution by Country (%):
SELECT
	country,
	SUM(revenue) AS total_revenue,
	ROUND(SUM(revenue)*100 / SUM(SUM(revenue)) OVER(),2) AS pct_revenue
FROM sales
GROUP BY country

-- Customer Revenue Ranking (RANK()):
WITH CTE AS (
SELECT 
	customer_id,
	SUM(revenue) AS total_revenue
FROM sales 
GROUP BY customer_id
)
SELECT 
	*,
	RANK() OVER(ORDER BY total_revenue DESC)
FROM CTE

-- Monthly Growth Rate (LAG()):
WITH monthly_rate AS(
SELECT 
	DATE_TRUNC('MONTH',invoice_date)::date AS current_dt,
	SUM(revenue) AS total_revenue
FROM sales
GROUP BY DATE_TRUNC('MONTH',invoice_date)
)
SELECT 
	current_dt,
	total_revenue,
	LAG(total_revenue) OVER(ORDER BY current_dt) AS previous_revenue,
	ROUND((total_revenue - LAG(total_revenue) OVER(ORDER BY current_dt)) *100 / LAG(total_revenue) OVER(ORDER BY current_dt),2) AS grwth_rate
FROM monthly_rate

