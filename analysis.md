## Product Trends & Analysis - Brazil E-commerce
Author: Aufar Tirta

### 1. Customers & Sellers Profile
```sql
--Identify cities with the most customers
SELECT customer_city, customer_state, COUNT(customer_unique_id) AS total_customers_per_city
FROM customers
GROUP BY customer_city, customer_state
ORDER BY total_customers_per_city DESC
LIMIT 5; 
```
Result:
|customer_city|customer_state|total_orders_per_city|
|---|---|---|
sao paulo|SP|15540
rio de janeiro|RJ|6882
belo horizonte|MG|2773
brasilia|DF|2131
curitiba|PR|1521

```sql
--Identify cities with the most sellers
SELECT seller_city, seller_state, COUNT(seller_id) AS total_sellers_per_city
FROM sellers
GROUP BY seller_city, seller_state
ORDER BY total_sellers_per_city DESC
LIMIT 5;
```
Result:
|seller_city|seller_state|total_sellers_per_city|
|---|---|---|
sao paulo|SP|694
curitiba|PR|124
rio de janeiro|RJ|93
belo horizonte|MG|66
ribeirao preto|SP|52

We can see the dominance of São Paulo, Rio de Janeiro, Belo Horizonte, and Curitiba. This result is also consistent with the findings of top city with the most orders below.

```sql
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
```
Result:
|customer_city|customer_state|total_order|total_order_value|total_payment_value
|---|---|---|---|---|
sao paulo|SP|18590|2275610.60|2839903.47
rio de janeiro|RJ|8202|1201226.55|1566591.48
belo horizonte|MG|3247|430460.59|501261.50
brasilia|DF|2457|364115.15|430499.42
curitiba|PR|1809|252659.53|329321.53

São Paulo, Rio de Janeiro, Belo Horizonte, and Curitiba remain at the top cities with the most orders and transactions. Brasilia, while lacking numbers in total sellers, is in the top 5 cities with the most customers. 

### 2. Products Profile
```sql
--Identify the most ordered products; translate to English
SELECT 
	p.product_category_name,
	t.product_category_name_english,
	COUNT(oi.product_id) AS total_order
FROM order_items oi 
JOIN products p ON oi.product_id = p.product_id
JOIN translations t ON p.product_category_name = t.product_category_name
GROUP BY
	p.product_category_name,
	t.product_category_name_english
ORDER BY total_order DESC
LIMIT 10;
```
Result:
|product_category_name|product_category_name_english|total_order|
|---|---|---|
cama_mesa_banho|bed_bath_table|11115
beleza_saude|health_beauty|9670
esporte_lazer|sports_leisure|8641
moveis_decoracao|furniture_decor|8334
informatica_acessorios|computers_accessories|7827
utilidades_domesticas|housewares|6964
relogios_presentes|watches_gifts|5991
telefonia|telephony|4545
ferramentas_jardim|garden_tools|4347
automotivo|auto|4235

Top-selling product categories are bed bath table, health beauty, sports leisure, furniture decor, and computers accessories.

```sql
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
```
Top-selling products per region were identified; the results correlate with the previous table about overall top-selling products.

### 3. Order & Delivery
```sql
--Identify the categories of order status
SELECT DISTINCT order_status FROM orders;
```
Result:
|order_status|
|---|
shipped
unavailable
invoiced
created
approved
processing
delivered
canceled

There are 8 different order statuses based on the final stage of product delivery. The product orders are either delivered, cancelled, or incomplete. Next, we compare the percentage of each category.

```sql
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
```
Result:
|year|total_orders|succesful_orders|succesful_percentage|canceled_order|cancel_percentage|incomplete_orders|incomplete_percentage|
|---|---|---|---|---|---|---|---|
2016|329|267|81.16|26|7.90|36|10.94
2017|45101|43428|96.29|265|0.59|1408|3.12
2018|54011|52783|97.73|334|0.62|894|1.66

Over the years, the majority of orders have been successfully delivered to the customers. The percentage of canceled and incomplete orders is significantly lower than the percentage of successful orders.

