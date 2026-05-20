CREATE OR REPLACE FUNCTION warehouse.notify_task() RETURNS TRIGGER AS $$
BEGIN
    PERFORM pg_notify('task_channel', 'new_task');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_notify_task ON warehouse.task_queue;
CREATE TRIGGER trigger_notify_task
    AFTER INSERT ON warehouse.task_queue
    FOR EACH ROW EXECUTE FUNCTION warehouse.notify_task();