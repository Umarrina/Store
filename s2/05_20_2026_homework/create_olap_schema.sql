DROP SCHEMA IF EXISTS olap CASCADE;
CREATE SCHEMA olap;

CREATE TABLE olap.dim_date (
                               date_id     INT PRIMARY KEY,
                               full_date   DATE NOT NULL,
                               year        SMALLINT,
                               quarter     SMALLINT,
                               month       SMALLINT,
                               month_name  VARCHAR(9),
                               day         SMALLINT,
                               day_of_week SMALLINT,
                               is_weekend  BOOLEAN
);

CREATE TABLE olap.dim_product (
                                  product_id    INT PRIMARY KEY,
                                  product_name  VARCHAR(100),
                                  category_id   INT,
                                  category_name VARCHAR(100),
                                  unit_price    INT,
                                  supplier_id   INT,
                                  supplier_name VARCHAR(100)
);

CREATE TABLE olap.dim_customer (
                                   customer_id   INT PRIMARY KEY,
                                   last_name     VARCHAR(50),
                                   first_name    VARCHAR(50),
                                   email         VARCHAR(100),
                                   customer_type VARCHAR(20)
);

CREATE TABLE olap.dim_warehouse (
                                    warehouse_id INT PRIMARY KEY,
                                    name         VARCHAR(31),
                                    address      VARCHAR(200),
                                    manager_name TEXT
);

CREATE TABLE olap.fact_sales (
                                 sale_id      BIGSERIAL PRIMARY KEY,
                                 order_id     INT NOT NULL,
                                 date_id      INT NOT NULL REFERENCES olap.dim_date(date_id),
                                 product_id   INT NOT NULL REFERENCES olap.dim_product(product_id),
                                 customer_id  INT NOT NULL REFERENCES olap.dim_customer(customer_id),
                                 warehouse_id INT REFERENCES olap.dim_warehouse(warehouse_id),
                                 quantity     INT NOT NULL,
                                 revenue      INT NOT NULL
);