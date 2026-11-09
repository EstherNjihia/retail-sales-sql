-- ============================================================
-- RETAIL SALES & CUSTOMER INTELLIGENCE
-- ============================================================

-- BUSINESS RULES
-- Money calculations use Completed orders only, unless stated otherwise.
-- Revenue = quantity * unit_price * (1 - discount / 100)
-- Cost = quantity * cost_price
-- Profit = revenue - cost
-- Profit margin (%) = profit / NULLIF(revenue, 0) * 100
-- Order counts include all statuses, unless stated otherwise.
-- Customer counts must count distinct customers.
-- "Today" means the latest order_date in the dataset.
-- Monthly analysis must distinguish between years.
-- Round monetary results to two decimal places.


-- ============================================================
-- SECTION A: SQL FUNDAMENTALS (Q1–Q10)
-- ============================================================

-- Q1: Retrieve all customer records.

select *
from customers c;

-- Q2: Display customer names, cities, and segments.

select 
	c.customer_name,
	c.city,
	c.customer_segment 
from customers c;

-- Q3: Find customers living in Nairobi.

select *
from customers c 
where c.city = 'Nairobi';

-- Q4: Find customers registered after January 1, 2025.
select *
from customers c 
where c.registration_date > '2025-01-01';

-- Q5: Display all unique customer cities.
select distinct c.city 
from customers c;

-- Q6: Retrieve the 10 most recent orders.
select *
from orders o 
order by o.order_date desc 
limit 10;

-- Q7: Find orders with unit prices above KSh 10,000.

select *
from orders o 
where o.unit_price > 10000;

-- Q8: Find customers whose names start with A.

select *
from customers c 
where c.customer_name  like 'A%';

-- Q9: Retrieve orders with quantities between 2 and 5.

select *
from orders o  
WHERE o.quantity BETWEEN 2 AND 5;

-- Q10: Find orders paid through M-Pesa.
select *
from orders o 
where o.payment_method = 'M-Pesa';



-- ============================================================
-- SECTION B: AGGREGATION AND GROUPING (Q11–Q20)
-- ============================================================

-- Q11: Count all customers.
select distinct count(*)
from customers c;

-- Q12: Count all orders.
select count(*)
from orders o;

-- Q13: Calculate completed-order revenue.
select
	round(sum(o.quantity * o.unit_price * (1 - o.discount / 100 )),2) as total_revenue
from orders o
where o.order_status = 'Completed';

-- Q14: Calculate the average completed-order value.
select
	round(avg(o.quantity * o.unit_price * (1 - o.discount / 100 )),2) as avg_order_value
from orders o
where o.order_status = 'Completed';

-- Q15: Find the highest and lowest product prices.
select 
	max(o.unit_price) as highest_product_price,
	min(o.unit_price ) as lowest_product_price
from orders o;

-- Q16: Calculate revenue by product category.
select
	o.product_category,
	round(sum(o.quantity * o.unit_price * (1 - o.discount / 100 )),2) as total_revenue
from 
	orders o
where o.order_status = 'Completed'
group by o.product_category;

-- Q17: Count customers by city.
select
	c.city ,
	count(*) as total_customers_count
from 
	customers c 
group by c.city; 

-- Q18: Calculate quantity sold by product.
select 
	o.product_name,
	sum(o.quantity) as units_sold 
from
	orders o 
where o.order_status = 'Completed'  --only from the completed orders
group by o.product_name;

-- Q19: Find categories generating more than KSh 100,000 in revenue.
select
	o.product_category,
	round(sum(o.quantity * o.unit_price * (1 - o.discount / 100 )),2) as total_revenue
from 
	orders o
where o.order_status = 'Completed'
group by o.product_category
having sum(o.quantity * o.unit_price * (1 - o.discount / 100 )) > 100000;

-- Q20: Calculate the percentage of cancelled orders.
select
	(sum(case when o.order_status = 'Cancelled' then 1 else 0 end) * 100.0) / count(*) as cancellation_percentage
from orders o;

-- ============================================================
-- SECTION C: JOINS AND CUSTOMER ANALYTICS (Q21–Q28)
-- ============================================================

