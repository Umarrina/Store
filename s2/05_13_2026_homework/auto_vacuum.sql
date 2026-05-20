ALTER TABLE warehouse.task_queue SET (
    autovacuum_vacuum_scale_factor = 0,
    autovacuum_vacuum_threshold = 500,
    autovacuum_vacuum_cost_delay = 10,
    autovacuum_vacuum_cost_limit = 1000
    );



SELECT
    relname,
    n_live_tup,
    n_dead_tup,
    round(100.0 * n_dead_tup / nullif(n_live_tup + n_dead_tup, 0), 2) AS dead_percent,
    last_vacuum,
    last_autovacuum,
    autovacuum_count
FROM pg_stat_user_tables
WHERE relname = 'task_queue';