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

We can see the dominance of São Paulo, Rio de Janeiro, Belo Horizonte, and Curitiba.

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
sao paulo|SP|18590|2275610.60|2839903.47
rio de janeiro|RJ|8202	1201226.5500000168	1566591.4899999963
belo horizonte|MG|3247	430460.59999999555	501261.5000000003
brasilia|DF|2457	364115.1599999979	430499.4299999996
curitiba|PR|1809	252659.5399999994	329321.5399999998

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
While freight value is calculated based on the product's weight and measurement, in this dataset the freight values are already provided.

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

```sql
--Identify The Most Common Type of Payment
SELECT
	payment_type,
	COUNT(*) AS amount,
	ROUND(SUM(payment_value::INTEGER), 2) AS total_value
FROM order_payments
GROUP BY payment_type
ORDER BY amount DESC;
```
Result:
|payment_type|amount|total_value
|---|---|---|
credit_card|76795|12542393.00
boleto|19784|2869488.00
voucher|5775|379391.00
debit_card|1529|218002.00
not_defined|3|0.00

