-- 1. INNER JOIN (покупатели и их заказы)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer c
                  JOIN warehouse.customer_order o ON c.id = o.customer_id
WHERE c.id BETWEEN 1000 AND 2000;

-- 2. LEFT JOIN (все покупатели, даже без заказов)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer c
                  LEFT JOIN warehouse.customer_order o ON c.id = o.customer_id
WHERE c.id BETWEEN 1000 AND 2000;

-- 3. Тройной JOIN (покупатели → заказы → товары)
EXPLAIN (ANALYZE, BUFFERS)
SELECT * FROM warehouse.customer c
                  JOIN warehouse.customer_order o ON c.id = o.customer_id
                  JOIN warehouse.order_item oi ON o.id = oi.order_id
                  JOIN warehouse.product_catalog p ON oi.product_id = p.id
WHERE c.id BETWEEN 1000 AND 2000;

-- 4. JOIN с агрегацией (сумма заказов по покупателям)
EXPLAIN (ANALYZE, BUFFERS)
SELECT c.id, c.last_name, COUNT(o.id) as order_count
FROM warehouse.customer c
         LEFT JOIN warehouse.customer_order o ON c.id = o.customer_id
GROUP BY c.id, c.last_name
HAVING COUNT(o.id) > 0
    LIMIT 100;

-- 5. Заказы и их платежи (INNER JOIN)
EXPLAIN (ANALYZE, BUFFERS)
SELECT o.id, o.order_date, o.status, p.amount, p.payment_date
FROM warehouse.customer_order o
         JOIN warehouse.payment p ON o.id = p.order_id
WHERE o.id BETWEEN 1000 AND 10000;