-- Q21: Display orders with customer names and cities.
select 
	o.order_id ,
	o.order_date,
	c.customer_name ,
	c.city
from 
	orders o 
inner join 
	customers c  on o.customer_id = c.customer_id;

-- Q22: Calculate total spending by customer.
select 
	c.customer_id,
	c.customer_name,
	round(coalesce(sum(o.quantity * o.unit_price * (1 - o.discount / 100 )),0),2) as total_completed_spending
from 
	customers c 
left join
	orders o on c.customer_id = o.customer_id and o.order_status  ='Completed'
group by
	c.customer_id,
	c.customer_name;

-- Q23: Identify customers who have never ordered.
select
	c.customer_id,
	c.customer_name
from 
	customers c 
left join 
	orders o on c.customer_id  = o.customer_id
where
 o.order_id is null;
	

-- Q24: Find the 10 highest-spending customers.
select 
	c.customer_id,
	c.customer_name,
	round(coalesce(sum(o.quantity * o.unit_price * (1 - o.discount / 100 )),0),2) as total_completed_spending
from 
	customers c 
left join
	orders o on c.customer_id = o.customer_id and o.order_status  ='Completed'
group by
	c.customer_id,
	c.customer_name
order by 
	COALESCE(SUM(o.quantity * o.unit_price * (1 - o.discount / 100)), 0) desc,
	c.customer_id 
limit 10;

-- Q25: Calculate revenue by customer city.
select 
	c.city,
	round(sum(o.quantity * o.unit_price * (1 - o.discount / 100 )),2) as total_revenue
from 
	orders o 
inner join 
	customers c  on o.customer_id = c.customer_id and o.order_status  ='Completed'
group by 
	c.city;

-- Q26: Identify customers with more than five orders.
select 
	c.customer_id,
	c.customer_name,
	count(o.order_id ) as  total_orders
from 
	orders o 
inner join 
	customers c  on o.customer_id = c.customer_id
group by 
	c.customer_id ,
	c.customer_name 
having
	count(o.order_id ) > 5;

-- Q27: Calculate average customer spending by segment.

select 
	c.customer_segment,
	round(
	coalesce(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 0)/ count(distinct c.customer_id),2) as avg_customer_spending
/* 
AVERAGE CUSTOMER SPENDING: 
Calculated as total completed revenue divided by the total distinct count of registered 
customers in that segment. Customers with zero spending are also included.
*/
from 
	customers c 
left join
	orders o on c.customer_id = o.customer_id and o.order_status  = 'Completed'
group by 
	c.customer_segment;

-- Q28: Identify the most popular category among VIP customers.
/* 
POPULAR: is defined by the category with the most units sold from completed orders
*/

select
	o.product_category,
	sum(o.quantity ) as total_units_sold
from 
	customers c 
inner join
	orders o  on c.customer_id = o.customer_id
where
	 c.customer_segment = 'VIP'
	 and o.order_status ='Completed'
group by
	o.product_category
order by
	total_units_sold desc
limit 1;

-- ============================================================
-- SECTION D: SUBQUERIES AND CTEs (Q29–Q34)
-- ============================================================

-- Q29: Find customers spending above the average total spending
-- per purchasing customer.
with purchasing_customers_totals as(
	select
		c.customer_id,
		c.customer_name,
		round(sum(o.quantity * o.unit_price * (1 - o.discount / 100 )),2) as total_spending
	from 
		customers c
	inner join
		orders o on c.customer_id  = o.customer_id
	where
		o.order_status = 'Completed'
	group by
		c.customer_id,
		c.customer_name 
)
select
	customer_id,
    customer_name,
    total_spending
from 
	purchasing_customers_totals
where
	total_spending > (select avg(total_spending)from purchasing_customers_totals )
order by
	total_spending desc;

-- Q30: Find products priced above the overall average unit price.
select
	o.product_category,
	o.product_name ,
	round(avg(o.unit_price),2) as avg_product_price
from 
	orders o
group by
	o.product_category,
	o.product_name
