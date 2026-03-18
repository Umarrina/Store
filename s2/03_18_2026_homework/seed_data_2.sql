INSERT INTO warehouse.product_category (id, name, description, created_at, is_active)
VALUES
    (6, 'Напитки', 'Соки, воды, газировка', NOW(), true),
    (7, 'Заморозка', 'Овощные смеси, мороженое', NOW(), true)
    ON CONFLICT (id) DO NOTHING;

INSERT INTO warehouse.product_catalog (id, name, category_id, unit_price, description)
VALUES
    (2250005, 'Тестовый товар 1', 6, 150, 'Создан seed_extra'),
    (2250006, 'Тестовый товар 2', 7, 320, 'Создан seed_extra')
ON CONFLICT (id) DO NOTHING;