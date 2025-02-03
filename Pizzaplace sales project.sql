CREATE DATABASE Pizzadb;

---Import the cv files into ssms tables 
---How many customers do we have each day ? 
SELECT 
COUNT(DISTINCT order_id) AS num_customers,
date
FROM dbo.orders 
GROUP BY date
ORDER BY 2
  
--- Are there any peak hours?
SELECT 
COUNT(DISTINCT order_id) AS num_orders,
DATEPART(hour,time) AS hour_slot
FROM dbo.orders 
GROUP BY DATEPART(hour,time)
ORDER BY num_orders DESC

---How many pizzas are typically in an order?Do we have any bestsellers?
SELECT COUNT(OD.quantity) AS num_pizzas,AVG(OD.quantity) AS Avg_pizzas,P.pizza_type_id
FROM order_details OD
JOIN pizzas P
ON OD.pizza_id =P.pizza_id
GROUP BY OD.order_id,P.pizza_type_id

---Do we have any bestsellers?
SELECT P.pizza_type_id,P.size,SUM(OD.quantity)AS total_quantity
FROM order_details OD
JOIN pizzas P
ON OD.pizza_id =P.pizza_id
GROUP BY P.pizza_type_id,P.size
ORDER BY total_quantity DESC

---How much money did we make this year?Can we identify any seasonality in the sales?
---We can identify the seasonality by changes in revenue over months

 SELECT YEAR(date) AS year, MONTH(date) AS month, SUM(P.price * OD.quantity) AS revenue
FROM orders O
JOIN order_details OD ON O.order_id = OD.order_id
JOIN pizzas P ON OD.pizza_id = P.pizza_id
WHERE YEAR(date) = 2015
GROUP BY YEAR(date), MONTH(date)
ORDER BY YEAR(date), MONTH(date)

---To find total revenue we eliminate the month column in the above query
 SELECT YEAR(date) AS year,
 SUM(P.price * OD.quantity) AS revenue
FROM orders O
JOIN order_details OD ON O.order_id = OD.order_id
JOIN pizzas P ON OD.pizza_id = P.pizza_id
WHERE YEAR(date) = 2015
GROUP BY YEAR(date)
ORDER BY YEAR(date)

---Are there any pizzas we should take of the menu or any promotions we could leverage?
---We find the least popular pizzas by order this maybe candidates for removal
---This query calculates the number of orders for each pizza type and sorts the results in ascending order.
---The pizzas at the TOP of the list have the lowest number of orders and may be candidates for removal from the menu.
SELECT P.pizza_id, P.pizza_type_id, COUNT(OD.order_details_id) AS num_orders
FROM order_details OD
JOIN pizzas P ON OD.pizza_id = P.pizza_id
GROUP BY P.pizza_id, P.pizza_type_id
ORDER BY num_orders ASC

---To identify pizzas that are particularly profitable and could be leveraged for promotions, we can use the following query:
---This query calculates the average prize, total quantity sold, and total revenue generated for each pizza type and sorts the results in descending order of revenue.
---The pizzas at the top of the list have high revenue and may be good candidates for promotions or upselling.
SELECT P.pizza_type_id, AVG(P.price) AS avg_price, SUM(OD.quantity) AS total_quantity,
SUM(P.price * OD.quantity) AS total_revenue
FROM order_details OD
JOIN pizzas P ON OD.pizza_id = P.pizza_id
GROUP BY P.pizza_type_id
ORDER BY total_revenue DESC
