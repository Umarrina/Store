CREATE SCHEMA IF NOT EXISTS partitioning_demo;
SET search_path TO partitioning_demo;

CREATE TABLE logs (
                      id SERIAL,
                      created_at TIMESTAMP NOT NULL,
                      message TEXT
) PARTITION BY RANGE (created_at);

CREATE TABLE logs_2026_03 PARTITION OF logs
    FOR VALUES FROM ('2026-03-01') TO ('2026-04-01');

CREATE TABLE logs_2026_04 PARTITION OF logs
    FOR VALUES FROM ('2026-04-01') TO ('2026-05-01');

INSERT INTO logs (created_at, message) VALUES
                                           ('2026-03-15 10:00:00', 'Сообщение 1'),
                                           ('2026-03-20 12:00:00', 'Сообщение 2'),
                                           ('2026-04-05 15:00:00', 'Сообщение 3');


EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM logs WHERE created_at >= '2026-03-01' AND created_at < '2026-04-01';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM logs WHERE created_at >= '2026-03-15' AND created_at < '2026-04-15';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM logs WHERE message LIKE '%Сообщение%';

CREATE INDEX ON logs (created_at);
EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM logs WHERE created_at >= '2026-03-01' AND created_at < '2026-04-01';



CREATE TABLE cities (
                        id SERIAL,
                        name TEXT,
                        region TEXT
) PARTITION BY LIST (region);

CREATE TABLE cities_center PARTITION OF cities FOR VALUES IN ('Центральный');
CREATE TABLE cities_north PARTITION OF cities FOR VALUES IN ('Северный');
CREATE TABLE cities_south PARTITION OF cities FOR VALUES IN ('Южный');

INSERT INTO cities (name, region) VALUES
                                      ('Москва', 'Центральный'),
                                      ('Санкт-Петербург', 'Северный'),
                                      ('Ростов-на-Дону', 'Южный');

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM cities WHERE region = 'Центральный';

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM cities WHERE name = 'Москва';


CREATE TABLE users (
                       id SERIAL PRIMARY KEY,
                       name TEXT
) PARTITION BY HASH (id);

CREATE TABLE users_p0 PARTITION OF users
    FOR VALUES WITH (MODULUS 2, REMAINDER 0);
CREATE TABLE users_p1 PARTITION OF users
    FOR VALUES WITH (MODULUS 2, REMAINDER 1);

INSERT INTO users (name) VALUES ('Alice'), ('Bob'), ('Charlie'), ('David');


EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users WHERE id = 3;

EXPLAIN (ANALYZE, BUFFERS) SELECT * FROM users;


SELECT * FROM partitioning_demo.logs;
SELECT * FROM partitioning_demo.cities;
SELECT * FROM partitioning_demo.users;

SELECT tableoid::regclass, * FROM partitioning_demo.logs;


CREATE PUBLICATION pub_logs_off FOR TABLE partitioning_demo.logs;

CREATE SCHEMA IF NOT EXISTS partitioning_demo;

CREATE SUBSCRIPTION sub_logs_off
    CONNECTION 'for_section'
    PUBLICATION pub_logs_off
    WITH (copy_data = true);

SELECT * FROM partitioning_demo.logs_2026_03;
SELECT * FROM partitioning_demo.logs_2026_04;


INSERT INTO partitioning_demo.logs (created_at, message) VALUES ('2026-03-25 12:00:00', 'test off');

CREATE PUBLICATION pub_logs_on FOR TABLE partitioning_demo.logs WITH (publish_via_partition_root = on);

CREATE TABLE partitioning_demo.logs_flat (LIKE partitioning_demo.logs INCLUDING ALL);

CREATE SUBSCRIPTION sub_logs_on
    CONNECTION 'for_section'
    PUBLICATION pub_logs_on
    WITH (copy_data = true);
