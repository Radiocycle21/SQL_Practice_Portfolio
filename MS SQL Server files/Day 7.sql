/*
----------------------------------------------------------------------------------------------------
-- Day 7 -- 

Problem count - 18
----------------------------------------------------------------------------------------------------
*/

-- Problem 1 -- 

/* 
Using customers and orders tables, find all customers who have NEVER placed an order.
Display the customer_id, first_name, and last_name of these customers.
Write two SQL solutions:
    - One solution using a LEFT JOIN technique.
    - One solution using the NOT IN or NOT EXISTS technique.
*/ 

-- solution one: 

select 
    c.customer_id,
    c.first_name,
    c.last_name 
from customers c  
left join orders o  
on c.customer_id = o.customer_id
where o.order_id is null; 

-- solution two: 

select 
    c.customer_id,
    c.first_name,
    c.last_name 
from customers c  
where customer_id not in (
    select distinct customer_id
    from orders o  
);

-- probelm 2 -- 

/*
Using employees table (which contains the manager_id foreign key referencing emp_id), find the full management chain for a specific employee (e.g., employee with emp_id = 705), 
going all the way up to the top-level manager (the one whose manager_id is NULL).
Display the emp_id, first_name, and the manager_id for every employee in that chain.
*/ 

with managementchain as (
    select 
        e.emp_id,
        e.first_name,
        e.last_name,
        e.manager_id,
        1 as level
    from employees e  
    where e.emp_id = 101 

    union all 

    select 
        m.emp_id,
        m.first_name,
        m.last_name,
        m.manager_id,
        c.level + 1 as level 
    from employees m 
    join managementchain c 
    on m.emp_id = c.manager_id 
)
select 
    emp_id,
    first_name,
    last_name,
    manager_id,
    level 
from managementchain
order by level 

-- Problem 3 -- 

/* 
Using customer_actions table, identify the first time each customer completed the action type 'Checkout' after 
having previously performed the action type 'Product_view'.
Display the customer_id, the date of the 'Product_veiw' action, and the date of the subsequent 'checkout' action.
*/ 

with sequenceactions as (
    select 
        customer_id,
        action_type,
        action_date,
        lag(action_type) over(partition by customer_id order by action_date) as next_action_type,
        lead(action_type) over(partition by customer_id order by action_date) as next_action_date
    from customer_actions
    where action_type in ('product_view', 'checkout')
),
filtered_transistion as (
    select 
        customer_id,
        action_date as browse_date,
        next_action_date  as checkout_date
    from sequenceactions
    where 
        action_type = 'Product_view'
    and next_action_type = 'Checkout'
)
select 
    customer_id,
    min(browse_date) as first_browse_date,
    min(checkout_date) as first_checkout_date 
from filtered_transistion
group by customer_id
order by customer_id;


-- Problem 4 -- 

/*
Find all employees whose current salary is greater than the salary of the employee who was hired immediately before them.
*/

with hiredSequence as (
    select 
        first_name,
        hire_date,
        salary, 
        lag(salary, 1) over (order by hire_date) as salary_of_previous_hire 
    from employees 
)
select * 
from hiredSequence 
where salary>salary_of_previous_hire 
order by hire_date; 

-- Problem 5 -- 

/*
Using your existing employees table, identify all employees in the 'Sales' department
whose salary is greater than the average salary of their entire department.
Display the employee's first_name, dept_id, and salary.
*/ 

with employeeaverage as (
    select 
        e.first_name,
        e.dept_id,
        e.salary,
        d.dept_name,
        avg(e.salary) over (partition by e.dept_id) as dept_average_salary
    from 
        employees e  
    join department d  
    on e.dept_id = d.dept_id 
)
select 
    first_name,
    dept_id,
    salary
from employeeaverage
where 
    dept_id = 203 
and salary > dept_average_salary 
order by salary desc;

-- Problem 6 -- 

/* 
Using your existing products table, categorize each product's price into one of three tiers based on the distribution of all product prices:
    - 'Budget' (Lowest 33.3% of prices)
    - 'Mid-Range' (Middle 33.3% of prices)
    - 'Premium' (Highest 33.3% of prices)
Display the product_name, price, and the new column price_tier.
*/

with rankedproducts as (
    select 
        product_id,
        product_name,
        price,
        ntile (3) over( order by price) as price_rank
    from products
)
select 
    product_id,
    product_name,
    price,
    case 
        when price_rank = 3 then 'Premium'
        when price_rank = 2 then 'Mid-Range'
        else 'Budget'
    end as price_tier 
from rankedproducts
order by price desc;

-- problem 7 -- 

/*
Using products table, find the product_name and price of all products that belong to the following categories: 
'Electronics', 'Furniture', or 'Photography'.
*/

