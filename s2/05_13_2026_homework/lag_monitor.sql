SELECT
    EXTRACT(epoch FROM (NOW() - MIN(created_at)))::INT AS lag_seconds,
    COUNT(*) AS pending_count
FROM warehouse.task_queue
WHERE status = 0 AND scheduled_at <= NOW();



SELECT COUNT(*) AS processed_per_second
FROM warehouse.task_queue
WHERE updated_at > NOW() - INTERVAL '1 second'
  AND status = 2;