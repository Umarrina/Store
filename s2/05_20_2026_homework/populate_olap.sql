-- Индекс для ускорения rate_customer
CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_customer_order_customer_id
    ON warehouse.customer_order(customer_id);


INSERT INTO olap.dim_date (date_id, full_date, year, quarter, month, month_name, day, day_of_week, is_weekend)
SELECT
    TO_CHAR(d, 'YYYYMMDD')::INT, d,
    EXTRACT(YEAR FROM d)::SMALLINT,
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(MONTH FROM d)::SMALLINT,
    TO_CHAR(d, 'Month'),
    EXTRACT(DAY FROM d)::SMALLINT,
    EXTRACT(DOW FROM d)::SMALLINT,
    EXTRACT(DOW FROM d) IN (0,6)
FROM generate_series(
             (SELECT MIN(order_date) FROM warehouse.customer_order),
             (SELECT MAX(order_date) FROM warehouse.customer_order),
             '1 day'
     ) AS d;

INSERT INTO olap.dim_product (product_id, product_name, category_id, category_name, unit_price, supplier_id, supplier_name)
SELECT
    pc.id, pc.name, pc.category_id, pc_cat.name, pc.unit_price, pc.supplier_id, s.organization_name
FROM warehouse.product_catalog pc
         LEFT JOIN warehouse.product_category pc_cat ON pc.category_id = pc_cat.id
         LEFT JOIN warehouse.supplier s ON pc.supplier_id = s.id;

INSERT INTO olap.dim_customer (customer_id, last_name, first_name, email, customer_type)
SELECT id, last_name, first_name, email, warehouse.rate_customer(id)
FROM warehouse.customer;

INSERT INTO olap.dim_warehouse (warehouse_id, name, address, manager_name)
SELECT w.id, w.name, w.address, CONCAT(m.last_name, ' ', m.first_name)
FROM warehouse.warehouse w
         LEFT JOIN warehouse.manager m ON w.manager_id = m.id;

DO $$
    DECLARE
        batch_size INT := 100000;
        offset_val INT := 0;
        total_rows INT;
    BEGIN
        SELECT COUNT(*) INTO total_rows FROM warehouse.order_item;
        RAISE NOTICE 'Всего строк для вставки: %', total_rows;

        WHILE offset_val < total_rows LOOP
                RAISE NOTICE 'Вставка строк с % по %', offset_val + 1, LEAST(offset_val + batch_size, total_rows);

                INSERT INTO olap.fact_sales (order_id, date_id, product_id, customer_id, warehouse_id, quantity, revenue)
                SELECT
                    oi.order_id,
                    TO_CHAR(co.order_date, 'YYYYMMDD')::INT,
                    oi.product_id,
                    co.customer_id,
                    e.warehouse_id,
                    oi.quantity,
                    oi.quantity * pc.unit_price
                FROM warehouse.order_item oi
                         JOIN warehouse.product_catalog pc ON oi.product_id = pc.id
                         JOIN warehouse.customer_order co ON oi.order_id = co.id
                         LEFT JOIN warehouse.employee e ON co.employee_id = e.id
                WHERE co.order_date IS NOT NULL
                ORDER BY oi.order_id
                LIMIT batch_size OFFSET offset_val;

                offset_val := offset_val + batch_size;
                COMMIT;
            END LOOP;
    END $$;