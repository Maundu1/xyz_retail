CREATE TABLE customers (customer_id INT PRIMARY KEY, full_name VARCHAR(100) NOT NULL, email VARCHAR(150) NOT NULL UNIQUE, city VARCHAR(60), 
signup_date DATE NOT NULL, referred_by INT NULL, FOREIGN KEY(referred_by) REFERENCES customers(customer_id));

CREATE TABLE categories (category_id INT PRIMARY KEY, category_name VARCHAR(60) NOT NULL, parent_id INT NULL, FOREIGN KEY(parent_id) 
REFERENCES categories(category_id));

CREATE TABLE products (product_id INT PRIMARY KEY, category_id INT NOT NULL, sku VARCHAR(30) UNIQUE NOT NULL, product_name VARCHAR(100) NOT NULL, 
list_price DECIMAL(12,2) NOT NULL CHECK(list_price>=0), unit_cost DECIMAL(12,2) NOT NULL CHECK(unit_cost>=0), active BOOLEAN NOT NULL DEFAULT TRUE, 
attributes JSON, FOREIGN KEY(category_id) REFERENCES categories(category_id));

CREATE TABLE warehouses (warehouse_id INT PRIMARY KEY, warehouse_name VARCHAR(80) NOT NULL, city VARCHAR(60) NOT NULL);

CREATE TABLE employees (employee_id INT PRIMARY KEY, full_name VARCHAR(100) NOT NULL, manager_id INT NULL, department VARCHAR(50) NOT NULL, 
salary DECIMAL(12,2) NOT NULL, hired_on DATE NOT NULL, FOREIGN KEY(manager_id) REFERENCES employees(employee_id));

CREATE TABLE inventory (warehouse_id INT NOT NULL, product_id INT NOT NULL, quantity INT NOT NULL CHECK(quantity>=0), 
reorder_level INT NOT NULL CHECK(reorder_level>=0), PRIMARY KEY(warehouse_id,product_id), FOREIGN KEY(warehouse_id) REFERENCES 
warehouses(warehouse_id), FOREIGN KEY(product_id) REFERENCES products(product_id));

CREATE TABLE orders (order_id INT PRIMARY KEY AUTO_INCREMENT, customer_id INT NOT NULL, employee_id INT NULL, warehouse_id INT NOT NULL, 
ordered_at DATETIME NOT NULL, status ENUM('pending','paid','shipped','delivered','cancelled') NOT NULL, channel ENUM('web','store','app') NOT NULL,
 FOREIGN KEY(customer_id) REFERENCES customers(customer_id), FOREIGN KEY(employee_id) REFERENCES employees(employee_id), FOREIGN KEY(warehouse_id) 
 REFERENCES warehouses(warehouse_id));
 
CREATE TABLE order_items (order_id INT NOT NULL, product_id INT NOT NULL, quantity INT NOT NULL CHECK(quantity>0), unit_price DECIMAL(12,2) 
NOT NULL CHECK(unit_price>=0), discount_pct DECIMAL(5,2) NOT NULL DEFAULT 0 CHECK(discount_pct BETWEEN 0 AND 100), cost_at_sale DECIMAL(12,2) 
NOT NULL CHECK(cost_at_sale>=0), PRIMARY KEY(order_id,product_id), FOREIGN KEY(order_id) REFERENCES orders(order_id), FOREIGN KEY(product_id) 
REFERENCES products(product_id));

CREATE TABLE payments (payment_id INT PRIMARY KEY AUTO_INCREMENT, order_id INT NOT NULL, paid_at DATETIME NOT NULL, amount DECIMAL(12,2) 
NOT NULL CHECK(amount>0), method ENUM('card','cash','mobile','bank') NOT NULL, status ENUM('successful','failed','pending') NOT NULL, 
FOREIGN KEY(order_id) REFERENCES orders(order_id));

CREATE TABLE returns_log (return_id INT PRIMARY KEY AUTO_INCREMENT, order_id INT NOT NULL, product_id INT NOT NULL, returned_at DATETIME NOT NULL, 
quantity INT NOT NULL CHECK(quantity>0), reason VARCHAR(100) NOT NULL, status ENUM('requested','approved','rejected') NOT NULL, 
FOREIGN KEY(order_id,product_id) REFERENCES order_items(order_id,product_id));

CREATE TABLE shipments (shipment_id INT PRIMARY KEY AUTO_INCREMENT, order_id INT NOT NULL UNIQUE, shipped_at DATETIME NOT NULL, 
delivered_at DATETIME NULL, carrier VARCHAR(60) NOT NULL, FOREIGN KEY(order_id) REFERENCES orders(order_id));

CREATE TABLE price_audit (audit_id BIGINT PRIMARY KEY AUTO_INCREMENT, product_id INT NOT NULL, old_price DECIMAL(12,2) NOT NULL, 
new_price DECIMAL(12,2) NOT NULL, changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP, changed_by VARCHAR(255) NOT NULL);

CREATE TABLE customer_import (row_id INT PRIMARY KEY, raw_name VARCHAR(100), raw_email VARCHAR(150), raw_city VARCHAR(60), raw_signup VARCHAR(30));