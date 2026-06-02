import org.json.JSONObject;
import java.sql.*;
import java.time.Instant;

public class ListeningWorker {
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

    public static void main(String[] args) throws SQLException {
        try (Connection conn = DbConnection.getConnection()) {
            conn.setAutoCommit(false);
            try (Statement st = conn.createStatement()) {
                st.execute("LISTEN task_channel");
            }
            System.out.println("ListeningWorker started, waiting for NOTIFY...");
            while (true) {
                conn.commit();
                org.postgresql.PGConnection pgConn = conn.unwrap(org.postgresql.PGConnection.class);
                org.postgresql.PGNotification[] notifications = pgConn.getNotifications(5000);
                if (notifications != null && notifications.length > 0) {
                    System.out.println("Получено уведомление, забираем задачу...");
                    processOneTask(conn);
                }
            }
        }
    }

    private static void processOneTask(Connection conn) throws SQLException {
        try (PreparedStatement st = conn.prepareStatement(POLL_SQL)) {
            ResultSet rs = st.executeQuery();
            if (!rs.next()) return;
            long taskId = rs.getLong("id");
            JSONObject payload = new JSONObject(rs.getString("payload"));
            int attemptsBefore = rs.getInt("attempts");
            System.out.printf("[%s] (NOTIFY) Задача %d (попытка %d): %s%n",
                    Instant.now(), taskId, attemptsBefore, payload);

            try {
                Thread.sleep(50);
            } catch (InterruptedException e) {
                Thread.currentThread().interrupt();
            }
            try (PreparedStatement upd = conn.prepareStatement(
                    "UPDATE warehouse.task_queue SET status = 2, updated_at = NOW() WHERE id = ?")) {
                upd.setLong(1, taskId);
                upd.executeUpdate();
            }
            System.out.printf("[%s] (NOTIFY) Задача %d завершена%n", Instant.now(), taskId);
            conn.commit();
        }
    }
}