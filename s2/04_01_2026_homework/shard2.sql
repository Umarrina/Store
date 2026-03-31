CREATE DATABASE shard2;
CREATE TABLE users (
                       id INT PRIMARY KEY,
                       name TEXT
);
INSERT INTO users VALUES (2, 'Bob'), (4, 'David');