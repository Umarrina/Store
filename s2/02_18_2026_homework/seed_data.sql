INSERT INTO warehouse.product_category (id, name, description, created_at, is_active) VALUES
    (1, 'бакалея', 'крупы, приправы, консервы', NOW(), true),
    (2, 'мясо', 'вырезки и части домашнего скота и диких животных', NOW(), true),
    (3, 'фрукты', 'ягоды, цитросувые, фрукты', NOW(), true),
    (4, 'овощи', 'свежие овощи', NOW(), true),
    (5, 'молочная продукция', 'молоко и его производные', NOW(), true)
    ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse.payment_status (id, status, description, created_at, is_active) VALUES
    (1, 'Pending', 'Ожидание оплаты', NOW(), true),
    (2, 'Paid', 'Оплачено', NOW(), true),
    (3, 'Failed', 'Ошибка оплаты', NOW(), true),
    (4, 'Refunded', 'Возврат', NOW(), true)
    ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse.supplier (id, organization_name, phone, email, notes) VALUES
    (1, 'ООО_Мясо', '+79991234567', 'example1@example.com', 'Мясная продукция'),
    (2, 'ООО_Ферма', '+79999874567', 'example2@example.com', 'Молочная продукция и бакалея'),
    (3, 'ООО_Сад', '+79963234567', 'example3@example.com', 'Овощи, фрукты')
    ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse.manager (id, last_name, first_name, gender) VALUES
    (1, 'Иванов', 'Иван', 'M'),
    (2, 'Петров', 'Мария', 'F')
    ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse.warehouse (id, address, manager_id, name, notes) VALUES
    (1, 'г. Новосибирск, ул. Красноармейская, д. 43', '2', 'Central Warehouse', 'Главный склад'),
    (2, 'г. Рязань, ул. Сибирская, д. 32', '1', 'Second Warehouse', 'Второй склад')
    ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse.employee (id, warehouse_id, last_name, first_name, gender, birth_date) VALUES
    (1, 1, 'Смирнов', 'Алексей', 'M', '1990-01-01'),
    (2, 2, 'Кузнецова', 'Елена', 'F', '1985-05-05')
    ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse.customer (
                                id, last_name, first_name, patronymic, email,
                                preferences, location, tags
)
SELECT
    nextval('warehouse.customer_id_seq'),
    'LastName_' || gs,
    'FirstName_' || gs,
    CASE WHEN random() < 0.2 THEN NULL ELSE 'Patronymic_' || gs END,
    'user' || gs || '@example.com',
    jsonb_build_object(
        'newsletter', random() < 0.5,
        'theme', case WHEN random() < 0.5 THEN 'dark' ELSE 'light' END
    ),
    point ((random() * 180 - 90) :: numeric, (random() * 360 - 180) :: numeric),
    ARRAY[CASE WHEN random() < 0.3 THEN 'vip' ELSE 'regular' END]
FROM generate_series(1, 250000) gs;

INSERT INTO warehouse.product_catalog (
                                       id, name, category_id, unit_price, unit_of_measure, supplier_id,
                                       description, attributes, dimensions
)
SELECT
    nextval('warehouse.product_catalog_id_seq'),
    'Product_' || gs,
    floor(random() * 5 + 1)::int,
    (random() * 1000) :: int,
    CASE WHEN random() < 0.5 THEN 'pcs' ELSE 'kg' END,
    floor(random() * 3 + 1)::int,
    CASE
        WHEN random() < 0.15 THEN NULL
        ELSE 'Description for product ' || gs || '. ' || repeat('text ', 20)
    END,
    jsonb_build_object(
            'color', CASE WHEN random() < 0.33 THEN 'red' WHEN random() < 0.66 THEN 'green' ELSE 'blue' END,
            'weight', (random()*10)::numeric(5,2)
    ),
    int4range((random()*100)::int, (random()*200+100)::int)
FROM generate_series(1, 250000) gs;

INSERT INTO warehouse.customer_order (
                                      id, customer_id, employee_id,
                                      order_date, status
)
SELECT
    nextval('warehouse.customer_order_id_seq'),
    CASE
        WHEN random() < 0.7 THEN floor(random() * 25000 + 1) :: int
        ELSE floor(random() * (250000 - 25000) + 25001) :: int
    END,
    floor(random() * 2 + 1) :: int,
    CURRENT_DATE - (random() * 180) :: int,
    CASE
        WHEN random() < 0.4 THEN 'pending'
        WHEN random() < 0.7 THEN 'paid'
        WHEN random() < 0.9 THEN 'shipped'
        ELSE 'delivered'
    END
FROM generate_series(1, 250000) gs;

WITH order_range AS (
    SELECT min(id) as min_id, max(id) as max_id FROM warehouse.customer_order
)
INSERT INTO warehouse.order_item (
    order_id, product_id, quantity,
    isCollect, notes
)
SELECT
    floor(random() * (max_id - min_id + 1) + min_id)::int,
    floor(random() * 250000 + 1)::int,
    floor(random() * 5 + 1)::int,
    random() < 0.2,
    CASE WHEN random() < 0.1 THEN 'urgent' ELSE NULL END
FROM generate_series(1, 1000000) gs, order_range
    ON CONFLICT (order_id, product_id) DO NOTHING;

INSERT INTO warehouse.payment (
    order_id, amount, status, payment_date, created_at
)
SELECT
    id,
    COALESCE((
        SELECT sum(quantity * pc.unit_price)
            FROM warehouse.order_item oi
            JOIN warehouse.product_catalog pc ON oi.product_id = pc.id
        WHERE oi.order_id = co.id
    ), 0) AS amount,
    CASE
        WHEN co.status IN ('paid', 'shipped', 'delivered') THEN 2
        ELSE 1
        END,
    co.order_date,
    NOW()
FROM warehouse.customer_order co
    ON CONFLICT (order_id) DO NOTHING;