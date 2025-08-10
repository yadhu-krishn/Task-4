CREATE DATABASE ecommerce_clean;
USE ecommerce_clean;

CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL,
    country VARCHAR(50) NOT NULL,
    registered_date DATE NOT NULL
);

CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    category_name VARCHAR(50) NOT NULL
);

CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    product_name VARCHAR(100) NOT NULL,
    category_id INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
);

CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    status VARCHAR(20) NOT NULL,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
    order_item_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Customers
INSERT INTO customers (first_name, last_name, email, country, registered_date) VALUES
('Alice', 'Brown', 'alice.brown@example.com', 'USA', '2023-01-15'),
('Bob', 'Smith', 'bob.smith@example.com', 'Canada', '2022-11-20'),
('Charlie', 'Davis', 'charlie.davis@example.com', 'USA', '2023-03-05'),
('Dana', 'Wilson', 'dana.wilson@example.com', 'UK', '2023-02-28'),
('Eve', 'Clark', 'eve.clark@example.com', 'USA', '2023-04-10');

-- Categories
INSERT INTO categories (category_name) VALUES
('Electronics'),
('Furniture'),
('Clothing');

-- Products
INSERT INTO products (product_name, category_id, price) VALUES
('Laptop', 1, 999.99),
('Desk Chair', 2, 150.00),
('Smartphone', 1, 599.99),
('T-Shirt', 3, 19.99),
('Bookshelf', 2, 85.50),
('Headphones', 1, 199.99),
('Jeans', 3, 49.99);

-- Orders
INSERT INTO orders (customer_id, order_date, status) VALUES
(1, '2023-07-01', 'Completed'),
(1, '2023-07-15', 'Completed'),
(2, '2023-06-25', 'Completed'),
(3, '2023-07-10', 'Completed'),
(4, '2023-07-12', 'Completed'),
(5, '2023-07-15', 'Completed');

-- Order Items
INSERT INTO order_items (order_id, product_id, quantity, price) VALUES
(1, 1, 1, 999.99),
(1, 4, 3, 19.99),
(2, 3, 1, 599.99),
(3, 2, 2, 150.00),
(4, 5, 1, 85.50),
(4, 6, 1, 199.99),
(5, 7, 2, 49.99),
(6, 1, 1, 999.99);

-- a. Select customers from USA ordered by last name
SELECT first_name, last_name, country
FROM customers
WHERE country = 'USA'
ORDER BY last_name;

-- b. INNER JOIN orders with customers
SELECT o.order_id, c.first_name, c.last_name, o.order_date
FROM orders o
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- c. Subquery: Customers who spent more than average spending
SELECT c.first_name, c.last_name, total_spent
FROM (
    SELECT o.customer_id, SUM(oi.price * oi.quantity) AS total_spent
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
) AS spending
JOIN customers c ON spending.customer_id = c.customer_id
WHERE total_spent > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(oi.price * oi.quantity) AS total
        FROM orders o
        JOIN order_items oi ON o.order_id = oi.order_id
        GROUP BY o.customer_id
    ) AS averages
);

-- d. Aggregate: Average order value by country
SELECT c.country, AVG(order_total) AS avg_order_value
FROM customers c
JOIN (
    SELECT o.customer_id, SUM(oi.price * oi.quantity) AS order_total
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY o.order_id
) AS order_summaries ON c.customer_id = order_summaries.customer_id
GROUP BY c.country;

-- e. Create a view for customer order summary
CREATE VIEW customer_order_summary AS
SELECT c.customer_id, c.first_name, c.last_name, c.country,
       COUNT(DISTINCT o.order_id) AS orders_count,
       SUM(oi.price * oi.quantity) AS total_spent
FROM customers c
LEFT JOIN orders o ON c.customer_id = o.customer_id
LEFT JOIN order_items oi ON o.order_id = oi.order_id
GROUP BY c.customer_id;

-- Query the view
SELECT * FROM customer_order_summary
WHERE total_spent > 500
ORDER BY total_spent DESC;

-- f. Create indexes to optimize queries
CREATE INDEX idx_customers_country ON customers(country);
CREATE INDEX idx_orders_customer ON orders(customer_id);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_order_items_product ON order_items(product_id);



SHOW INDEX FROM customers;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_items;

