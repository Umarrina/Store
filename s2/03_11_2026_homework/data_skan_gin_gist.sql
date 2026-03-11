--GIN
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE preferences ? 'newsletter';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE preferences @> '{"theme": "dark"}';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE tags && ARRAY['vip'];

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE attributes @> '{"color": "red"}';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE attributes ? 'color';

CREATE INDEX idx_customer_preferences_gin ON warehouse.customer USING gin (preferences);
CREATE INDEX idx_customer_tags_gin ON warehouse.customer USING gin (tags);
CREATE INDEX idx_product_attributes_gin ON warehouse.product_catalog USING gin (attributes);

DROP INDEX IF EXISTS warehouse.idx_customer_preferences_gin;
DROP INDEX IF EXISTS warehouse.idx_customer_tags_gin;
DROP INDEX IF EXISTS warehouse.idx_product_attributes_gin;

--GiST

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer ORDER BY location <-> point(55.75, 37.62) LIMIT 5;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions && int4range(0, 20);

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions @> 260;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.product_catalog WHERE dimensions -|- int4range(50, 100);

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE location <@ box(point(50,50), point(100,100));

CREATE INDEX idx_customer_location_gist ON warehouse.customer USING gist (location);
CREATE INDEX idx_product_dimensions_gist ON warehouse.product_catalog USING gist (dimensions);

DROP INDEX IF EXISTS warehouse.idx_customer_location_gist;
DROP INDEX IF EXISTS warehouse.idx_product_dimensions_gist;