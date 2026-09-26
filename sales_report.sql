---------------- SALES DATA ANALYSIS ----------------
---1. Overall Sales Performance ---
--	What is the total sales revenue?
SELECT SUM(sales_amount) as total_sales
from sales_transaction;
--  What is the total profit?
SELECT SUM(profit) as total_profit
from sales_transaction;
-- How many orders were generated?
SELECT count(transaction_id) as total_order
from sales_transaction;
-- How many customers purchased?
SELECT COUNT(distinct customer_id)AS TOTAL_CUSTOMER
FROM sales_transaction;
--	How many units were sold?
SELECT SUM(Quantity) AS Total_units_sold
FROM sales_transaction;
--	What is the average order value?
SELECT round(AVG(sales_amount),2) AS Average_order_value
from sales_transaction;
-- What is the overall profit margin?
SELECT round((sum(profit)/sum(sales_amount))*100,2)
             as overall_profit_margin
from sales_transaction;

----B. Monthly & Yearly Trends----
--	What are the monthly sales trends?
SELECT datename (MONTH,Transaction_date) AS sales_month,
sum(sales_amount) as Monthly_sales
from sales_transaction
group by datename (MONTH,Transaction_date)
order by sales_month;
-- 	What are the yearly sales trends?
SELECT DATENAME (YEAR , Transaction_date) as year_month,
sum(sales_amount) as yearly_sales
from sales_transaction
GROUP BY DATENAME (YEAR , Transaction_date)
ORDER BY yearly_sales;
--	Which month has the highest sales?
SELECT datename (MONTH,Transaction_date) AS Monthly,
MAX(SALES_AMOUNT) AS HIGHEST_SALES
FROM sales_transaction
GROUP BY datename (MONTH,Transaction_date) 
ORDER BY Monthly;
--  Which month has the lowest sales?
SELECT datename (MONTH,Transaction_date) AS Monthly,
MIN(SALES_AMOUNT) AS LOWEST_SALES
FROM sales_transaction
GROUP BY datename (MONTH,Transaction_date) 
ORDER BY Monthly;
--	Are sales growing year over year?
WITH yearly_sales AS 
( 
SELECT
YEAR(transaction_date) AS sales_year , 
SUM (sales_amount) AS Total_sales
FROM sales_transaction
GROUP BY YEAR(Transaction_date)
)
SELECT sales_year,
total_sales,
LAG(total_sales) over (order by sales_year) as previous_year_sales,
total_sales - LAG(TOTAL_SALES)OVER(ORDER BY sales_year) as sales_growth
from yearly_sales
order by sales_year;
--	Which months show seasonal patterns?
WITH Monthly_sales AS 
( 
  SELECT 
  YEAR(Transaction_date) AS sales_year,
  MONTH(Transaction_date) AS Month_Number,
  DATENAME(MONTH, Transaction_date) AS Month_name,
  SUM(sales_amount) as total_sales
  FROM sales_transaction
  GROUP BY 
  YEAR(Transaction_date),
  MONTH(Transaction_date) ,
  DATENAME(MONTH, Transaction_date) 
  )
SELECT* FROM Monthly_sales
order by sales_year ,
           Month_Number;
--	Is profit growing at the same rate as sales?
WITH yearly_sales AS 
( 
SELECT
YEAR(transaction_date) AS sales_year , 
SUM (sales_amount) AS Total_sales,
SUM(Profit) as Total_Profit
FROM sales_transaction
GROUP BY YEAR(Transaction_date)
)
SELECT sales_year,
       Total_sales,
       Total_profit,
LAG(total_sales)over(order by sales_year) as previous_year_sales,
LAG(total_profit) over(order by sales_year) as previous_year_profit,
ROUND(
((total_sales - LAG(total_sales)over(order by sales_year) )/ Nullif
(LAG(total_sales)over(order by sales_year) ,0))*100,2) 
as sales_growth_precent,
ROUND(
((total_profit - LAG(total_profit) over(order by sales_year))/ nullif
(LAG(total_profit) over(order by sales_year) ,0))*100 ,2)
as profit_growth_percent
from yearly_sales
order by sales_year;

