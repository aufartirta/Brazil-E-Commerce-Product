--Identify cities with most customers
SELECT customer_city, customer_state, COUNT(customer_unique_id) AS total_customers_per_city
FROM customers
GROUP BY customer_city, customer_state
ORDER BY total_customers_per_city DESC
LIMIT 5; 

--Identify cities with the most sellers
SELECT seller_city, seller_state, COUNT(seller_id) AS total_sellers_per_city
FROM sellers
GROUP BY seller_city, seller_state
ORDER BY total_sellers_per_city DESC
LIMIT 5;

--Identify total orders from every city
SELECT
	c.customer_city,
	c.customer_state,
	COUNT(o.order_id) AS total_order,
	SUM(oi.price) + SUM(oi.freight_value) AS total_order_value,
	SUM(op.payment_value) AS total_payment_value
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN order_payments op ON oi.order_id = op.order_id
GROUP BY 
	c.customer_city,
	c.customer_state
ORDER BY total_order DESC
LIMIT 5;

--Identify the most ordered products; translate to English
SELECT 
	p.product_category_name,
	t.product_category_name_english,
	COUNT(oi.product_id) AS total_order
FROM order_items oi 
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN translations t ON p.product_category_name = t.product_category_name
GROUP BY
	p.product_category_name,
	t.product_category_name_english
ORDER BY total_order DESC
;

--Identify the most popular products based on region
SELECT DISTINCT ON (c.customer_state)
    c.customer_state,
    t.product_category_name_english,
    COUNT(o.order_id) AS total_order
FROM customers c
JOIN orders o ON c.customer_id = o.customer_id
JOIN order_items oi ON o.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN translations t ON p.product_category_name = t.product_category_name
GROUP BY 
    c.customer_state,
    t.product_category_name_english
ORDER BY 
    c.customer_state, 
    COUNT(o.order_id) DESC;


--Identify the categories of order status
SELECT DISTINCT order_status FROM orders;

--Compare order statuses trend over the years
SELECT
	EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
	COUNT(*) AS total_orders,
    COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) AS successful_orders,
	ROUND((COUNT(CASE WHEN order_status = 'delivered' THEN 1 END) * 100.0 / COUNT(*)), 2) AS success_percentage,
	COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) AS canceled_orders,
	ROUND((COUNT(CASE WHEN order_status = 'canceled' THEN 1 END) * 100.0 / COUNT(*)), 2) AS cancel_percentage,
	COUNT(CASE WHEN order_status IN ('shipped', 'processing', 'approved','created', 'invoiced', 'unavailable') THEN 1 END) AS incomplete_orders,
	ROUND((COUNT(CASE WHEN order_status IN ('shipped', 'processing', 'approved','created', 'invoiced', 'unavailable') THEN 1 END) * 100.0 / COUNT(*)), 2) AS incomplete_percentage
FROM orders
GROUP BY EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY year;

--Identify months with highest transactions
SELECT 
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month, 
	EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_payment_value
FROM 
    order_payments
JOIN 
    orders ON order_payments.order_id = orders.order_id
GROUP BY 
    EXTRACT(MONTH FROM order_purchase_timestamp),
	EXTRACT(YEAR FROM order_purchase_timestamp)
ORDER BY 
    total_transactions DESC;

--Identify product volume and compare with product weight and freight value
SELECT
	p.product_id,
	t.product_category_name_english,
	(p.product_length_cm * p.product_height_cm * p.product_width_cm) AS product_volume,
	p.product_weight_g,
	oi.freight_value
FROM products p
JOIN order_items oi
ON p.product_id = oi.product_id
JOIN translations t 
ON p.product_category_name = t.product_category_name
ORDER BY product_volume;

--Identify total order values per product category
--formula: (num of product * price) + (num of product * freight price)

SELECT 
    p.product_category_name,
    t.product_category_name_english,
    SUM(oi.price) + SUM(oi.freight_value) AS total_order_value
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN translations t ON p.product_category_name = t.product_category_name
GROUP BY 
    p.product_category_name,
    t.product_category_name_english
ORDER BY 
    total_order_value DESC;

--Identify products with highest rating
SELECT * FROM order_reviews
WHERE review_score >= 4
ORDER BY review_score DESC;

--Identify percentage of well-reviewed products
SELECT
	COUNT(*) AS total_order,
	(SELECT COUNT (*) FROM order_reviews WHERE review_score >=4) as number_of_good_products,
	ROUND(((SELECT COUNT(*) FROM order_reviews WHERE review_score >=4)*100.0 / COUNT(*)),2) AS good_product_percentage
FROM order_reviews;

--Idenfity high performing product categories
SELECT 
    t.product_category_name_english,
    SUM(r.review_score) AS total_score
FROM order_reviews r
JOIN order_items oi ON r.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN translations t ON p.product_category_name = t.product_category_name
GROUP BY
    t.product_category_name_english
ORDER BY total_score DESC
LIMIT 5;

--Identify high performing sellers
SELECT
	s.seller_id,
	s.seller_city,
	s.seller_state,
	SUM(r.review_score) AS total_score
FROM order_reviews r
JOIN order_items oi ON r.order_id = oi.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY
	s.seller_id,
	s.seller_city,
	s.seller_state
ORDER BY total_score DESC;


--Identify cities with high-performing sellers
SELECT
	s.seller_city,
	s.seller_state,
	SUM(r.review_score) AS total_score
FROM order_reviews r
JOIN order_items oi ON r.order_id = oi.order_id
JOIN sellers s ON oi.seller_id = s.seller_id
GROUP BY	
	s.seller_city,
	s.seller_state
ORDER BY total_score DESC;

--Identify low-performing products
SELECT * FROM order_reviews
WHERE review_score < 3
ORDER BY review_score;

--Identify low-perforing product categories
SELECT 
	p.product_category_name,
	t.product_category_name_english,
	COUNT(oi.product_id) AS total_order,
	SUM(r.review_score) AS total_score
FROM order_reviews r 
JOIN order_items oi ON r.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN translations t ON p.product_category_name = t.product_category_name
GROUP BY
	p.product_category_name,
	t.product_category_name_english
ORDER BY total_score;

