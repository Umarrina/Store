CREATE DATABASE router;

CREATE EXTENSION postgres_fdw;

CREATE SERVER shard1_server FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'localhost', port '5432', dbname 'shard1');

CREATE SERVER shard2_server FOREIGN DATA WRAPPER postgres_fdw
    OPTIONS (host 'localhost', port '5432', dbname 'shard2');

CREATE USER MAPPING FOR CURRENT_USER SERVER shard1_server
    OPTIONS (user 'db_practice_umarrina', password 'f73aml4k9');
CREATE USER MAPPING FOR CURRENT_USER SERVER shard2_server
    OPTIONS (user 'db_practice_umarrina', password 'f73aml4k9');

CREATE FOREIGN TABLE users_shard1 (id INT, name TEXT)
    SERVER shard1_server OPTIONS (table_name 'users');

CREATE FOREIGN TABLE users_shard2 (id INT, name TEXT)
    SERVER shard2_server OPTIONS (table_name 'users');

CREATE VIEW all_users AS
SELECT * FROM users_shard1
UNION ALL
SELECT * FROM users_shard2;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM all_users;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users_shard1 WHERE id = 1;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM all_users WHERE id = 1;