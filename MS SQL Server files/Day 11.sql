/*
----------------------------------------------------------------------------------------------------
-- Day 11 -- 

Problem count -
----------------------------------------------------------------------------------------------------
*/

-- Problem 1 -- 

/* 
From the customers table, find all duplicate customers based on email.
Return: customer_id, first_name, last_name, email.
*/

select 
    customer_id,
    first_name,
    last_name,
    email 
from customers 
where email in (
        select 
            email
        from customers
        group by email
        having count(*) > 1
);


-- Problem 2 -- 

/*
Find all customers whose first_name + last_name combination appears more than once in the customers table, regardless of email.

Return the full rows, i.e.:
customer_id
first_name
last_name
email
*/


select 
    customer_id,
    first_name,
    last_name,
    email 
from customers
where concat(first_name, ' ', last_name) in (
    select 
        concat(first_name, ' ', last_name) as fullname
    from customers 
    group by  concat(first_name, ' ', last_name)
    having count(*) > 1 
);


-- Problem 3 --

/*
From the sales table, return the top 10 sales ordered by revenue DESC.
Then, from those top 10 results, return only the rows where the row number is odd
(i.e., rows 1, 3, 5, 7, 9).

Return the full rows from the sales table.
*/

WITH ranked AS (
  SELECT
    sale_id,
    order_id,
    product_id,
    customer_id,
    sale_date,
    quantity,
    revenue,
    employee_id,
    ROW_NUMBER() OVER (ORDER BY revenue DESC, sale_id) AS rn
  FROM sales
)
SELECT *
FROM ranked
WHERE rn <= 10
  AND rn % 2 = 1
ORDER BY rn;

-- Problem 4 -- 

/*
FInd the count of rows for all the 5 join types of tables department and employees 
*/

-- Inner join
SELECT 
    'Inner_join' as joins,
    count(*) as count
FROM department d 
INNER JOIN employees e 
ON d.dept_id = e.dept_id

union all

-- left join 
SELECT
    'Left_join',
    count(*)
FROM department d 
LEFT JOIN employees e 
ON d.dept_id = e.dept_id

UNION ALL

-- right join 
SELECT 
    'Right_join',
    count(*)
FROM department d 
RIGHT JOIN employees e 
ON d.dept_id = e.dept_id

UNION ALL

-- full outer join 
SELECT 
    'Full_outer_join',
    count(*)
FROM department d 
FULL OUTER JOIN employees e 
ON d.dept_id = e.dept_id

UNION all 

-- cross join 
SELECT 
    'Cross Join',
    count(*) as cross_count
FROM department d 
CROSS JOIN employees e;

-- there are no employees without a dept. that is why all the joins came back the same number. 
-- if the data had anything without depts. then the joins would've been different. 

-- Problem 5 -- 

/*
Assume order_id is not unique (just a scenario — you’re practising the logic).
Each duplicated order has multiple rows with the same order_id.
You need to delete duplicates and keep only the row with the latest order_date.

Return the final set of rows after deletion (or write the correct DELETE query).
*/

with rownumbers as (
    select 
        order_id,
        order_date,
        row_number() over (partition by order_id order by order_date desc ) as ranking
    from orders
) 
-- delete
from rownumbers
where ranking > 1;

-- Problem 6 -- 

/*
Using your products and sales tables, find the top 3 products by total revenue for each product category.
Return these columns:
category
product_id
product_name
total_revenue
prod_rank — rank within the category (1 = highest revenue)
*/ 

with sum_revenue as (
select 
    p.category,
    p.product_id,
    p.product_name,
    sum(s.revenue) as total_revenue
from products p  
join sales s  
on p.product_id = s.product_id
group by p.category, p.product_id, p.product_name 
),
ranking as (
    select 
        category, 
        product_id,
        product_name, 
        total_revenue,
        dense_rank() over (partition by category order by total_revenue desc) as rn
    from sum_revenue 
)
select * 
from ranking 
where rn <= 3;

-- Problem 7 -- 

/*
For each customer_id in orders, return the orders that are in positions 3, 6, 9, ... (i.e., every 3rd order by order_date ascending). 
Return customer_id, order_id, order_date, rn where rn is the row number per customer.
*/

select * 
from (
select 
    customer_id,
    order_id,
    order_date,
    row_number() over (partition by customer_id order by order_date asc) as ranking
from orders 
)t 
where ranking % 3 = 0;

-- problem 8 -- 

/*
Return all customers who have never placed an order.
Output: customer_id, first_name, last_name, email
*/

select 
    c.customer_id,
    c.first_name,
    c.last_name, 
    c.email,
    o.order_id
from customers c 
left join orders o  
on c.customer_id = o.customer_id
where o.order_id is null;

-- problem 9 -- 

/*
Return all products that have never been ordered
(from products table, checking against order_details).

Return:
product_id
product_name
category
price
*/

select 
    p.product_id,
    p.product_name,
    p.category,
    p.price
from products p
left join order_details od  
on p.product_id = od.product_id 
where od.order_id is null;

-- Problem 10 -- 

/*
Find customers whose second order (by order_date ascending) landed on a weekend (Saturday or Sunday).
Return these columns:
customer_id
order_id (the second order's id)
order_date
rn (row number per customer)
*/

select * 
from (
select 
    customer_id, 
    order_id,
    order_date,
    row_number() over (partition by customer_id order by order_date asc) as ranking,
    datename(weekday, order_date) as dayofweek
from orders 
)t 
where ranking = 2
and (dayofweek = 'Saturday' or  dayofweek = 'sunday')

-- alternate way using IN

select * 
from (
select 
    customer_id, 
    order_id,
    order_date,
    row_number() over (partition by customer_id order by order_date asc) as ranking,
    datename(weekday, order_date) as dayofweek
from orders 
)t 
where ranking = 2
and dayofweek in ('Saturday', 'sunday')