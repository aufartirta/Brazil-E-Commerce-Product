```sql
--Identify cities with the most orders
SELECT customer_city, customer_state, COUNT(customer_id) AS total_orders_per_city FROM customers
GROUP BY customer_city, customer_state
ORDER BY total_orders_per_city DESC
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
SELECT seller_city, seller_state, COUNT(seller_id) AS total_sellers_per_city FROM sellers
GROUP BY seller_city, seller_state
ORDER BY total_sellers_per_city DESC
LIMIT 5;
```
Result:
|seller_city|seller_state|total_sellers_per_city|
|---|---|---|
sao paulo|SP|15540
curitiba|PR|124
rio de janeiro|RJ|93
belo horizonte|MG|66
ribeirao preto|SP|52

We can see the dominance of São Paulo, Rio de Janeiro, Belo Horizonte, and Curitiba.

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
ORDER BY total_order DESC;
```
Result:
|product_category_name|product_category_name|total_order|
|---|---|---|
moveis_decoracao|furniture_decor|527
cama_mesa_banho|bed_bath_table|488
ferramentas_jardim|garden_tools|484
ferramentas_jardim|garden_tools|392
ferramentas_jardim|garden_tools|388
ferramentas_jardim|garden_tools|373
informatica_acessorios|computers_accessories|343
relogios_presentes|watches_gifts|323
beleza_saude|health_beautfy|281
informatica_acessorios|computers_accessories|274

Top-selling products are furniture decor, bed bath table, garden tools, computer accessories, watches gifts, and health beauty. Duplicated category names mean they are different products that falls into the same product category.

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

