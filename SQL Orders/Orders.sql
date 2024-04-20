Create Table orders.orders
(order_id int,
order_date   date,
ship_mode varchar(255),        
segment varchar(255),      
country varchar(255),      
city varchar(255),        
state  varchar(255),       
postal_code int,        
region varchar(255),       
category varchar(255),        
sub_category varchar(255),        
product_id  varchar(255),        
quantity   int ,      
discount_price float,
sale_price float,      
profit float) ;

SELECT * FROM orders.orders;

#--find top 10 highest reveue generating products
SELECT PRODUCT_ID,SUM(sale_price) AS TOTAL FROM orders.orders 
GROUP BY PRODUCT_ID ORDER BY TOTAL DESC limit 10;

#--find top 5 highest selling products in each region
with cte as (select PRODUCT_ID,region,sum(sale_price) as total from orders.orders
group by PRODUCT_ID,region)
select * from (
SELECT PRODUCT_ID ,region,RANK() OVER(PARTITION BY REGION ORDER BY total desc) AS RNK
FROM cte ) a
where rnk<=5;

#find month over month growth comparison for 2022 and 2023 sales eg : jan 2022 vs jan 2023
with cte as (
SELECT year(order_date) as 'yr' ,month(order_date) as 'order_month' ,round(SUM(sale_price),2) as  sales FROM orders.orders
 GROUP BY year(order_date) ,month(order_date))
 select order_month,sum(case when yr=2022 then sales else 0 end) as sale_2022,
 sum(case when yr=2023 then sales else 0 end) as sale_2023 from cte
 group by order_month
 order by order_month;
 
 #for each category which month had highest sales
 with cte as (
 select category,Month(order_date) order_month,round(sum(sale_price),2) as total from orders.orders
 group by category,order_month)
 select category,order_month,total from
 (select category,order_month,total,rank() over(partition by category order by total desc) as rnk
 from cte) a
 where rnk=1;
 
#which sub category had highest growth by profit in 2023 compare to 2022
with cte as (
select sub_category,year(order_date) order_yr,round(sum(sale_price),2) as profit from orders.orders
group by sub_category,year(order_date))
,cte2 as (
select sub_category,sum(case when order_yr=2023 then profit else 0 end) as profit_23,
sum(case when order_yr=2022 then profit else 0 end) as profit_22 from cte
group by sub_category)
select sub_category,(profit_23-profit_22) from cte2 
order by (profit_23-profit_22) desc
limit 1
