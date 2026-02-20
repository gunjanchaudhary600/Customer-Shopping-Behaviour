select * from customer limit 20;

--1. What is the total revenue genrated by male vs female customer?
select gender, sum("purchase_amount_(usd)") as revenue
from customer
group by gender; 

--2. Which customers used a discount but still spent more than the averarage purchase amount?
select customer_id, "purchase_amount_(usd)"
from customer
where discount_applied = 'Yes' and "purchase_amount_(usd)" >= (select avg("purchase_amount_(usd)") 
from customer)

--3. Which are the top 5 products with the highest average review rating?
select item_purchased, ROUND(avg(review_rating::numeric),2) as "average product rating"
from customer
group by item_purchased
order by avg(review_rating) desc
limit 5;

--4. Compare the average purchase amounts between standard and express shipping.
select shipping_type, 
ROUND(avg("purchase_amount_(usd)"),2)
from customer 
where shipping_type in ('Standard','Express')
group by shipping_type;

--5. Do subscribed customers spend more? Campare average spend and total revenue between subscribers and non-subscribers.
select subscription_status,
count(customer_id) as total_customers,
ROUND(avg("purchase_amount_(usd)"),2) as avg_spend,
ROUND(sum("purchase_amount_(usd)"),2) as total_revenue
from customer
group by subscription_status
order by total_revenue, avg_spend desc

--6. Which 5 products have the highest percentage of purchase with discounts applied?
select item_purchased,
round(100 * sum(case when discount_applied = 'Yes' then 1 else 0 end)/count(*),2) as discount_rate
from customer
group by item_purchased
order by discount_rate desc
limit 5;

--7. Segment customers into New, Returning, and Loyal based on their total number of previous purchase, and show the count of each segment.
with customer_type as (
select customer_id, previous_purchases,
case 
	when previous_purchases = 1 then 'New'
	when previous_purchases between 2 and 10 then 'Returning'
	else 'Loyal'
	end as customer_segment
from customer
)
select customer_segment, count(*) as "Number of Customers"
from customer_type
group by customer_segment;

--8. What are the top 3 most purchased products within each category?
with item_counts as (
select category,
item_purchased,
count(customer_id) as total_orders,
row_number() over(partition by category order by count(customer_id) desc) as item_rank 
from customer
group by category, item_purchased
)
select item_rank, category, item_purchased, total_orders
from item_counts
where item_rank <= 3;

--9. Are customers who are repeat buyers (more than 5 previous purchases) also likely to subscribe?
select subscription_status,
count(customer_id) as repeat_buyers
from customer
where previous_purchases > 5
group by subscription_status;

--10. What is the revenue contribution of each age group?
select age_group,
sum("purchase_amount_(usd)") as total_revenue
from customer 
group by age_group
order by total_revenue desc;