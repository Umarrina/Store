import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public class DbConnection {
    private static final String URL = "jdbc:postgresql://localhost:5433/db_store";
    private static final String USER = "db_practice_umarrina";
    private static final String PASSWORD = "f73aml4k9";

    public static Connection getConnection() throws SQLException {
        Properties props = new Properties();
        props.setProperty("user", USER);
        props.setProperty("password", PASSWORD);
        return DriverManager.getConnection(URL, props);
    }
}