/*
----------------------------------------------------------------------------------------------------
-- Day 8 -- 

Problem count - 10
----------------------------------------------------------------------------------------------------
*/

-- Problem 1 -- 

/*
Using your products and sales for revenue, find the product with the highest total revenue for each product category.
Display the category, product_name, and the total_revenue for that product.
*/

with total_Product_revenue as (
    select 
        p.product_name,
        p.category,
        sum(s.revenue)  as total_revenue
    from products p  
    join sales s
    on p.product_id = s.product_id
    group by p.product_name, p.category
),
product_ranking as (
    select 
        product_name,
        category,
        total_revenue,
        row_number() over (partition by category order by total_revenue desc) as ranking
    from total_Product_revenue
)
select 
    product_name,
    category,
    total_revenue
from product_ranking
where ranking = 1;

-- Problem 2 -- 

/*
Using orders table, calculate the running total of total_amount for a single specific customer (customer_id = 301, for example), 
ordered by order_date.

Display the order_id, order_date, total_amount, and the new column running_total.
*/

select 
    customer_id,
    order_id,
    order_date,
    total_amount,
    sum(total_amount) over (partition by customer_id order by order_date, order_id) as running_total
from orders
where customer_id = 301;

-- Problem 3 -- 

/*
Using products table, calculate a 3-point moving average of the price for products in the 'Electronics' category, 
based on their product_id order (which simulates a time or sequence). 
The average at any row should include the current row, the 1 preceding row, and the 1 following row.
Display the product_id, product_name, price, and the new column three_point_avg.
*/


select 
    product_id,
    product_name,
    price,
    avg(price) over (order by product_id rows between 1 preceding and 1 following ) as three_point_avg
from products
where category in ('Electronics');

-- Problem 4 -- 

/*
Using sales and products tables, 
find the customer_id for all customers who made at least one purchase of a product in the 'Accessories' category and also made at least one purchase of a product in the 'electronics' category.
Display the customer_id and the total number of orders placed by that customer.
*/

select 
    s.customer_id,
    count(s.sale_id) as total_orders_placed,
    sum(case when p.category = 'Accessories'  then 1 else 0 end) as accessories_purchase, -- showing the columns for better understanding of how the orders are broken up.
    sum(case when p.category = 'electronics' then 1 else 0 end) as electronics_purchase
from products p  
join sales s  
on p.product_id = s.product_id 
group by s.customer_id
having 
         sum(case when p.category = 'Accessories'  then 1 else 0 end) >= 1
    and  sum(case when p.category = 'electronics' then 1 else 0 end) >= 1;

-- Problem 5 -- 

/*
Using customer_actions table, a customer might have multiple action_type entries (e.g., 'Viewed Product', 'Added to Cart') 
on the same day. Find the most recent unique action_type for each customer based on the action_date.
Display the customer_id, the unique action_type, and the corresponding action_date.
*/ 

select * 
from (
select
    customer_id,
    action_date,
    action_type,
    row_number() over (partition by customer_id, action_type order by action_date desc, action_id desc) as ranking
from customer_actions
)t 
where ranking = 1;

-- Problem 6 -- 

/*

Using your employees table, find the first_name, last_name, and salary of all employees whose salary is 
greater than the average salary of their respective department.
Display the employee details, their salary, and the average salary of their department.
*/ 

select * 
from (
select 
    emp_id,
    dept_id,
    first_name,
    last_name,
    salary,
    avg(salary) over(partition by dept_id) as avg_salary
from employees
)t 
where salary > avg_salary;

-- Problem 7 -- 

/*
Using orders table, assign each order to a specific Volume_Tier based on its total_amount.
Define the tiers as follows:

    - 'Low Value': total_amount less than 50.
    - 'Medium Value': total_amount between 50 and 500 (inclusive).
    - 'High Value': total_amount greater than 500.
Display the order_id, total_amount, and the new column Volume_Tier.
*/

select 
    order_id,
    total_amount,
    case 
        when total_amount < 50 then 'Low_Value'
        when total_amount between 50 and 100 then 'Medium_value'
        else 'High_value'
    END as volume_tier 
from orders
order by total_amount desc;

-- Problem 8 -- 

/*
Using your employees table, find the complete management chain for a specific employee (e.g., employee with emp_id = 101), 
listing every manager up to the top-level manager (who has a NULL manager_id).
Display the emp_id, first_name, last_name, and the manager_id for every person in that chain.
*/

with managementchain as 
(
    select 
        emp_id,
        first_name,
        last_name,
        manager_id,
        1 as level 
    from employees
    where emp_id = 101

    union all 

    select 
        m.emp_id,
        m.first_name,
        m.last_name,
        m.manager_id,
        c.level + 1 
    from employees m 
    join managementchain c 
    on m.emp_id = c.manager_id
) 
select 
    emp_id,
    first_name,
    last_name,
    manager_id
from managementchain
order by level;

-- Problem 9 -- 

/*
Using customer_actions table, 
find all instances where a customer's action status changed from 'Viewed Product' to 'Added to Cart' in two consecutive, 
chronologically ordered actions.
Display the customer_id, the date of the 'Viewed Product' action, and the date of the 'Added to Cart' action.
*/

with rankedactions as (
    select 
        customer_id,
        action_type,
        action_date,
        lag(action_type) over (partition by customer_id order by action_date, action_type, action_id) as previous_action,
        lag(action_date) over (partition by customer_id order by action_date, action_type, action_id) as previous_action_date
    from customer_actions 

)
select 
    customer_id,
    previous_action_date as viewed_product_date,
    action_date as added_to_cart_date 
from rankedactions
where 
    action_type = 'Add_to_cart'
and previous_action = 'product_view';

-- Problem 10 -- 

/*
Using customers, orders, and products tables, find the customer_id and full name of all customers who:
    1. HAVE placed an order in the 'Home Goods' category.
        AND
    2.HAVE NOT placed an order for a product priced over $100 at any time.
*/ 

select 
    customer_id,
    first_name + ' ' + last_name as full_name
from customers c
where 
    c.customer_id in 
    (
        select distinct 
            o.customer_id
        from orders o  
        join order_details od  
        on o.order_id = od.order_id 
        join products p 
        on od.product_id = p.product_id
        where p.category = 'Electronics'
    )
and 
    c.customer_id not in 
    (
        select distinct 
            o.customer_id 
        from orders o  
        join order_details od
        on o.order_id = od.order_id 
        join products p 
        on od.product_id = p.product_id 
        where p.price > 100
    );