select 
    product_id,
    product_name,
    category 
from products
where category in ('Electronics', 'Furniture', 'Photography');

-- Problem 8 -- 

/* 
Using employees table, find all employees who do NOT work in the following departments: 
dept_id 201, dept_id 203, or dept_id 205.
Display the first_name, last_name, and dept_id of these employees.
*/

select 
    first_name,
    last_name,
    dept_id 
from employees 
where dept_id not in (201, 203, 205);

-- Problem 9 -- 
/*
Using sales table, find all sales that occurred within the first two months of the year, 
specifically between '2024-03-01' and '2024-05-29' (inclusive).
Display the sale_id, sale_date, and revenue.
*/

select 
    sale_id,
    sale_date,
    revenue 
from sales 
where sale_date between '2024-03-01' and '2024-05-29';

-- Problem 10 -- 
/*
Using products table, find all products whose price is not in the mid-range of $50.00 to $200.00 (inclusive).
Display the product_name and price.
*/ 

select 
    product_name,
    price
from products
where price not between 50 and 200;

-- Problem 11 -- 
/*
Using your employees and department tables, find the first_name and last_name of all employees 
who work in a department named 'Marketing'.
*/

select 
    e.first_name,
    e.last_name,
    d.dept_name
from employees e
left join department d  
on e.dept_id = d.dept_id 
where d.dept_name = 'Marketing';

-- OR -- 

select 
    first_name,
    last_name,
    dept_id
from employees 
where dept_id in (
    select 
        dept_id
    from department
    where dept_name = 'Marketing'
);

-- Problem 12 -- 

/*
Using your customers and orders tables, find the first_name and last_name of all customers who have NEVER placed an order.
*/

select 
    first_name,
    last_name
from customers
where customer_id not in (
    select 
        customer_id
    from orders 
);

-- Problem 13 -- 

/* 
Using employees table, find the first_name and last_name of all employees who currently 
do not have a manager assigned (i.e., their manager_id is unknown).
*/

select 
    first_name,
    last_name,
    manager_id
from employees
where manager_id is null; 


-- problem 14 -- 

/*
Using sales table, find all sales that meet one of these two criteria:

    1. The sale occurred in order_id = 501 AND the revenue was greater than $500.

    2. OR the sale occurred in order_id = 502 (regardless of revenue).

Display the sale_id, order_id, and revenue.
*/

select 
    order_id,
    revenue
from sales
where (order_id = 501 and revenue >= 300) or  order_id = 502;

-- problem 15 -- 

/* 
Using sales table, find all sales records that meet all of the following criteria:
    - The sale occurred during the second half of the year (on or after '2024-07-01').
    - The sale's revenue was either less than $100.00 OR greater than $5,000.00.
    - The sale's customer_id is NOT one of the known high-value customers (exclude customer IDs 301, 305, and 310).
    - The quantity sold must be known (i.e., not NULL).
Display the sale_id, sale_date, revenue, and customer_id.
*/ 


select 
    sale_id,
    sale_date,
    revenue,
    customer_id,
    quantity
from sales
where 
    sale_date >= '2024-02-01' -- changed the date to see the rows, data does not exist in my DB beyond 5th month LOL! 
    and (revenue >= 10 or revenue <= 300)
    and customer_id not in (301, 305, 310)
    and quantity is not null;

-- Problem 16 -- 

/*
Using products table, retrieve the product_name and category of all products that meet the following criteria:
    -The category must be 'Electronics' or 'Fashion'.
    - AND the category must NOT be 'Furniture'.
*/

select 
    product_name,
    category
from products 
where category in ('Electronics', 'Fashion')
and category not in ('Furniture');

-- Probelem 17 -- 

/* 
Using products, orders, and order_details tables, 
find the product_id and product_name of all products that meet the following two criteria simultaneously:
    1. The product belongs to the 'Electronics' or 'Home Appliances' categories.
    2. AND the product has NEVER been purchased in an order placed during the year 2024.
*/

select 
    product_id,
    product_name
from products 
where category in ('Electronics', 'Home Appliances')
and product_id not in (
    select 
        product_id
    from orders o 
    join order_details od  
    on o.order_id = od.order_id
    where year(order_date) = 2024
);

-- Problem 18 -- 

/*
Find the customer_id of all customers who have placed at least one order in the 'Fashion' or 'Furniture' categories, 
but have never placed any order in the 'Electronics' category.
*/

select 
    s.customer_id
from products p  
join sales s 
on p.product_id = s.product_id
where p.category in ('Fashion', 'Furniture')
and s.customer_id not in (
    select 
        customer_id
    from sales s  
    join products p  
    on p.product_id = s.product_id
    where p.category in ('Electronics')
);