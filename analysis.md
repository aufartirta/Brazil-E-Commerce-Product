```sql
/*CUSTOMERS*/

--Identify cities with most orders
SELECT customer_city, customer_state, COUNT(customer_id) AS total_orders_per_city FROM customers
GROUP BY customer_city, customer_state
ORDER BY total_orders_per_city DESC
LIMIT 5;
```
|customer_city|customer_state|total_orders_per_city|
|---|---|---|
sao paolo|SP|15540
rio de janeiro|RJ|6882
belo horizonte|MG|2773
brasilia|DF|2131
curitiba|PR|1521


