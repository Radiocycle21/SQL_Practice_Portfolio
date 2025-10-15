/*
----------------------------------------------------------------------------------------------------
-- Day 9 -- 

Problem count - 15
----------------------------------------------------------------------------------------------------
*/

-- Problem 1 -- 

/* 
Using products table, find the product_name and price for all products that are in the 'Home Appliances' category.
*/

select 
    product_name,
    price 
from products 
where category = 'Home Appliances';

-- Problem 2 -- 

/*
Using employees table, find the first_name, last_name, and salary for all employees whose salary is greater than 75000.
*/

select 
    first_name,
    last_name,
    salary 
from employees 
where salary > 70000;

-- Problem 3 -- 

/* 
Using products table, find the product_name and category for all products whose category is either 'Electronics', 'Furniture', or 'Home appliances'.
*/

select 
    product_name,
    category,
    price 
from products 
where category in ('Photography', 'Home Appliances', 'Furniture');

-- Problem 4 -- 

/* 
Using department table, list all departments except for 'Sales' and 'Marketing'. Display the dept_name.
*/

select 
    dept_id,
    dept_name
from department
where dept_name not in ('Sales', 'Marketing')


-- Problem 5 -- 

/*
Using orders table, find the order_id and total_amount for all orders with a total amount between 50.00 and 150.00, inclusive.
*/

select 
    order_id,
    total_amount 
from orders
where total_amount between 50 and 150;

-- Problem 6 -- 

/*
Using sales table, find the sale_id and sale_date for all sales that occurred in the year 2024.
*/ 

select 
    sale_id,
    sale_date 
from sales 
where year(sale_date) = '2024';

-- Problem 7 -- 

/*
Find the first_name and last_name of all customers who have placed an order (i.e., their customer_id is present in the orders table).
*/

select 
    first_name,
    last_name
from customers 
where customer_id in (select distinct customer_id from orders);

-- Problem 8 --

/*
Find the product_name of all products that have not been sold (i.e., their product_id is NOT present in the sales table).
*/

select 
    product_name
from products 
where product_id not in (select distinct product_id from sales); 

-- Problem 9 -- 

/*
Find the order_id and order_date for orders placed by customer_id = 309 AND had a total_amount less than 100.
*/

select 
    order_id,
    order_date
from orders
where customer_id = 309 
and total_amount <= 100;

-- Problem 10 -- 

-- Find the product_name and price for any product that is in the 'Electronics' category OR has a price greater than 500.

select 
    product_name,
    price
from products 
where category = 'Electronics' 
or price >= 500;

-- Problem 11 --

-- Using the customers table, find the first_name and last_name of all customers whose last_name starts with the letter 'S'.

select 
    first_name,
    last_name
from customers 
where last_name like 'S%';

-- Problem 12 -- 

-- Using the customers table, find the email addresses that contain the string '@example.com' (assuming this is a common test domain in your data).

select 
    email 
from customers 
where email like '%example.com';

-- Problem 13 -- 

-- Using the employees table, 
-- find the first_name and last_name of all top-level employees who do not have a manager.

select 
    first_name,
    last_name,
    manager_id
from employees 
where manager_id is null;

-- Problem 14 -- 

-- Using the employees table, find the first_name and last_name of all employees who do have a manager.

select 
    first_name,
    last_name,
    manager_id
from employees 
where manager_id is not null; 

-- Problem 15 -- 

-- Using the orders table, find the total number of orders placed by customer_id = 310.

select 
    c.customer_id,
    c.first_name,
    c.last_name,
    count(o.order_id) as total_number_of_orders 
from orders o  
join customers c  
on o.customer_id = c.customer_id 
where o.customer_id = 310
group by c.customer_id, c.first_name, c.last_name;

