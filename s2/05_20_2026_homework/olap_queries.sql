
SELECT
    d.year,
    d.month,
    d.month_name,
    p.category_name,
    SUM(f.revenue) AS total_revenue,
    COUNT(DISTINCT f.order_id) AS order_count,
    SUM(f.quantity) AS items_sold
FROM olap.fact_sales f
         JOIN olap.dim_date d ON f.date_id = d.date_id
         JOIN olap.dim_product p ON f.product_id = p.product_id
GROUP BY d.year, d.month, d.month_name, p.category_name
ORDER BY d.year, d.month, total_revenue DESC
    LIMIT 20;


SELECT
    c.customer_id,
    c.last_name || ' ' || c.first_name AS customer_name,
    c.customer_type,
    SUM(f.revenue) AS total_spent,
    COUNT(DISTINCT f.order_id) AS orders_count
FROM olap.fact_sales f
         JOIN olap.dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.last_name, c.first_name, c.customer_type
ORDER BY total_spent DESC
    LIMIT 10;


SELECT
    CASE WHEN d.is_weekend THEN 'Weekend' ELSE 'Weekday' END AS day_type,
    AVG(f.revenue) AS avg_revenue,
    SUM(f.revenue) AS total_revenue,
    COUNT(*) AS total_sales_events
FROM olap.fact_sales f
         JOIN olap.dim_date d ON f.date_id = d.date_id
GROUP BY d.is_weekend;


WITH monthly AS (
    SELECT
        p.category_name,
        d.year,
        d.month,
        SUM(f.revenue) AS revenue
    FROM olap.fact_sales f
             JOIN olap.dim_date d ON f.date_id = d.date_id
             JOIN olap.dim_product p ON f.product_id = p.product_id
    GROUP BY p.category_name, d.year, d.month
),
     prev AS (
         SELECT
             category_name,
    year,
    month,
    revenue,
    LAG(revenue) OVER (PARTITION BY category_name ORDER BY year, month) AS prev_revenue
FROM monthly
    )
SELECT
    category_name,
    year,
    month,
    revenue,
    prev_revenue,
    ROUND(100.0 * (revenue - prev_revenue) / prev_revenue, 2) AS growth_percent
FROM prev
WHERE prev_revenue IS NOT NULL
ORDER BY growth_percent ASC
    LIMIT 10;