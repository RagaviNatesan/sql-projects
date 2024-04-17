#Retrieve the total number of orders placed.
SELECT COUNT(ORDER_ID) FROM pizzahut.orders;

#Calculate the total revenue generated from pizza sales.
SELECT ROUND(SUM(O.QUANTITY*P.PRICE),2) FROM pizzahut.PIZZAS P,pizzahut.ORDER_DETAILS O
WHERE P.PIZZA_ID=O.PIZZA_ID;

#Identify the highest-priced pizza.
SELECT MAX(PRICE) AS HIGH_PRICE FROM pizzahut.pizzas;

#Identify the most common pizza size ordered.
SELECT P.size,COUNT(O.PIZZA_ID) FROM pizzahut.pizzas P,pizzahut.order_details O
WHERE P.PIZZA_ID=O.PIZZA_ID GROUP BY p.size ORDER BY COUNT(O.PIZZA_ID) desc ;

#List the top 5 most ordered pizza types along with their quantities.
SELECT p.pizza_type_id, COUNT(O.PIZZA_ID),sum(o.quantity) FROM pizzahut.pizzas P,pizzahut.order_details O
WHERE P.PIZZA_ID=O.PIZZA_ID group by  p.pizza_type_id order by COUNT(O.PIZZA_ID) desc limit 5;

#Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT t.category,sum(o.quantity) FROM order_details O,pizza_types T,pizzas p
where p.pizza_id=o.pizza_id and p.pizza_type_id=t.pizza_type_id
group by t.category;

#Determine the distribution of orders by hour of the day
SELECT HOUR(order_time),COUNT(ORDER_ID) FROM ORDERS
GROUP BY HOUR(order_time);

#Join relevant tables to find the category-wise distribution of pizzas.
SELECT CATEGORY,COUNT(NAME) FROM pizza_types GROUP BY CATEGORY;

#Group the orders by date and calculate the average number of pizzas ordered per day
SELECT O.ORDER_DATE,avg(d.quantity)  FROM ORDERS O,order_details d
where o.order_id=d.order_id
group by o.order_date;

#Determine the top 3 most ordered pizza types based on revenue
select t.name,sum(p.price*d.quantity) as total from pizzas p,order_details d,pizza_types t
where p.pizza_id=d.pizza_id and t.pizza_type_id=p.pizza_type_id
group by t.name
order by total desc
limit 3;

#Calculate the percentage contribution of each pizza type to total revenue
select p.pizza_type_id,(sum(p.price*d.quantity)/(
SELECT round(sum(p.price*d.quantity),2)  FROM PIZZAS P,order_details D
where p.pizza_id=d.pizza_id))*100 as per from pizzas p,order_details d
where p.pizza_id=d.pizza_id
group by p.pizza_type_id;

#Analyze the cumulative revenue generated over time.
select order_date,sum(total) over(order by order_date) as cum_sum from
(SELECT o.order_date ,sum(p.price*d.quantity) as total from pizzas p,order_details d,ORDERS O
where p.pizza_id=d.pizza_id and o.order_id=d.order_id
group by o.order_date) as sales;

#Determine the top 3 most ordered pizza types based on revenue for each pizza category.
select category,name,total from (
select category,name,total, rank() over (partition by category order by total) as rnk from (
select t.category,t.name,sum(p.price*d.quantity) as total from pizza_types t,pizzas p,order_details d
where t.pizza_type_id=p.pizza_type_id
and p.pizza_id=d.pizza_id
group by t.category,t.name) as sales) as revenue where rnk<=3