----------C. Regional Performance--------
--	Which region generates the highest revenue?
WITH Region_Revenue AS
(
SELECT
       r.region_name,
       SUM(st.sales_amount) AS Total_Revenue
 FROM sales_transaction AS st
JOIN region AS r
on st.region_id=r.region_id
group by 
      r.region_name
)
SELECT 
region_name,
total_revenue,
rank() over(order by total_revenue desc ) as revenue_rank
from region_revenue
order by revenue_rank;
--	Which region generates the highest profit?
WITH Region_Revenue AS
(
SELECT
       r.region_name,
       SUM(st.profit) AS Total_profit
 FROM sales_transaction AS st
JOIN region AS r
on st.region_id=r.region_id
group by 
      r.region_name
)
SELECT 
region_name,
Total_profit,
rank() over(order by total_profit desc ) as revenue_rank
from region_revenue
order by revenue_rank;
--	Which region has the best profit margin?
WITH Profit_margin  AS
(
SELECT r.region_name , sum(st.sales_amount)AS Total_sales,sum(st.profit) as total_profit
FROM Region AS r
inner join sales_transaction as st
on r.region_id = st.region_id
group by r.region_name
)
SELECT
region_name,
(Total_profit / Total_sales) * 100 as profit_margin,
rank () over(order by profit_margin desc) as rank
from Profit_margin
-------D. Product Performance----------
--	Which products sell the most?
SELECT p.product_name , count(st.product_id) as qty_sell
from Product AS p
inner join sales_transaction as st
on p.product_id = st.product_id
group by p.product_name
order by qty_sell desc ;
--•	Which products generate the most revenue?
SELECT p.product_name , sum(st.sales_amount) as highest_revenue
from Product as p 
inner join sales_transaction as st
on p.product_id = st.product_id
group by p.product_name
order by highest_revenue desc ;
--	Which products generate the most profit?
SELECT p.product_name , sum(st.profit) as highest_profit
from Product as p 
inner join sales_transaction as st
on p.product_id = st.product_id
group by p.product_name
order by highest_profit desc;
--•	Which categories perform best?
SELECT p.category , sum(st.sales_amount) as sales
FROM Product as p 
inner join sales_transaction as st
on p.product_id = st.product_id
group by p.category
order by sales desc;
--	Which products have high sales but low profit?
SELECT top 1 p.product_name , max(st.sales_amount) as high_sales , min(st.profit) as low_profit
from Product as p 
 inner join sales_transaction as st
 on p.product_id = st.product_id
 group by p.product_name
 --  Which products have low sales but high margins?
 WITH Product_Ananlysis AS 
 (
 SELECT p.product_name ,
 SUM(st.sales_amount) AS Total_sales,
 SUM(st.profit) as Total_profit,
 ROUND(
      SUM(st.profit)* 100.0/
      NULLIF(SUM(sales_amount),0),2) AS Profit_Margin
FROM sales_transaction as st
inner join product as p
on p.product_id=st.product_id
group by p.product_name)
SELECT product_name ,
Total_sales ,
Total_profit,
ROUND(profit_Margin , 2) AS Profit_Margin 
from Product_Ananlysis
where Total_sales<(select avg(total_sales)from Product_Ananlysis) and
profit_margin > (select avg(profit_margin) from Product_Ananlysis)
order by Profit_Margin desc;

----------Customer Analysis----------
--	How many active customers do we have?
SELECT COUNT(DISTINCT customer_id)
FROM sales_transaction;
-- Who are our top customers?
SELECT C.CUSTOMER_NAME , SUM(ST.sales_amount) AS TOTAL_SALES
FROM Customer AS C
INNER JOIN sales_transaction AS ST
ON C.customer_id=ST.customer_id
GROUP BY C.customer_name
ORDER BY TOTAL_SALES DESC;
--	Which customer segment generates the most revenue?
SELECT c.CustomerSegment , sum(s.sales_amount) as sales_revenue
FROM Customer AS c
inner join sales_transaction as s
on c.customer_id = s.customer_id
GROUP BY c.CustomerSegment
ORDER BY sales_revenue DESC;
--•	Which customers generate the most profit?
SELECT C.customer_name , sum(st.profit) as profit
from Customer as C
inner join sales_transaction as st
on C.customer_id= st.customer_id
group by C.customer_name
order by profit desc;
--	What is the average customer spending?
SELECT C.customer_name , AVG(ST.sales_amount) as avg_spending
FROM Customer as C
inner join sales_transaction as ST
on C.customer_id= st.customer_id
group by C.customer_name;
--	How frequently do customers purchase?
SELECT  c.customer_id , count(st.transaction_id) as purchase
FROM customer as c
inner join sales_transaction as st
on c.customer_id = st.customer_id
GROUP BY c.customer_id
ORDER BY purchase desc ;
--•	Which customer segments are growing?
WITH Segmentsales AS
(SELECT c.customersegment,
        DATENAME(year , st.transaction_date) as sales_year,
        SUM(st.sales_amount) as total_sales
FROM sales_transaction AS st
inner join customer as c
on c.customer_id = st.customer_id
GROUP BY c.CustomerSegment,
 DATENAME(year , st.transaction_date)),
 Growth as 
 ( SELECT customersegment,
 sales_year,
 total_sales,
 LAG(total_sales) over 
 ( partition by customersegment
 order by sales_year) as previousyearsales
 from Segmentsales)
 SELECT customersegment, sales_year,
 total_sales ,previousyearsales,
 total_sales - previousyearsales as salesgrowth
 from Growth
 WHERE previousyearsales is not null
 order by salesgrowth desc;
