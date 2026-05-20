CREATE SCHEMA IF NOT EXISTS warehouse;

CREATE TABLE warehouse.task_queue (
        id            BIGSERIAL PRIMARY KEY,
        payload       JSONB NOT NULL,
        status        SMALLINT DEFAULT 0,
        priority      INT DEFAULT 0,
        scheduled_at TIMESTAMP DEFAULT NOW(),
        attempts     INT       DEFAULT 0,
        max_attempts INT       DEFAULT 3,
        last_error   TEXT,
        created_at   TIMESTAMP DEFAULT NOW(),
        updated_at   TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_task_queue_status_priority_scheduled
    ON warehouse.task_queue (status, priority DESC, scheduled_at) WHERE status = 0;

CREATE INDEX idx_task_queue_status_updated
    ON warehouse.task_queue (status, updated_at) WHERE status = 1; -- RUNNING