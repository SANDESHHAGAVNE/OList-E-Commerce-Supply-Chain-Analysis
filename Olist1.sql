CREATE DATABASE `OList E-commerce Supply Chain`;

-- 1. Create Category Translation Table
CREATE TABLE product_category_name_trans (
    product_category_name VARCHAR(100) PRIMARY KEY,
    product_category_name_english VARCHAR(100)
);

-- 2. Create Products Table
CREATE TABLE products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100) REFERENCES prod_cat_trans(product_category_name),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g DECIMAL,
    product_length_cm DECIMAL,
    product_height_cm DECIMAL,
    product_width_cm DECIMAL
);

-- 3. Create Customers Table
CREATE TABLE customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix VARCHAR(10),
    customer_city VARCHAR(100),
    customer_state CHAR(2)
);

-- 4. Create Sellers Table
CREATE TABLE sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix VARCHAR(10),
    seller_city VARCHAR(100),
    seller_state CHAR(2)
);

-- 5. Create Orders Table
CREATE TABLE orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50) REFERENCES customers(customer_id),
    order_status VARCHAR(20),
    order_purchase_timestamp TIMESTAMP,
    order_approved_at TIMESTAMP,
    order_delivered_carrier_date TIMESTAMP,
    order_delivered_customer_date TIMESTAMP,
    order_estimated_delivery_date TIMESTAMP
);

-- 6. Create Order Items Table (Fact Table)
CREATE TABLE order_items (
    order_id VARCHAR(50) REFERENCES orders(order_id),
    order_item_id INT,
    product_id VARCHAR(50) REFERENCES products(product_id),
    seller_id VARCHAR(50) REFERENCES sellers(seller_id),
    shipping_limit_date TIMESTAMP,
    price DECIMAL(10, 2),
    freight_value DECIMAL(10, 2),
    PRIMARY KEY (order_id, order_item_id)
);

-- 7. Create Order Payments Table
CREATE TABLE order_payments (
    order_id VARCHAR(50) REFERENCES orders(order_id),
    payment_sequential INT,
    payment_type VARCHAR(20),
    payment_installments INT,
    payment_value DECIMAL(10, 2)
);

-- 8. Create Order Reviews Table
CREATE TABLE order_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50) REFERENCES orders(order_id),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

-- 9. Create Geolocation Table (No PK as zip codes repeat)
CREATE TABLE geolocation (
    geolocation_zip_code_prefix VARCHAR(10),
    geolocation_lat DECIMAL,
    geolocation_lng DECIMAL,
    geolocation_city VARCHAR(100),
    geolocation_state CHAR(2)
);

ALTER TABLE product_category_name_trans
RENAME TO prod_cat_trans;


LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_customers_dataset.csv'
INTO TABLE customers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_geolocation_dataset.csv'
INTO TABLE geolocation
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_orders_dataset.csv'
INTO TABLE orders
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/product_category_name_translation.csv'
INTO TABLE prod_cat_trans
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_products_dataset.csv'
INTO TABLE products
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_sellers_dataset.csv'
INTO TABLE sellers
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_order_payments_dataset.csv'
INTO TABLE order_payments
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


CREATE TABLE order_reviews_temp (
    review_id VARCHAR(50),
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date TIMESTAMP,
    review_answer_timestamp TIMESTAMP
);

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_order_reviews_dataset.csv'
INTO TABLE order_reviews_temp
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

LOAD DATA LOCAL INFILE
'E:/SQL/OList E-commerce Supply Chain Analysis/olist_order_items_dataset.csv'
INTO TABLE order_items
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;


select * from order_reviews;
select * from order_reviews_temp;


-- Step 1: Disable strict mode/zero-date checks for your current session
SET SESSION sql_mode = '';

-- Step 2: Run your insert query again
INSERT IGNORE INTO order_reviews ( 
    review_id, 
    order_id, 
    review_score, 
    review_comment_title, 
    review_comment_message, 
    review_creation_date, 
    review_answer_timestamp 
) 
SELECT 
    review_id, 
    order_id, 
    review_score, 
    review_comment_title, 
    review_comment_message, 
    review_creation_date, 
    review_answer_timestamp 
FROM ( 
    SELECT *, 
           ROW_NUMBER() OVER ( 
               PARTITION BY review_id 
               ORDER BY review_creation_date 
           ) AS rn 
    FROM order_reviews_temp 
) AS temp 
WHERE rn = 1;

-- (Optional) Step 3: Reset sql_mode back to default once done
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,NO_ENGINE_SUBSTITUTION';




DROP TABLE order_reviews_temp;

SELECT * FROM prod_cat_trans;

