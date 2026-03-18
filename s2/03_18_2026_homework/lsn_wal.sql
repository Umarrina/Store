SELECT pg_current_wal_lsn();

INSERT INTO warehouse.customer (last_name, first_name, email)
VALUES ('Test', 'WAL', 'test_wal@example.com');

SELECT pg_current_wal_lsn();

SELECT pg_wal_lsn_diff('0/E75429F8', '0/E753EEC8');



BEGIN;

SELECT pg_current_wal_lsn() AS before_commit;

INSERT INTO warehouse.customer (last_name, first_name, email)
VALUES ('Test2', 'WAL2', 'test2@example.com');

SELECT pg_current_wal_lsn();

COMMIT;

SELECT pg_current_wal_lsn();

SELECT pg_wal_lsn_diff('0/E7546B78', '0/E7542BA0');

SELECT pg_wal_lsn_diff('0/E7546B78', '0/E7542B00');



SELECT pg_current_wal_lsn();

INSERT INTO warehouse.customer (last_name, first_name, email)
SELECT 'Mass_' || g, 'Insert_' || g, 'mass' || g || '@example.com'
FROM generate_series(1, 10000) g;

SELECT pg_current_wal_lsn();

SELECT pg_wal_lsn_diff('0/EBD24560', '0/EAB4A240') AS wal_bytes;