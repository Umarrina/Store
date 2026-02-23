ALTER TABLE warehouse.customer_order
    ADD COLUMN order_date DATE DEFAULT CURRENT_DATE,
    ADD COLUMN status TEXT;

ALTER TABLE warehouse.order_item
    ADD COLUMN isCollect BOOLEAN,
    ADD COLUMN notes TEXT;

ALTER TABLE warehouse.payment
    ADD COLUMN created_at TIMESTAMP DEFAULT NOW();

ALTER TABLE warehouse.payment_status
    ADD COLUMN description TEXT,
    ADD COLUMN created_at TIMESTAMP DEFAULT NOW(),
    ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

ALTER TABLE warehouse.product_category
    ADD COLUMN description TEXT,
    ADD COLUMN created_at TIMESTAMP DEFAULT NOW(),
    ADD COLUMN is_active BOOLEAN DEFAULT TRUE;

ALTER TABLE warehouse.product_inventory
    ADD COLUMN last_updated TIMESTAMP DEFAULT NOW(),
    ADD COLUMN notes TEXT;

ALTER TABLE warehouse.supplier
    ADD COLUMN email VARCHAR(255),
    ADD COLUMN notes TEXT;

ALTER TABLE warehouse.warehouse
    ADD COLUMN name VARCHAR(31),
    ADD COLUMN notes TEXT;

ALTER TABLE warehouse.customer
    ADD COLUMN preferences JSONB,
    ADD COLUMN location POINT,
    ADD COLUMN tags TEXT[];

ALTER TABLE warehouse.product_catalog
    ADD COLUMN description TEXT,
    ADD COLUMN attributes JSONB,
    ADD COLUMN dimensions INT4RANGE;