INSERT INTO prod_cat_trans (product_category_name, product_category_name_english)
VALUES 
    ('pc_gamer', 'pc_gamer'),
    ('portateis_cozinha_e_preparadores_de_alimentos', 'kitchen_portables_and_food_preparers');



-- 1. Table: product_category_name_trans
ALTER TABLE prod_cat_trans RENAME COLUMN product_category_name TO cat_name;
ALTER TABLE prod_cat_trans RENAME COLUMN product_category_name_english TO cat_name_en;

-- 2. Table: products
ALTER TABLE products RENAME COLUMN product_id TO prod_id;
ALTER TABLE products RENAME COLUMN product_category_name TO cat_name;
ALTER TABLE products RENAME COLUMN product_name_lenght TO name_len;
ALTER TABLE products RENAME COLUMN product_description_lenght TO desc_len;
ALTER TABLE products RENAME COLUMN product_photos_qty TO photos_qty;
ALTER TABLE products RENAME COLUMN product_weight_g TO weight_g;
ALTER TABLE products RENAME COLUMN product_length_cm TO len_cm;
ALTER TABLE products RENAME COLUMN product_height_cm TO height_cm;
ALTER TABLE products RENAME COLUMN product_width_cm TO width_cm;

-- 3. Table: customers
ALTER TABLE customers RENAME COLUMN customer_id TO cust_id;
ALTER TABLE customers RENAME COLUMN customer_unique_id TO unique_id;
ALTER TABLE customers RENAME COLUMN customer_zip_code_prefix TO zip;
ALTER TABLE customers RENAME COLUMN customer_city TO city;
ALTER TABLE customers RENAME COLUMN customer_state TO state;

-- 4. Table: sellers
ALTER TABLE sellers RENAME COLUMN seller_id TO sell_id;
ALTER TABLE sellers RENAME COLUMN seller_zip_code_prefix TO zip;
ALTER TABLE sellers RENAME COLUMN seller_city TO city;
ALTER TABLE sellers RENAME COLUMN seller_state TO state;

-- 5. Table: orders
ALTER TABLE orders RENAME COLUMN order_id TO ord_id;
ALTER TABLE orders RENAME COLUMN customer_id TO cust_id;
ALTER TABLE orders RENAME COLUMN order_status TO status;
ALTER TABLE orders RENAME COLUMN order_purchase_timestamp TO purchased_at;
ALTER TABLE orders RENAME COLUMN order_approved_at TO approved_at;
ALTER TABLE orders RENAME COLUMN order_delivered_carrier_date TO carrier_date;
ALTER TABLE orders RENAME COLUMN order_delivered_customer_date TO delivered_at;
ALTER TABLE orders RENAME COLUMN order_estimated_delivery_date TO estim_date;

-- 6. Table: order_items
ALTER TABLE order_items RENAME COLUMN order_id TO ord_id;
ALTER TABLE order_items RENAME COLUMN order_item_id TO item_id;
ALTER TABLE order_items RENAME COLUMN product_id TO prod_id;
ALTER TABLE order_items RENAME COLUMN seller_id TO sell_id;
ALTER TABLE order_items RENAME COLUMN shipping_limit_date TO ship_limit;

-- 7. Table: order_payments
ALTER TABLE order_payments RENAME COLUMN order_id TO ord_id;
ALTER TABLE order_payments RENAME COLUMN payment_sequential TO pay_seq;
ALTER TABLE order_payments RENAME COLUMN payment_type TO pay_type;
ALTER TABLE order_payments RENAME COLUMN payment_installments TO installments;
ALTER TABLE order_payments RENAME COLUMN payment_value TO pay_val;

-- 8. Table: order_reviews
ALTER TABLE order_reviews RENAME COLUMN review_id TO rev_id;
ALTER TABLE order_reviews RENAME COLUMN order_id TO ord_id;
ALTER TABLE order_reviews RENAME COLUMN review_score TO score;
ALTER TABLE order_reviews RENAME COLUMN review_comment_title TO title;
ALTER TABLE order_reviews RENAME COLUMN review_comment_message TO message;
ALTER TABLE order_reviews RENAME COLUMN review_creation_date TO created_at;
ALTER TABLE order_reviews RENAME COLUMN review_answer_timestamp TO answered_at;

-- 9. Table: geolocation
ALTER TABLE geolocation RENAME COLUMN geolocation_zip_code_prefix TO zip;
ALTER TABLE geolocation RENAME COLUMN geolocation_lat TO lat;
ALTER TABLE geolocation RENAME COLUMN geolocation_lng TO lng;
ALTER TABLE geolocation RENAME COLUMN geolocation_city TO city;
ALTER TABLE geolocation RENAME COLUMN geolocation_state TO state;










