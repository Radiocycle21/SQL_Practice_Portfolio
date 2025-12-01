/*
----------------------------------------------------------------------------------------------------
-- Day 12 -- 

Problem count - 10
----------------------------------------------------------------------------------------------------
*/

-- Problem 1 -- 

/*
Find customers who have placed more than 3 orders. 
Return: customer_id, first_name, last_name, order_count
Order by order_count DESC.
*/

select 
    c.customer_id,
    c.first_name,
    c.last_name,
    count(o.order_id) as order_count 
from customers c
join orders o  
on c.customer_id = o.customer_id
group by c.customer_id, c.first_name, c.last_name
having count(o.order_id) >= 3
order by count(o.order_id) desc; 

-- Problem 2 --

/* 
Find the top 2 highest-paid employees per department.
Return:
    dept_id
    emp_id
    first_name
    salary
    rank_in_dept
Sort departments normally, but within each dept return salaries in descending order.
*/

select * 
from (
SELECT
    d.dept_id,
    e.emp_id,
    e.first_name,
    e.salary,
    row_number() over (partition by d.dept_id order by e.salary desc) as ranking 
from employees e  
join department d  
on e.dept_id = d.dept_id
)t 
where ranking <= 2;

-- Problem 3 -- 

/*
Find the customers who bought more than 5 different products.

Return:
    customer_id
    first_name
    last_name
    distinct_product_count
*/

select 
    c.customer_id,
    c.first_name,
    c.last_name,
    count(distinct s.product_id ) as distinct_product_count 
from sales s
join customers c   
on s.customer_id = c.customer_id 
group by 
    c.customer_id,
    c.first_name,
    c.last_name
having count(distinct s.product_id ) >= 5;

-- Problem 4 -- 

/*
You need to find the top 3 customers by revenue,
but only considering orders placed in odd-numbered months
(i.e., Jan, Mar, May, Jul, Sep, Nov).
Return:
    customer_id
    total_revenue
    month_of_order
    rank (based on revenue)
*/

select * 
from (
select 
    customer_id,
    total_amount,
    DATEPART("month", order_date) as months,
    datename("month", order_date) as monthname,
    row_number() over (order by total_amount desc) as ranking 
from orders
)t 
where months % 2 = 1
order by months;

-- Problem 5 -- 

/*
Return rows for each customer that correspond to their 2nd, 3rd, and 5th orders by order_date. 
Output: customer_id, order_id, order_date, rn. If a customer doesn't have that position, exclude them.
*/

select * 
from (
select 
    order_id,
    customer_id,
    order_date,
    row_number() over (partition by customer_id order by order_date desc) as ranking 
from orders 
)t 
where ranking in (2,3,5);

-- Problem 6 -- 

-- find the Rolling 7-day revenue per product

select 
    product_id,
    revenue,
    sum(revenue) over (partition by product_id order by sale_date rows between 6 preceding and current row) as rolling_revenue
from sales; 

-- Problem 7 -- 

/*
Return emp_id, first_name, salary, manager_id, manager_name, manager_salary for employees whose manager’s salary < employee salary.
*/

SELECT 
  e.emp_id           AS emp_id,
  e.first_name       AS first_name,
  e.salary           AS salary,
  m.emp_id           AS manager_id,
  m.first_name       AS manager_name,
  m.salary           AS manager_salary
FROM employees e              
JOIN employees m 
  ON e.manager_id = m.emp_id
WHERE m.salary < e.salary;

-- Problem 8 -- 

-- find the Month-over-Month revenue % change

with order_months as (
select 
    datename("month", o.order_date) as months,
    month(o.order_date) as Nr_month,
    year(o.order_date) as Yr_month,
    sum(s.revenue) as total_revenue 
from sales s  
join orders o 
on s.order_id = o.order_id
group by  
    datename("month", o.order_date),  
    month(o.order_date), 
    year(o.order_date)
),
previous_month as (
    select 
        months,
        Nr_month,
        Yr_month,
        total_revenue,
        lag(total_revenue) over (order by yr_month, Nr_month ) as prev_month 
    from order_months
)
select 
        months,
        Nr_month,
        Yr_month,
        total_revenue,
        prev_month,
        case 
            when prev_month is null then null 
            when prev_month = 0 then null 
            else ( (total_revenue - prev_month) * 1.0/ prev_month) * 100 
        END as percentage_change
from previous_month
order by Yr_month, Nr_month;



-- problem 9 -- 

/*
find the Products whose price is ABOVE their category’s average price.

Return:
    product_id
    product_name
    category
    price
    category_avg_price
Sort by category, price DESC.
*/

select * 
from (
select 
    product_id,
    product_name,
    category,
    price,
    avg(price) over(partition by category) as category_avg_price 
from products 
)t 
where price > category_avg_price;

-- Problem 10 -- 

/*
Find all product–customer combinations where a customer has ordered the same product more than once.

Return:
    customer_id
    product_id
    total_times_ordered
Sort by total_times_ordered DESC.
*/

select 
    customer_id,
    product_id,
    count(*) as total_times_ordered 
from sales 
group by customer_id, product_id 
having count(*) > 1;