having
	 avg(o.unit_price ) > (select avg(o.unit_price) from orders o )
order by 
	avg_product_price;

-- Q31: Use a CTE to identify the three highest-revenue months.
with monthly_revenue as (
	select
		date_trunc('month', o.order_date ) as sales_month,
		sum(o.quantity * o.unit_price * (1 - o.discount / 100 )) as revenue
	from
		orders o
	where o.order_status  = 'Completed'
	group by
		date_trunc('month', o.order_date )
)
select 
	sales_month,
	round(revenue,2) as total_revenue
from monthly_revenue
order by revenue desc
limit 3;

-- Q32: Find customers purchasing from at least three categories.
select
	c.customer_id,
	c.customer_name,
	count(distinct o.product_category ) as categories_purchased
from customers c
inner join 
	orders o on c.customer_id = o.customer_id
where
	o.order_status = 'Completed'
group by 
	c.customer_id,
	c.customer_name
having
	count(distinct o.product_category) >= 3
order by
	categories_purchased desc,
	c.customer_id asc;


-- Q33: Use a CTE to calculate category revenue, cost, profit,
-- and profit margin.
with category_finances as (
	select
		o.product_category,
		sum(o.quantity * o.unit_price * (1 - o.discount / 100 )) as total_revenue,
		sum(o.quantity * o.cost_price ) as total_cost
	from 
		orders o
	where 
		o.order_status = 'Completed'
	group by
		o.product_category 
)
select
	product_category,
	round(total_revenue,2) as revenue,
	round(total_cost,2) as cost,
	round(total_revenue - total_cost, 2) as profit,
	round(((total_revenue - total_cost) * 100.0 / NULLIF(total_revenue, 0)),2) as profit_margin
from 
	category_finances 
order by
	profit_margin desc;

-- Q34: Find customers whose latest completed order is more than
-- 90 days before the latest order date in the dataset.
select
	c.customer_id,
	c.customer_name,
	max(o.order_date) as customer_last_completed_order,
	(select max(o.order_date) from orders o) as reference_date,
	((select max(o.order_date) from orders o) - max(o.order_date)) as inactive_days
from customers c
inner join 
	orders o on c.customer_id = o.customer_id 
where
	o.order_status = 'Completed'
group by
	c.customer_id,
	c.customer_name
having
	((select max(o.order_date) from orders o) - max(o.order_date)) > 90
order by
	inactive_days desc,
	c.customer_id asc;

-- ============================================================
-- SECTION E: WINDOW FUNCTIONS (Q35–Q42)
-- ============================================================

-- Q35: Rank customers by spending using RANK().
with customer_revenue_totals as (
	select
		c.customer_id,
		c.customer_name,
		round(sum(o.quantity * o.unit_price * (1-o.discount / 100.0 )),2) as total_spending
	from 
		customers c
	inner join 
		orders o on c.customer_id = o.customer_id
	where
		o.order_status = 'Completed'
	group by 
		c.customer_id,
		c.customer_name
)
select
	customer_id,
	customer_name,
	total_spending,
	rank() over (order by total_spending  desc) as spending_rank
from 
	customer_revenue_totals 
order by 
	spending_rank asc,
	customer_id asc;

-- Q36: Number each customer's orders by recency using ROW_NUMBER().
select
	c.customer_id,
	c.customer_name,
	o.order_id ,
	o.order_date,
	o.order_status,
	row_number() over (
		partition by c.customer_id 
		order by o.order_date desc, o.order_id desc
	) as order_recency_sequence
from 
	customers c
inner join 
	orders o on c.customer_id = o.customer_id
order by
	c.customer_id asc,
	order_recency_sequence asc;

