 --Data Exploration with SQL
 --query for number of customers in the data
SELECT
   COUNT(DISTINCT customer_id) AS total_customers
 FROM customers
 ;

--The city with the most profit for the company.
 SELECT
   o.shipping_city AS city,
   SUM(od.order_profits) AS profit
 FROM order_details od
 JOIN orders o
   ON od.order_id = o.order_id
 WHERE EXTRACT(YEAR FROM o.order_date) = 2015
 GROUP BY city
 ORDER BY profit DESC
 LIMIT 1;

--Number of uniques (different) cities in the data?

 SELECT
   COUNT(DISTINCT shipping_city) AS unique_cities
 FROM orders
 ;

--The total spent by customers from low to high.

 SELECT
   c.customer_id,
   c.customer_name,
   SUM(od.order_sales) AS total_spent
 FROM customers AS c
 JOIN orders AS o 
   ON c.customer_id = o.customer_id
 JOIN order_details AS od 
   ON o.order_id = od.order_id
 GROUP BY c.customer_id
 ORDER BY total_spent ASC
 ;

 --The most profitable city in the State of Tennessee.
 SELECT
   o.shipping_city AS city,
   SUM(od.order_profits) AS profit
 FROM order_details od
 JOIN orders o
   ON od.order_id = o.order_id
 WHERE o.shipping_state = 'Tennessee'
 GROUP BY city
 ORDER BY profit DESC
 LIMIT 1
 ;

 --The average annual profit for that city (Lebanon) across all years is 27.67.
 
WITH Lebanon_annual_profit AS(
  SELECT
     EXTRACT(YEAR FROM o.order_date) AS years,
     SUM(od.order_profits) AS annual_profit
  FROM order_details od
  JOIN orders o
     ON od.order_id = o.order_id
  WHERE o.shipping_city = 'Lebanon'
  GROUP BY years)


 SELECT
   ROUND(AVG(annual_profit)::numeric,2) AS average_annual_profit
 FROM Lebanon_annual_profit
 ;

 --The distribution of customer types in the data

 SELECT 
  customer_segment,
  COUNT(*) AS dist_customer
 FROM customers
 GROUP BY customer_segment
 ORDER BY dist_customer
 ;

 --The most profitable product category on average in Iowa across all years is Furniture, average_profit = 130.25.
 SELECT
   pr.product_category,
   ROUND(AVG(od.order_profits)::numeric,2) AS average_profit
 FROM product pr
 JOIN order_details od
   ON od.product_id = pr.product_id
 JOIN orders o
   ON o.order_id = od.order_id
 WHERE o.shipping_state = 'Iowa'
 GROUP BY pr.product_category
 ORDER BY average_profit DESC
 LIMIT 1
 ;

--The most popular product in the Furniture category across all states in 2016 is the Global Push Button Manager's Chair, Indigo. 
 
SELECT
   pr.product_name,
   SUM(od.quantity) AS total_products
FROM product pr
JOIN order_details od
   ON od.product_id = pr.product_id
JOIN orders o
   ON o.order_id = od.order_id
WHERE pr.product_category = 'Furniture'
      AND EXTRACT(YEAR FROM o.order_date) = 2016
GROUP BY pr.product_name
ORDER BY total_products DESC
LIMIT 1
;

--Customer with the most discount in the data? (in total amount)
--Customer with customer ID 687  had the highest discount in the data based on the query below.
 SELECT
 c.customer_id,
 SUM((order_sales / (1 - order_discount)) - order_sales) AS total_discount
 FROM
 order_details od
 JOIN orders o ON o.order_id = od.order_id
 JOIN customers c ON o.customer_id = c.customer_id
 GROUP BY c.customer_id
 ORDER BY total_discount DESC
 ;

--How widely did monthly profits vary in 2018?
 
 WITH month_profit AS (
  SELECT
    to_char(order_date, 'MM-YYYY') AS month,
    SUM(order_profits) AS monthly_profit
 FROM order_details od
 JOIN orders o ON od.order_id = o.order_id
 WHERE EXTRACT(YEAR FROM o.order_date) = 2018
 GROUP BY month
 ORDER BY month)


 SELECT *, 
(monthly_profit - LAG(monthly_profit) OVER()) 
   AS month_profit_difference
 FROM month_profit
 ;

--The biggest order regarding sales in 2015?
--The biggest order regarding sales in 2015 is the order with order_id CA-2015-145317.
 
 SELECT
   od.order_id,
   od.order_sales AS biggest_order
 FROM order_details od
 JOIN orders o
   ON od.order_id = o.order_id
 WHERE EXTRACT(YEAR FROM o.order_date) = 2015
 ORDER BY biggest_order DESC
 LIMIT 1
 ;

--14. The rank of each city in the East region in 2015 in quantity?
 
 WITH total_quantity AS (
  SELECT
     shipping_city,
     SUM(quantity) AS total_quantity
  FROM orders o
  JOIN order_details od 
    ON o.order_id = od.order_id
  WHERE EXTRACT(YEAR FROM order_date) = 2015
        AND shipping_region = 'East'
  GROUP BY shipping_city)
 
 SELECT
   shipping_city,
   DENSE_RANK() OVER(ORDER BY total_quantity DESC) AS rank
 FROM total_quantity
 ;

 --15. Display customer names for customers who are in the segment ‘Consumer’ or ‘Corporate.’ How many customers are there in total?
 SELECT
   DISTINCT customer_name,
   customer_segment,
   (SELECT COUNT(*)
    FROM customers
    WHERE customer_segment IN ('Consumer', 'Corporate')) AS total_number
 FROM customers
 WHERE customer_segment IN ('Consumer', 'Corporate')
 ORDER BY customer_name ASC
 ;

--The difference between the largest and smallest order quantities for product id ‘100.’
 
 SELECT 
   MAX(quantity) - MIN(quantity) AS quantity_diff
 FROM order_details
 WHERE product_id = 100
 ;

--The percentage of products that are within the category ‘Furniture’ is 20.54 .
 
 SELECT 
   ROUND(((SELECT COUNT(*)FROM product
   WHERE product_category = 'Furniture')*1.0)/COUNT(*) *100, 2)   
AS perc_furniture
 FROM product
 ;

--The number of product manufacturers with more than 1 product in the product table. 
--There are 169 manufacturers with more than 1 product. 
 WITH product_manufacturers AS (
   SELECT
      product_manufacturer,
      COUNT(DISTINCT product_id) AS total_products_per_manufacturer
   FROM product
   GROUP BY product_manufacturer
 )
 SELECT
   COUNT(product_manufacturer) AS total_manufacturers
 FROM product_manufacturers
 WHERE total_products_per_manufacturer > 1
 ;

--Show the product_subcategory and the total number of products in the subcategory. Show the order from most to least products and then by product_subcategory name ascending.
 SELECT 
   product_subcategory, 
   COUNT(DISTINCT product_id) AS num_products
 FROM product
 GROUP BY product_subcategory
 ORDER BY num_products DESC, 
    product_subcategory ASC 
 ;

--Show the product_id(s), the sum of quantities, where the total sum of its product quantities is greater than or equal to 100.
 SELECT 
   product_id, 
   SUM(quantity) AS total_quantity
 FROM order_details
 GROUP BY product_id
 HAVING SUM(quantity) >= 100
 ;





