CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE IF NOT EXISTS warehouse.task_queue (
                                                    id            BIGSERIAL PRIMARY KEY,
                                                    payload       JSONB NOT NULL,
                                                    status        SMALLINT DEFAULT 0,   -- 0 READY, 1 RUNNING, 2 COMPLETED, 3 FAILED, 4 DLQ
                                                    priority      INT DEFAULT 0,
                                                    scheduled_at  TIMESTAMP DEFAULT NOW(),
    attempts      INT DEFAULT 0,
    max_attempts  INT DEFAULT 3,
    last_error    TEXT,
    created_at    TIMESTAMP DEFAULT NOW(),
    updated_at    TIMESTAMP DEFAULT NOW()
    );

CREATE INDEX CONCURRENTLY IF NOT EXISTS idx_task_queue_status_priority
    ON warehouse.task_queue (status, priority DESC, scheduled_at)
    WHERE status = 0;