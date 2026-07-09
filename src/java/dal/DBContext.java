package dal;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBContext {

    public Connection getConnection() {
        try (InputStream inputStream = getClass().getClassLoader()
                .getResourceAsStream("../ConnectDB.properties")) {
            if (inputStream == null) {
                throw new IOException("ConnectDB.properties is missing from web/WEB-INF");
            }

            Properties properties = new Properties();
            properties.load(inputStream);
            String user = environmentOrDefault("CBMS_DB_USER", properties.getProperty("userID"));
            String password = environmentOrDefault("CBMS_DB_PASSWORD", properties.getProperty("password"));
            String url = environmentOrDefault("CBMS_DB_URL", properties.getProperty("url"));

            requireConfiguration("url", url);
            requireConfiguration("userID", user);
            if (password == null) {
                throw new IOException("Database configuration 'password' is missing");
            }

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(url, user, password);
        } catch (ClassNotFoundException | SQLException | IOException ex) {
            Logger.getLogger(DBContext.class.getName()).log(
                    Level.SEVERE,
                    "Cannot connect to CBMS database. Check SQL Server service, TCP/IP/port, "
                    + "database name, SQL Authentication and ConnectDB.properties.",
                    ex);
            throw new IllegalStateException(
                    "Cannot connect to CBMS database. See the server log for the root cause.", ex);
        }
    }

    private void requireConfiguration(String name, String value) throws IOException {
        if (value == null || value.trim().isEmpty()) {
            throw new IOException("Database configuration '" + name + "' is missing");
        }
    }

    private String environmentOrDefault(String name, String defaultValue) {
        String value = System.getenv(name);
        return value == null || value.trim().isEmpty() ? defaultValue : value.trim();
    }

    public void closeConnection(Connection connection, PreparedStatement statement, ResultSet resultSet) {
        try {
            if (resultSet != null && !resultSet.isClosed()) {
                resultSet.close();
            }
            if (statement != null && !statement.isClosed()) {
                statement.close();
            }
            if (connection != null && !connection.isClosed()) {
                connection.close();
            }
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