```sql
--Identify months with highest transactions
SELECT 
    EXTRACT(MONTH FROM order_purchase_timestamp) AS month, 
	EXTRACT(YEAR FROM order_purchase_timestamp) AS year,
    payment_type,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_payment_value
FROM 
    order_payments
JOIN 
    orders ON order_payments.order_id = orders.order_id
GROUP BY 
    EXTRACT(MONTH FROM order_purchase_timestamp),
	EXTRACT(YEAR FROM order_purchase_timestamp),
	payment_type
ORDER BY 
    total_transactions DESC;
```
The number of transactions generally increases over time. However, the number of transactions peaked in November 2017, which is possibly linked to promotional events such as Black Friday.

```sql
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
ON p.product_category_name = t.product_category_name;
```
While freight value is calculated based on the product's weight and measurement, freight values are already provided in this dataset.

```sql
--Identify Total Order Values per Product Category
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
    total_order_value DESC
LIMIT 10;
```
Result:
|product_category_name|product_category_name_english|total_order_value|
|---|---|---|
beleza_saude|health_beauty|1441248.069
relogios_presentes|watches_gifts|1305541.61
cama_mesa_banho|bed_bath_table|1241681.72
esporte_lazer|sports_leisure|1156656.48
informatica_acessorios|computers_accessories|1059272.40
moveis_decoracao|furniture_decor|902511.79
utilidades_domesticas|housewares|778397.77
cool_stuff|cool_stuff|719329.95
automotivo|auto|685384.32
ferramentas_jardim|garden_tools|584219.21

The total order value is calculated by multiplying the number of products by the sum of their price and freight cost. As shown in the table above, the product categories with the highest order values are health beauty, watches gifts, bed bath table, sports leisure, and computer accessories. When compared to the previous table displaying the most ordered products, many of these categories reappear, indicating that they are both top-selling and highly profitable.

### 4. Product Ratings & Performances
```sql
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
```
Result:
|total_order|number_of_good_products|good_product_percentage
|---|---|---|
99224|76470|77.07

Overall, 77.07% of products sold are well-reviewed (>4 scores).

```sql
--Identify high performing product categories
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
```
Result:
|product_category_name_english|total_score
|---|---|
bed_bath_table|43386
health_beauty|39957
sports_leisure|35493
furniture_decor|32520
computers_accessories|30853

Total scores were calculated for each product category. Top reviewed product categories bed bath table, health beauty, sports leisure, furniture decor, and computer accessories.

```sql
--Identify high-performing sellers
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
ORDER BY total_score DESC
LIMIT 5;
```
Result:
|seller_city|seller_state|total_score
|---|---|---|
sao paulo|SP|111989
ibitinga|SP|29567
curitiba|PR|12500
santo andre|SP|12284
sao jose do rio preto|SP|10251

Cities with high-rated sellers are São Paulo, Ibtinga, Curitiba, Santo André, and São José do Rio Preto.

```sql
--Identify low-perforing product categories
SELECT 
	t.product_category_name_english,
	COUNT(oi.product_id) AS total_order,
	SUM(r.review_score) AS total_score
FROM order_reviews r 
JOIN order_items oi ON r.order_id = oi.order_id
JOIN products p ON oi.product_id = p.product_id
LEFT JOIN translations t ON p.product_category_name = t.product_category_name
GROUP BY
	t.product_category_name_english
ORDER BY total_score
LIMIT 10;
```
Result:
|product_category_name_english|total_order|total_score
|---|---|---|
security_and_services|2|5
pc_games|9|30
fashion_childrens_clothes|8|36
portable_kitchen_food_preparations|15|49
la_cuisine|13|52
cds_dvds_musicals|14|65
home_comfort_2|27|98
arts_and_craftmanship|24|99
diapers_and_hygiene|39|127
fashion_sport|31|132

Lowest-performing products were identified. Products with the lowest scores are also products with the least sales. Among them are security and services, pc games, fashion children clothes, portable kitchen and food preparations, and la cuisine.