-----------. Salesperson Performance -------------
--	Which salesperson generates the highest sales?
SELECT s.salesperson_name , SUM(st.sales_amount) AS HIGHEST_SALES
FROM Sales_person as s
INNER JOIN sales_transaction AS st
on s.salesperson_id = st.salesperson_id
group by s.salesperson_name
order by HIGHEST_SALES desc ; 
--•	Who generates the highest profit?
SELECT s.salesperson_name , SUM(st.profit) AS HIGHEST_PROFIT
FROM Sales_person as s
INNER JOIN sales_transaction AS st
on s.salesperson_id = st.salesperson_id
group by s.salesperson_name
order by HIGHEST_PROFIT desc ; 
--	Who has the highest number of orders?
SELECT s.salesperson_name , COUNT(st.Transaction_ID) AS ORDER_NUMBER
FROM Sales_person as s
INNER JOIN sales_transaction AS st
on s.salesperson_id = st.salesperson_id
group by s.salesperson_name
order by ORDER_NUMBER desc;
--•	Which salesperson has the best profit margin?
WITH best_Profit_margin  AS
(
SELECT s.salesperson_name , sum(st.sales_amount)AS Total_sales,sum(st.profit) as total_profit
FROM Sales_person AS s
inner join sales_transaction as st
on  s.salesperson_id = st.salesperson_id
group by s.salesperson_name
)
SELECT
salesperson_name,
(Total_profit / Total_sales) * 100 as Profit_margin,
rank () over(order by Profit_margin desc) as rank
from best_Profit_margin
--•	Which region/salesperson combination performs best?
SELECT r.region_name , s.salesperson_name ,SUM(st.sales_amount) as Total_sales ,SUM(st.profit) as Total_profit
FROM Region AS r 
inner join Sales_person as s
on r.region_id = s.region_id
inner join sales_transaction as st
on s.salesperson_id = st.salesperson_id
GROUP BY r.region_name,
s.salesperson_name
ORDER BY Total_sales desc
, Total_profit desc;
----------------5. Discount Analysis-----------
--•	How much discount is being given?
SELECT ROUND(AVG(DISCOUNT),2) AS Average_Discount
from sales_transaction
--•	Does higher discount result in higher sales?
SELECT max(sales_amount) as higher_sales, max(discount) as higher_discount
from sales_transaction
--•	Does discount reduce profitability?
SELECT discount,
SUM(sales_amount) as Total_sales,
SUM(profit) as total_profit,
ROUND(SUM(PROFIT)* 100.0/
NULLIF (SUM(sales_amount),0),2
) as profit_margin
from sales_transaction
group by Discount
order by Discount;
--•	Which products receive the highest discounts?
SELECT p.product_name , max(st.discount) as highest_discount
from Product as p
inner join sales_transaction as st
on p.product_id = st.product_id
group by p.product_name
order by highest_discount desc;
--•	Which regions provide the most discounts?
SELECT r.region_name , max(st.discount) as high_discount
from Region as r
inner join sales_transaction as st
on r.region_id = st.region_id
group by r.region_name
order by high_discount desc ;
------------Profitability Analysis---------------
--•	Which products are most profitable?
SELECT TOP 1 P.product_name , sum(st.profit) as profitable
from Product as P
inner join sales_transaction as st
on P.product_id = st.product_id
group by p.product_name
order by profitable desc;
--•	Which categories are most profitable?
SELECT TOP 1 P.category , sum(st.profit) as profitable
from Product as P
inner join sales_transaction as st
on P.product_id = st.product_id
group by p.category
order by profitable desc;
--•	Which regions are most profitable?
SELECT TOP 1 r.region_name , sum(st.profit) as profitable
from Region as r
inner join sales_transaction as st
on r.region_id = st.region_id
group by r.region_name
order by profitable desc;
--•	Which customers generate the highest profit?
SELECT top 1 c.customer_name , max(st.profit) as highest_profit
FROM Customer AS c
INNER JOIN sales_transaction AS st
on c.customer_id = st.customer_id
group by c.customer_name
order by highest_profit desc ;
--•	Which salespeople generate the highest profit?
SELECT top 1 s.salesperson_name , max(st.profit) as highest_profit
FROM Sales_person AS s
INNER JOIN sales_transaction AS st
on s.salesperson_id = st.salesperson_id
group by s.salesperson_name 
order by highest_profit desc;
--•	Where are sales high but margins low?
SELECT
    r.region_name,
    SUM(st.sales_amount) AS Total_Sales,
    SUM(st.profit) AS Total_Profit,
    ROUND(
        SUM(st.profit) * 100.0 /
        NULLIF(SUM(st.sales_amount), 0), 2
    ) AS Profit_Margin
FROM Region r
INNER JOIN Sales_Transaction st
    ON r.region_id = st.region_id
GROUP BY r.region_name
ORDER BY Total_Sales DESC;