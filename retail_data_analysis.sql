ALTER TABLE retail_cleaned MODIFY order_id VARCHAR(20);
ALTER TABLE retail_cleaned MODIFY order_date DATE;
ALTER TABLE retail_cleaned MODIFY ship_mode VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY segment VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY country VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY city VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY state VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY postal_code VARCHAR(20);
ALTER TABLE retail_cleaned MODIFY region VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY category VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY sub_category VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY product_id VARCHAR(50);
ALTER TABLE retail_cleaned MODIFY cost_price DECIMAL(10,2);
ALTER TABLE retail_cleaned MODIFY list_price DECIMAL(10,2);
ALTER TABLE retail_cleaned MODIFY quantity INT;
ALTER TABLE retail_cleaned MODIFY discount_percent DECIMAL(5,2);
ALTER TABLE retail_cleaned MODIFY revenue DECIMAL(12,2);
ALTER TABLE retail_cleaned MODIFY discount_amount DECIMAL(12,2);
ALTER TABLE retail_cleaned MODIFY selling_price DECIMAL(12,2);

alter table retail_cleaned modify profit decimal(12,2);

select count(*) as total_rows
from retail_cleaned;

select min(order_date) as start_date,
max(order_date) as end_date
from retail_cleaned;

select order_id,count(*) as cnt 
from retail_cleaned
group by order_id 
having cnt>1;

select
sum(order_id  is null) as null_order_id,
sum(order_date is null) as null_order_date,
sum(region is null) as null_region,
sum(category is null) as null_category,
sum(quantity is null) as null_quantity,
sum(revenue is null) as null_revenue,
sum(profit is null) as null_profit
from retail_cleaned;


select 
order_id,
list_price*quantity as expected_revenue,
revenue,
selling_price*quantity-cost_price*quantity as expected_profit,
profit
from retail_cleaned
limit 20;

create or replace view sales_monthly as 
select 
year(order_date) as year,
month(order_date) as month,
sum(revenue) as total_revenue,
sum(profit) as total_profit,
count(distinct order_id) as total_orders
from retail_cleaned
group by year(order_date),month(order_date)
order by year,month;

select*from sales_monthly;

create or replace view sales_category as 
select
 category,
 sub_category,
 sum(revenue) as total_revenue,
 sum(profit) as total_profit,
 round(sum(profit)/nullif(sum(revenue),0)*100,2)as profit_margin_pct
 from retail_cleaned
 group by category,sub_category
 order by total_revenue desc;
 
 select * from sales_category;
 
 create or replace view sales_region as 
 select
 region, country,state,
 sum(revenue) as total_revenue,
 sum(profit) as total_profit,
 count(distinct order_id) as total_orders
 from retail_cleaned
 group by region,country,state
 order by total_revenue desc;
 
 select *from sales_region;
 
 create or replace view top_products as 
 select 
 product_id,
 category,
 sub_category,
 sum(quantity) as total_quantity,
 sum(revenue) as total_revenue,
 sum(profit) as total_profit
 from retail_cleaned
 group by product_id,category,sub_category
 order by total_revenue desc
 limit 10;
 
 select* from top_products;
 
 # kpi profit margin %
 
create or replace view kpi_profit_margin as 
select
year(order_date) as year,
month(order_date) as month,
sum(revenue) as total_revenue,
sum(profit) as total_profit,
round(sum(profit)/nullif(sum(revenue),0)*100,2) as profit_margin_pct
from retail_cleaned
group by year(order_date),month(order_date)
order by year,month;

select*from kpi_profit_margin;

##kpi discount impact

create or replace view kpi_discount_impact as 
select 
year(order_date) as year,
month(order_date) as month,
sum(list_price*quantity) as gross_revenue,
sum(selling_price*quantity) as net_revenue,
sum(greatest(list_price-selling_price,0)*quantity) as discount_amount,
round((sum(greatest(list_price-selling_price,0)*quantity)/nullif(sum(list_price*quantity),0))*100,2)*100 as discount_pct
from retail_cleaned
group by year(order_date),month(order_date)
order by year,month;

select*from kpi_discount_impact;

create or replace view kpi_monthly_growth as 
select 
year,
month,
total_revenue,
lag(total_revenue) over ( order by year,month) as prev_revenue,
round((total_revenue-lag(total_revenue) over(order by year,month))/
nullif(lag(total_revenue) over(order by year,month),0)*100,2) as mom_growth_pct 
from(
select
year(order_date) as year,
month(order_date) as month,
sum(revenue) as total_revenue
from retail_cleaned
group by year(order_date),month(order_date))t;

select*from kpi_monthly_growth;

