package utils;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

public final class DBCPUtils {
    private static final String CONFIG_FILE = "ConnectDB.properties";

    private DBCPUtils() {
    }

    public static Connection getConnection() throws SQLException {
        Properties config = loadConfig();
        String driver = config.getProperty("db.driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String url = config.getProperty("db.url");
        String username = config.getProperty("db.username");
        String password = config.getProperty("db.password");

        if (url == null || username == null) {
            throw new SQLException("Missing db.url or db.username in " + CONFIG_FILE);
        }

        try {
            Class.forName(driver);
            return DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException ex) {
            throw new SQLException("Cannot load JDBC driver: " + driver, ex);
        }
    }

    private static Properties loadConfig() throws SQLException {
        Properties config = new Properties();
        try (InputStream input = DBCPUtils.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {
            if (input == null) {
                throw new SQLException("Cannot find " + CONFIG_FILE + " in WEB-INF/classes.");
            }
            config.load(input);
            return config;
        } catch (IOException ex) {
            throw new SQLException("Cannot read " + CONFIG_FILE, ex);
        }
    }
}