-- Q37: Rank products within categories using DENSE_RANK().
with product_revenue_totals as (
    select  
        o.product_category,
        o.product_name , 
        ROUND(SUM(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2) AS total_product_revenue
    FROM 
        orders o
    WHERE 
        o.order_status = 'Completed'
    GROUP BY 
        o.product_category,
        o.product_name
)
select 
    product_category,
    product_name,
    total_product_revenue,
    DENSE_RANK() OVER (
        PARTITION BY  product_category 
        ORDER BY total_product_revenue DESC
    ) AS product_rank_in_category
from
	 product_revenue_totals
ORDER BY 
    product_category ASC, 
    product_rank_in_category ASC;

-- Q38: Calculate cumulative monthly revenue.
with monthly__revenue as (
    select
        date_trunc('month', o.order_date) as sales_month,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as revenue
    from
        orders o
    where 
        o.order_status = 'Completed' -- business rule: completed orders only
    group by
        date_trunc('month', o.order_date)
)
select
    sales_month,
    round(revenue::numeric, 2) as total_monthly_revenue,
    round(sum(revenue) over (
        order by sales_month asc
    ), 2) as cumulative_running_revenue
from
    monthly__revenue
order by
    sales_month asc;

-- Q39: Compare monthly revenue using LAG().
with monthly_revenue as (
    select
        date_trunc('month', o.order_date) as sales_month,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as current_revenue
    from
        orders o
    where 
        o.order_status = 'Completed' 
    group by
        date_trunc('month', o.order_date)
)
select
    sales_month,
    round(current_revenue, 2) as total_revenue,
    round(lag(current_revenue, 1) over (
        order by sales_month asc
    ), 2) as previous_month_revenue
from
    monthly_revenue
order by
    sales_month asc;

-- Q40: Calculate month-over-month revenue growth (%).
with monthly_base as (
    select
        date_trunc('month', o.order_date) as sales_month,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as current_revenue
    from
        orders o
    where 
        o.order_status = 'Completed' 
    group by
        date_trunc('month', o.order_date)
),
monthly_with_lag as (
    select
        sales_month,
        current_revenue,
        lag(current_revenue, 1) over (
            order by sales_month asc
        ) as previous_revenue
    from
        monthly_base
)
select
    sales_month,
    round(current_revenue, 2) as total_revenue,
    round(previous_revenue, 2) as previous_month_revenue,
    round((
        (current_revenue - previous_revenue) * 100.0 / nullif(previous_revenue, 0)
    ), 2) as growth_percent
from
    monthly_with_lag
order by
    sales_month asc;

-- Q41: Divide customers into four spending groups using NTILE(4).
with customer_spending_totals as (
    select
        c.customer_id,
        c.customer_name,
        round(coalesce(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 0), 2) as total_spending
    from
        customers c
    left join
        orders o on c.customer_id = o.customer_id and o.order_status = 'Completed'
    group by
        c.customer_id,
        c.customer_name
)
select
    customer_id,
    customer_name,
    total_spending,
    ntile(4) over (
        order by total_spending desc
    ) as spending_quartile
from
    customer_spending_totals
order by
    spending_quartile asc,
    total_spending desc,
    customer_id asc;

-- Q42: Calculate each category's share of total revenue
-- using window functions.
with category_revenue_totals as (
    select
        o.product_category,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) as category_revenue
    from
        orders o
    where
        o.order_status = 'Completed' -- business rule: completed orders only
    group by
        o.product_category
)
select
    product_category,
    round(category_revenue::numeric, 2) as revenue,
    round((
       category_revenue * 100.0 / nullif(sum(category_revenue) over (), 0)
    ), 2) as revenue_share_percent
from
    category_revenue_totals
order by
    revenue_share_percent desc;



-- ============================================================
-- SECTION F: ADVANCED BUSINESS INTELLIGENCE (Q43–Q46)
-- ============================================================

-- Q43: Create a monthly_sales_summary view containing:
-- month, orders, revenue, cost, and profit.
-- Then SELECT from the view.
create or replace view monthly_sales_summary as
with monthly_totals as (
    select
        date_trunc('month', o.order_date)::date as month,
        count(*) as orders,
        coalesce(
            sum(o.quantity * o.unit_price * (1 - o.discount / 100.0))
                filter (where o.order_status = 'Completed'),
            0
        ) as total_revenue,
        coalesce(
            sum(o.quantity * o.cost_price)
                filter (where o.order_status = 'Completed'),
            0
        ) as total_cost
    from orders o
    group by date_trunc('month', o.order_date)::date
)
select
    month,
    orders,
    round(total_revenue, 2) as revenue,
    round(total_cost, 2) as cost,
    round(total_revenue - total_cost, 2) as profit
