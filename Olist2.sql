SELECT * FROM customers LIMIT 10;
SELECT * FROM sellers LIMIT 10;
SELECT * FROM products LIMIT 10;

SELECT * FROM orders LIMIT 10;
SELECT * FROM order_items LIMIT 10;
SELECT * FROM order_payments LIMIT 10;
SELECT * FROM order_reviews LIMIT 10;

SELECT * FROM geolocation LIMIT 10;
--------------------
SELECT * FROM view_logistics_performance LIMIT 10;
SELECT * FROM view_products_master LIMIT 10;
SELECT * FROM view_geo_clean LIMIT 10;
SELECT * FROM view_shipping_map LIMIT 10;
SELECT * FROM view_customer_feedback LIMIT 10;
---------------------

CREATE OR REPLACE VIEW view_logistics_performance AS
SELECT 
    o.ord_id,
    o.cust_id,
    oi.sell_id, -- Added so you can rank sellers by speed
    o.status,
    o.purchased_at,
    o.delivered_at,
    o.estim_date,
    c.state AS cust_state,
    s.state AS sell_state,
    -- 1. Total Lead Time (Days)
    DATEDIFF(o.delivered_at, o.purchased_at) AS total_lead_time,
    -- 2. Seller Processing Time (Warehouse Speed)
    DATEDIFF(o.carrier_date, o.purchased_at) AS warehouse_time,
    -- 3. Carrier Shipping Time (Last Mile Speed)
    DATEDIFF(o.delivered_at, o.carrier_date) AS shipping_time,
    -- 4. SLA Difference (Positive = Early, Negative = Late)
    DATEDIFF(o.estim_date, o.delivered_at) AS sla_diff,
    CASE 
        WHEN o.delivered_at > o.estim_date THEN 'Late'
        ELSE 'On-Time'
    END AS delivery_status
FROM orders o
JOIN customers c ON o.cust_id = c.cust_id
JOIN order_items oi ON o.ord_id = oi.ord_id
JOIN sellers s ON oi.sell_id = s.sell_id
WHERE o.status = 'delivered' 
  AND o.delivered_at IS NOT NULL 
  AND o.carrier_date IS NOT NULL;


-- First, clean the geo data (average coords per zip)
CREATE OR REPLACE VIEW view_geo_clean AS
SELECT 
	zip, 
	AVG(lat) as lat, 
	AVG(lng) as lng
FROM geolocation
GROUP BY zip;

-- Create the master distance view
CREATE OR REPLACE VIEW view_shipping_map AS
SELECT 
    oi.ord_id,
    s.state AS sell_state,
    c.state AS cust_state,
    sg.lat AS sell_lat, sg.lng AS sell_lng,
    cg.lat AS cust_lat, cg.lng AS cust_lng,
    oi.freight_value,
    oi.price
FROM order_items oi
JOIN sellers s ON oi.sell_id = s.sell_id
JOIN orders o ON oi.ord_id = o.ord_id
JOIN customers c ON o.cust_id = c.cust_id
LEFT JOIN view_geo_clean sg ON s.zip = sg.zip
LEFT JOIN view_geo_clean cg ON c.zip = cg.zip;



CREATE OR REPLACE VIEW view_products_master AS
SELECT 
    oi.ord_id, -- ADDED THIS LINE
    p.prod_id,
    COALESCE(t.cat_name_en, p.cat_name, 'other') AS category,
    p.weight_g,
    ROUND((p.len_cm * p.width_cm * p.height_cm) / 6000.0, 2) AS vol_weight_kg,
    p.photos_qty
FROM products p
JOIN order_items oi ON p.prod_id = oi.prod_id -- JOINED TO ORDER_ITEMS
LEFT JOIN prod_cat_trans t ON p.cat_name = t.cat_name;

SELECT 
    l.ord_id, 
    l.delivery_status, 
    p.category, 
    f.score 
FROM view_logistics_performance l
JOIN view_products_master p ON l.ord_id = p.ord_id
JOIN view_customer_feedback f ON l.ord_id = f.ord_id
LIMIT 10;



-- 1. Create Customer Feedback View
CREATE OR REPLACE VIEW view_customer_feedback AS
SELECT 
    ord_id,
    score,
    DATEDIFF(answered_at, created_at) AS response_time_days
FROM order_reviews;
---------------------
-- 2. Join Logistics, Products, and Feedback Views
SELECT 
    l.ord_id, 
    l.delivery_status, 
    p.category, 
    f.score AS u
FROM view_logistics_performance l
JOIN view_products_master p ON l.ord_id = p.prod_id
JOIN view_customer_feedback f ON l.ord_id = f.ord_id;

-- 3. Row Counts for Each View
SELECT COUNT(*) FROM view_logistics_performance;
SELECT COUNT(*) FROM view_products_master;
SELECT COUNT(*) FROM view_customer_feedback;

-- 4. Sample Left Join with Limit
SELECT l.ord_id, f.score
FROM view_logistics_performance l
LEFT JOIN view_customer_feedback f ON l.ord_id = f.ord_id
LIMIT 10;

