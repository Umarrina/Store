EXPLAIN SELECT * FROM warehouse.customer WHERE id = 15000;
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id = 15000;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id = 15000;

EXPLAIN SELECT * FROM warehouse.customer WHERE id > 200000;
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id > 200000;
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id > 200000;

EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE email LIKE 'user150%';

EXPLAIN SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE email LIKE '%500%';
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE email LIKE '%500%';

EXPLAIN SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
EXPLAIN ANALYZE SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM warehouse.customer WHERE id IN (100000, 150000, 200000);


CREATE INDEX idx_customer_id_btree ON warehouse.customer USING btree (id);
DROP INDEX IF EXISTS warehouse.idx_customer_id_btree;

CREATE INDEX idx_customer_id_hash ON warehouse.customer USING hash (id);
DROP INDEX IF EXISTS warehouse.idx_customer_id_hash;

CREATE INDEX idx_customer_email_btree ON warehouse.customer USING btree (email);
DROP INDEX IF EXISTS warehouse.idx_customer_email_btree;

CREATE INDEX idx_customer_email_hash ON warehouse.customer USING hash (email);
DROP INDEX IF EXISTS warehouse.idx_customer_email_hash;