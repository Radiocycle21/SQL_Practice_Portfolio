/*
----------------------------------------------------------------------------------------------------
-- Day 6 -- 

Problem count - 
----------------------------------------------------------------------------------------------------
*/

-- Problem 1 -- 

/*
Using employees table, find the employee with the highest salary in each dept_id.
Display the dept_id, the employee's first_name, and their salary.
*/

select * 
from(
select 
    emp_id,
    dept_id,
    first_name,
    salary,
    row_number() over (partition by dept_id order by salary desc) as ranking
from employees
)t
where ranking = 1;

-- Problem 2 -- 

/*
Using sales table, calculate the running total of revenue for each customer_id, ordered chronologically by sale_date.
Display the customer_id, sale_date, revenue, and the new calculated column running_revenue_total.

*/
-- important: running total is always calculated ascending order. 

select 
    customer_id,
    sale_Date,
    revenue,
    sum(revenue) over (partition by customer_id order by sale_date) as running_revenue_total
from sales;

-- Problem 3 --
 
/*
Using the employees table, identify all dept_ids that have:
 - A total salary pool greater than $200,000 AND
 - More than 5 employees.
Display the dept_id and the total number of employees and the total salary.
*/ 

select 
    dept_id,
    count(emp_id) as total_employees,
    sum(salary) as total_salary
from employees
group by dept_id
having  
    sum(salary) >= 450000
and count(emp_id) >= 5 ;

-- Problem 4 -- 

/* 
Using your existing employees table, identify the "hiring islands": periods of three or more consecutive days where at least one employee was hired each day.

Display the start date and the end date of each such hiring island.
*/ 

-- answer by Gemini 

WITH HiringDays AS (
    -- Step 1: Get the distinct days where a hire occurred and assign a row number (rn)
    SELECT DISTINCT
        CAST(hire_date AS DATE) AS hire_day,
        ROW_NUMBER() OVER (ORDER BY CAST(hire_date AS DATE)) AS rn
    FROM employees
),
IslandGroups AS (
    -- Step 2: Calculate the Group ID. Consecutive days will have the same Group ID.
    -- (Date - Row_Number = Constant for a consecutive sequence)
    SELECT
        hire_day,
        -- Subtract the row number from the date to create the constant group ID
        DATEADD(day, -rn, hire_day) AS island_group_id
    FROM HiringDays
)
SELECT
    MIN(hire_day) AS island_start_date,
    MAX(hire_day) AS island_end_date
FROM IslandGroups
GROUP BY island_group_id
-- Step 3: Filter for islands of 3 or more days
HAVING DATEDIFF(day, MIN(hire_day), MAX(hire_day)) + 1 >= 3
ORDER BY island_start_date;

-- Problem 5 -- 

/*
Using employees table, find the time gap (in days) between an employee's hire date and the hire date of the next employee hired in the entire company.
Display the first_name, hire_date, and the days_until_next_hire.
*/

select 
    first_name,
    hire_date,
    lag(hire_date) over (order by hire_date ) as preivous_hire_date,
    datediff(day, lag(hire_date) over (order by hire_date ), hire_date ) as days_since_previous_hire
from employees
order by hire_date; 

-- Problem 6 --

/* 
Using your existing sales table, you need to deduplicate records based on the logical key (order_id and product_id).
Write a query that returns the sale_id of the records that should be kept for each logical group, 
prioritizing by highest revenue. If revenue is tied, prioritize the record with the highest sale_id.
*/

select sale_id
from (
select 
    sale_id,
    row_number() over (partition by order_id, product_id, customer_id order by revenue desc, sale_id desc) as ranking 
 from sales
)t 
where ranking = 1;

-- problem 7 -- 

/* 
Write a query that deletes all the records from the sales table that are considered duplicates 
(i.e., those that were NOT identified as the primary record in Question 6).
Use the logic from Question 6 to identify the rows to be deleted
*/

-- solutoin given by Gemini 
-- Do not run this code. it will delete the rows in the database.

/* 

WITH DuplicatesToDelete AS (
    SELECT 
        sale_id,
        ROW_NUMBER() OVER (  PARTITION BY order_id, product_id, customer_id 
            ORDER BY 
                revenue DESC, -- Highest revenue first
                sale_id DESC    -- Highest sale_id tie-breaker
        ) AS ranking 
    FROM sales
)
DELETE FROM sales
WHERE sale_id IN (
    -- Select only the sale_id of the rows that are NOT the primary record (ranking > 1)
    SELECT sale_id 
    FROM DuplicatesToDelete
    WHERE ranking > 1
);

*/ 

-- Problem 8 -- 

/*
Write an SQL query to find the second lowest-paid employee in each department. 
If there are fewer than two employees, return all of them.
Display the department id, employee full name, and salary.
*/

select *
from (
select
        emp_id,
        first_name,
        last_name,
        dept_id,
        salary,
        DENSE_RANK() over(partition by dept_id order by salary asc ) as ranking
    from employees
)t
where ranking <= 2;

-- Problem 9 --

/* 
For each product, calculate the running average of the price based on product_id order (to simulate some non-date-based sequence).
Display the product_id, product_name, price, and the running_average_price.
*/

select
    product_id,
    product_name,
    price,
    avg(price) over (order by price ) as running_average_price
from products;

-- Problem 10 --

/*
Identify all customers who have placed orders totaling over $1,000 in a single order AND have also placed at least three separate orders on different days. 
Display their full name and customer_id.
*/

-- solution by Gemini
select
    c.customer_id,
    concat(c.first_name, ' ', c.Last_name) as fullname
from orders o
    join customers c
    on o.customer_id = c.customer_id
group by 
    c.customer_id,
    concat(c.first_name, ' ', c.Last_name)
having 
    max(o.total_amount) >1000
    and
    count(distinct o.order_date) >=3
order by c.customer_id;

