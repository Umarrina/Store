CREATE DATABASE shard1;
CREATE TABLE users (
                       id INT PRIMARY KEY,
                       name TEXT
);
INSERT INTO users VALUES (1, 'Alice'), (3, 'Charlie');