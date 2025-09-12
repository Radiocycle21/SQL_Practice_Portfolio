
/*
============================================================================================================================================
This is the custom Business BD created by Prajwal Sai N. for the purpose of practicing. 

This file contains the Business DB schema
============================================================================================================================================
*/

-- Drop the existing database
DROP DATABASE IF EXISTS BusinessDB;

-- Recreate the database
CREATE DATABASE BusinessDB;

-- Switch to the newly created database
USE BusinessDB;

-- Create the schema
CREATE TABLE department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE employees (
    emp_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    dept_id INT,
    salary INT,
    hire_date DATE,
    manager_id INT NULL,
    FOREIGN KEY (dept_id) REFERENCES department(dept_id)
);

CREATE TABLE customers (
    customer_id INT PRIMARY KEY,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(100),
    price DECIMAL(10, 2),
    stock_quantity INT
);

CREATE TABLE order_details (
    order_detail_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    quantity INT,
    subtotal DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE sales (
    sale_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    product_id INT,
    customer_id INT,
    sale_date DATE,
    quantity INT,
    revenue DECIMAL(10, 2),
    employee_id INT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (employee_id) REFERENCES employees(emp_id)
);

-- Create the customer_actions table to track different customer events
CREATE TABLE customer_actions (
    action_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    action_type VARCHAR(50) NOT NULL,
    action_date DATE,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);