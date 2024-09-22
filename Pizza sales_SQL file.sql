## Retrive the total number of orders placed.

Select count(order_id) as total_orders from orders;


## Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_sales
FROM
    orders_details
        JOIN
    pizzas ON orders_details.pizza_id = pizzas.pizza_id;


## Identify the highest-priced pizza.
Select pizza_types.name, pizzas.price
from pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
Where price=(select max(price) from pizzas);

#or

Select pizza_types.name, pizzas.price
from pizza_types JOIN pizzas
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
Order by price DESC LIMIT 1;

 
## Identify the most common pizza size ordered.

Select COUNT(orders_details.quantity) AS order_count ,pizzas.size
from orders_details JOIN pizzas
ON orders_details.pizza_id=pizzas.pizza_id
GROUP BY pizzas.size order BY order_count DESC;                                    ##should do group by on the basis of non aggreagateed column



## List the top 5 most ordered pizza types along with their quantities.

Select * from pizza_types;
Select * from orders_details;


	SELECT pizza_types.name,SUM(orders_details.quantity) AS Quantities
	FROM pizza_types 
	JOIN pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
	JOIN orders_details ON orders_details.pizza_id = pizzas.pizza_id
	GROUP BY pizza_types.name
	ORDER BY Quantities DESC
	LIMIT 5;
    
    
    
## Join the necessary tables to find the total quantity of each pizza category ordered.

select * from orders_details;
select * from pizza_types;

select SUM(orders_details.quantity) as Quantity, pizza_types.category
FROM pizza_types
JOIN pizzas ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN orders_details ON orders_details.pizza_id=pizzas.pizza_id
GROUP BY category
order by Quantity DESC;

##  Determine the distribution of orders by hour of the day.

## Select order_id, order_time from orders;

Select count(order_id) as Order_count, hour(order_time) as hour from orders
GROUP BY hour(order_time);



## Join relevant tables to find the category-wise distribution of pizzas.
Select * from pizza_types;
select * from pizzas;
	
select category, COUNT(name) AS Distribution_of_Pizzas from  pizza_types
group by category;



##  Group the orders by date and calculate the average number of pizzas ordered per day.

Select ROUND(avg(quantity),0) as Avg_pizzas_ordered_per_day
from(
select orders.order_date, SUM(orders_details.quantity) as quantity
from orders_details 
JOIN orders
ON orders.order_id=orders_details.order_id
GROUP BY order_date) AS order_quantity;


## Determine the top 3 most ordered pizza types based on revenue.

select pizza_types.name, SUM(orders_details.quantity*pizzas.price) as revenue
from pizza_types
JOIN pizzas
ON  pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id=pizzas.pizza_id
GROUP BY name order by revenue desc LIMIT 3;	


## Calculate the percentage contribution of each pizza type to total revenue.

select pizza_types.category,                                                                    
round(sum(orders_details.quantity*pizzas.price)/                                     ## total reveune = Quantit* price
(select ROUND(SUM(orders_details.quantity*pizzas.price),2) as total_sales
from orders_details JOIN pizzas ON orders_details.pizza_id=pizzas.pizza_id)*100,2) as Cal_revenue    
from pizzas 	
JOIN pizza_types
ON pizza_types.pizza_type_id = pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id=pizzas.pizza_id
GROUP BY category ORDER BY Cal_revenue DESC;


## Analyze the cumulative revenue generated over time.

select order_date, SUM(Revenue) over (order by order_date) as CUM_Revenue
from 
(Select orders.order_date, SUM(orders_details.quantity*pizzas.price) as revenue
from orders_details
JOIN pizzas
ON orders_details.pizza_id = pizzas.pizza_id
JOIN orders
ON orders.order_id = orders_details.order_id 
GROUP BY order_date) as Sales;


## Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select name, revenue, ranke
from
(select category,name, revenue,
rank() over (partition by category order by revenue desc) as ranke
from
(select pizza_types.name,pizza_types.category,SUM(orders_details.quantity*pizzas.price) as revenue
from pizza_types
JOIN pizzas 
ON pizza_types.pizza_type_id=pizzas.pizza_type_id
JOIN orders_details
ON orders_details.pizza_id=pizzas.pizza_id
GROUP BY pizza_types.name,pizza_types.category) as table_1) as table_2
where ranke<=3;