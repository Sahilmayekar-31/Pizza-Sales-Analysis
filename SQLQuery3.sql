-- Basic

-- Retrieve the total number of orders placed.

select count(order_id) as Total_Orders 
from orders;

-- Calculate the total revenue generated from pizza sale

select round(sum(od.quantity * p.price),2)
as Total_Repvenue 
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id;


-- Identify the highest-priced pizza.
	select PT.name, round(p.price,2)  as price
	from pizza_types as PT
	join pizzas as p
	on PT.pizza_type_id = p.pizza_type_id
	where p.price =(Select max(price) from pizzas);

-- Identify the most common pizza size ordered.
select p.size, count(order_details_id) as count_order
from pizzas as p
join order_details as od
on p.pizza_id = od.pizza_id
group by P.size;

-- List the top 5 most ordered pizza types along with their quantities.
select pt.name, sum(quantity) as total_Quantity 
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on p.pizza_id = od.pizza_id
group by name
order by total_Quantity desc
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

---- Intermediate

-- Join the necessary tables to find the total quantity of each pizza category ordered.

select category,sum(quantity)as Total_Quantity
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as pd
on p.pizza_id = pd.pizza_id
group by category;

-- Determine the distribution of orders by hour of the day.

select datepart(hour,order_time) as hour,
count(order_id) as "count of Order"
from orders
group by datepart(hour,order_time)
order by hour;

-- Join relevant tables to find the category-wise distribution of pizzas.
select category,count(name) as types
from pizza_types
group by category;

-- Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT ROUND(AVG(quantity),0) AS avg_daily_quantity
FROM (SELECT o.order_date,SUM(od.quantity) AS quantity
FROM orders as o
JOIN order_details as od 
ON o.order_id = od.order_id
GROUP BY o.order_date
) AS order_quantity;

-- Determine the top 3 most ordered pizza types based on revenue.
select pt.name,
sum(quantity*price)as total_revenue
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by name
order by total_revenue desc
offset 0 rows fetch next 3 rows only;

------ Advanced 
-- Calculate the percentage contribution of each pizza type to total revenue.

select pt.category,
round((sum(quantity*price)/(select round(sum(od.quantity * p.price),2)
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id))*100,2) as Total_Revenue
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id
join pizza_types as pt
on p.pizza_type_id = pt.pizza_type_id
group by category
order by Total_Revenue desc;

-- Analyze the cumulative revenue generated over time.
select order_date,
round(sum(revenue) over(order by order_date),2)as cum_revenue
from (select o.order_date,
sum(od.quantity * p.price) as revenue
from order_details as od
join pizzas as p
on od.pizza_id = p.pizza_id 
join orders as o
on o.order_id = od.order_id  
group by o.order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category, name , 
revenue from 
(select category, name , revenue, 
rank() over (partition by category order by revenue desc) as Rank
from (select pt.category, pt.name, sum(od.quantity * p.price) as revenue
from pizza_types as pt
join pizzas as p
on pt.pizza_type_id = p.pizza_type_id
join order_details as od
on od.pizza_id = p.pizza_id
group by pt.category, pt.name) as a) as b
where Rank <=3;
