import java.sql.*;

public class Monitor {
    public static void main(String[] args) throws InterruptedException {
        while (true) {
            try (Connection conn = DbConnection.getConnection()) {
                // Лаг очереди
                try (Statement st = conn.createStatement();
                     ResultSet rs = st.executeQuery(
                             "SELECT EXTRACT(epoch FROM (NOW() - MIN(created_at)))::INT AS lag, COUNT(*) AS pending " +
                                     "FROM warehouse.task_queue WHERE status = 0 AND scheduled_at <= NOW()")) {
                    if (rs.next()) {
                        System.out.printf("[LAG] %d sec, pending: %d%n", rs.getInt("lag"), rs.getInt("pending"));
                    } else {
                        System.out.println("[LAG] нет задач в статусе READY");
                    }
                }

                // Пропускная способность (задачи, завершённые за последнюю секунду)
                try (Statement st = conn.createStatement();
                     ResultSet rs = st.executeQuery(
                             "SELECT COUNT(*) AS throughput FROM warehouse.task_queue " +
                                     "WHERE status = 2 AND updated_at > NOW() - INTERVAL '1 second'")) {
                    if (rs.next()) {
                        System.out.printf("[THROUGHPUT] %d задач/сек%n", rs.getInt("throughput"));
                    }
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
            Thread.sleep(2000);
        }
    }
}