import org.json.JSONObject;
import java.sql.*;
import java.time.Instant;
import java.util.concurrent.ThreadLocalRandom;

public class TaskWorker {
    private static final String POLL_SQL =
            "WITH next_task AS (" +
                    "    SELECT id, payload, attempts " +
                    "    FROM warehouse.task_queue " +
                    "    WHERE status = 0 AND scheduled_at <= NOW() " +
                    "    ORDER BY priority DESC, created_at " +
                    "    LIMIT 1 " +
                    "    FOR UPDATE SKIP LOCKED" +
                    ") " +
                    "UPDATE warehouse.task_queue t " +
                    "SET status = 1, updated_at = NOW(), attempts = t.attempts + 1 " +
                    "FROM next_task " +
                    "WHERE t.id = next_task.id " +
                    "RETURNING t.id, t.payload, t.attempts";

    public static void main(String[] args) {
        System.out.println("TaskWorker started. Waiting for tasks...");
        while (true) {
            try (Connection conn = DbConnection.getConnection()) {
                conn.setAutoCommit(false);

                long taskId;
                JSONObject payload;
                int attemptsBefore;
                try (PreparedStatement st = conn.prepareStatement(POLL_SQL)) {
                    ResultSet rs = st.executeQuery();
                    if (!rs.next()) {
                        conn.commit();
                        Thread.sleep(1000);
                        continue;
                    }
                    taskId = rs.getLong("id");
                    payload = new JSONObject(rs.getString("payload"));
                    attemptsBefore = rs.getInt("attempts");
                    System.out.printf("[%s] Задача %d (попытка %d) получена: %s%n",
                            Instant.now(), taskId, attemptsBefore, payload);
                }

                boolean success = processTask(payload);

                if (success) {
                    try (PreparedStatement st = conn.prepareStatement(
                            "UPDATE warehouse.task_queue SET status = 2, updated_at = NOW() WHERE id = ?")) {
                        st.setLong(1, taskId);
                        st.executeUpdate();
                    }
                    System.out.printf("[%s] Задача %d УСПЕШНО завершена%n", Instant.now(), taskId);
                } else {
                    long backoffMinutes = (long) (Math.pow(2, attemptsBefore) * 5);
                    try (PreparedStatement st = conn.prepareStatement(
                            "UPDATE warehouse.task_queue " +
                                    "SET status = CASE WHEN attempts >= max_attempts THEN 4 ELSE 0 END, " +
                                    "    scheduled_at = NOW() + (? * INTERVAL '1 minute'), " +
                                    "    updated_at = NOW(), " +
                                    "    last_error = ? " +
                                    "WHERE id = ?")) {
                        st.setLong(1, backoffMinutes);
                        st.setString(2, "Simulated error");
                        st.setLong(3, taskId);
                        st.executeUpdate();
                    }
                    System.out.printf("[%s] Задача %d ошибка → повтор через %d мин%n",
                            Instant.now(), taskId, backoffMinutes);
                }
                conn.commit();
            } catch (InterruptedException e) {
                System.out.println("Worker interrupted");
                break;
            } catch (Exception e) {
                e.printStackTrace();
                try { Thread.sleep(5000); } catch (InterruptedException ignored) {}
            }
        }
    }

    private static boolean processTask(JSONObject payload) {
        try {
            Thread.sleep(50);
        } catch (InterruptedException e) {
            return false;
        }
        if (ThreadLocalRandom.current().nextInt(100) < 10) {
            System.out.println(" Ошибка при обработке: " + payload);
            return false;
        }
        System.out.println(" Успех: " + payload);
        return true;
    }
}