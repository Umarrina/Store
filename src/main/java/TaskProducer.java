import org.json.JSONObject;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.util.Random;

public class TaskProducer {
    private static final Random random = new Random();

    public static void main(String[] args) throws InterruptedException {
        while (true) {
            int priority = random.nextInt(100) < 80 ? 0 : 100;
            JSONObject payload = new JSONObject();
            payload.put("task_id", System.currentTimeMillis());
            payload.put("message", "Task with priority " + priority);

            try (Connection conn = DbConnection.getConnection()) {
                conn.setAutoCommit(false);
                try (PreparedStatement st = conn.prepareStatement(
                        "INSERT INTO warehouse.task_queue (payload, priority) VALUES (?::jsonb, ?)")) {
                    st.setString(1, payload.toString());
                    st.setInt(2, priority);
                    st.executeUpdate();
                }
                conn.commit();
            } catch (Exception e) {
                e.printStackTrace();
            }

            Thread.sleep(2);
        }
    }
}