from monthly_totals;

select *
from monthly_sales_summary
order by month;


-- Q44: Create a PostgreSQL function that returns completed-order
-- revenue for a supplied customer ID.
-- Demonstrate it for an existing customer and a nonexistent ID.
-- A nonexistent ID must return 0, not NULL.
create or replace function customer_completed_revenue(p_customer_id integer)
returns numeric
language plpgsql
as $$
declare
    v_revenue numeric;
begin
    select
        round(
            coalesce(
                sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)),
                0
            ),
            2
        )
    into v_revenue
    from orders o
    where o.customer_id = p_customer_id
        and o.order_status = 'Completed';

    return v_revenue;
end;
$$;

select
    141 as customer_id,
    customer_completed_revenue(141) as completed_revenue;

-- Test with an ID above the highest registered customer ID.
select
    max(c.customer_id) + 1 as missing_customer_id,
    customer_completed_revenue(max(c.customer_id) + 1) as completed_revenue
from customers c;


-- Q45: Segment customers into High, Medium, and Low Value.
-- The 25th and 75th percentiles use observed positive spending
-- so the cutoffs reflect what paying customers actually spent.
-- Customers below the lower cutoff, including zero spenders, are Low Value.

with customer_spending_totals as (
    select
        c.customer_id,
        c.customer_name,
        coalesce(
            sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)),
            0
        ) as total_spending
    from customers c
    left join orders o
        on c.customer_id = o.customer_id
        and o.order_status = 'Completed'
    group by
        c.customer_id,
        c.customer_name
),
spending_thresholds as (
    select
        percentile_disc(0.25) within group (order by total_spending) as lower_cutoff,
        percentile_disc(0.75) within group (order by total_spending) as upper_cutoff
    from customer_spending_totals
    where total_spending > 0
)
select
    c.customer_id,
    c.customer_name,
    round(c.total_spending, 2) as total_spending,
    case
        when c.total_spending >= t.upper_cutoff then 'High Value'
        when c.total_spending >= t.lower_cutoff then 'Medium Value'
        else 'Low Value'
    end as customer_value_segment
from customer_spending_totals c
cross join spending_thresholds t
order by
    c.total_spending desc,
    c.customer_id;


-- Q46a: Top five customers by completed spending.

select
    c.customer_id,
    c.customer_name,
    round(sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)), 2)
        as total_completed_spending
from customers c
inner join orders o
    on c.customer_id = o.customer_id
where o.order_status = 'Completed'
group by
    c.customer_id,
    c.customer_name
order by
    sum(o.quantity * o.unit_price * (1 - o.discount / 100.0)) desc,
    c.customer_id
limit 5;


-- Q46b: Top five products across all categories by completed revenue.

with product_revenue_totals as (
    select
        o.product_category,
        o.product_name,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100.0))
            as total_product_revenue
    from orders o
    where o.order_status = 'Completed'
    group by
        o.product_category,
        o.product_name
)
select
    product_category,
    product_name,
    round(total_product_revenue, 2) as product_revenue
from product_revenue_totals
order by
    total_product_revenue desc,
    product_category,
    product_name
limit 5;


-- Q46c: Most profitable category by total profit.

with category_finances as (
    select
        o.product_category,
        sum(o.quantity * o.unit_price * (1 - o.discount / 100.0))
            as total_revenue,
        sum(o.quantity * o.cost_price) as total_cost
    from orders o
    where o.order_status = 'Completed'
    group by o.product_category
)
select
    product_category,
    round(total_revenue, 2) as revenue,
    round(total_cost, 2) as cost,
    round(total_revenue - total_cost, 2) as profit
from category_finances
order by
    (total_revenue - total_cost) desc,
    product_category
limit 1;


-- Q46d: Month with the lowest revenue in the monthly sales view.

select
    month,
    revenue
from monthly_sales_summary
order by
    revenue asc,
    month asc
limit 1;