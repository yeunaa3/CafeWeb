package utils;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public final class DBCPUtils {
    private static final String RESOURCE_NAME = "java:comp/env/jdbc/CBMS";
    private static final String CONFIG_FILE = "ConnectDB.properties";
    private static DataSource dataSource;

    private DBCPUtils() {
    }

    public static Connection getConnection() throws SQLException {
        try {
            return getDataSource().getConnection();
        } catch (NamingException | RuntimeException | LinkageError ex) {
            return getDirectConnection(ex);
        } catch (SQLException ex) {
            return getDirectConnection(ex);
        }
    }

    private static synchronized DataSource getDataSource() throws NamingException {
        if (dataSource == null) {
            InitialContext context = new InitialContext();
            dataSource = (DataSource) context.lookup(RESOURCE_NAME);
        }
        return dataSource;
    }

    private static Connection getDirectConnection(Throwable poolError) throws SQLException {
        Properties config = loadConfig(poolError);
        String driver = config.getProperty("db.driver", "com.microsoft.sqlserver.jdbc.SQLServerDriver");
        String url = config.getProperty("db.url");
        String username = config.getProperty("db.username");
        String password = config.getProperty("db.password");

        if (url == null || username == null) {
            SQLException ex = new SQLException("Missing db.url or db.username in " + CONFIG_FILE);
            ex.addSuppressed(poolError);
            throw ex;
        }

        try {
            Class.forName(driver);
            return DriverManager.getConnection(url, username, password);
        } catch (ClassNotFoundException ex) {
            SQLException sqlException = new SQLException("Cannot load JDBC driver: " + driver, ex);
            sqlException.addSuppressed(poolError);
            throw sqlException;
        } catch (SQLException ex) {
            ex.addSuppressed(poolError);
            throw ex;
        }
    }

    private static Properties loadConfig(Throwable poolError) throws SQLException {
        Properties config = new Properties();
        try (InputStream input = DBCPUtils.class.getClassLoader().getResourceAsStream(CONFIG_FILE)) {
            if (input == null) {
                SQLException ex = new SQLException("Cannot find " + CONFIG_FILE + " in WEB-INF/classes.");
                ex.addSuppressed(poolError);
                throw ex;
            }
            config.load(input);
            return config;
        } catch (IOException ex) {
            SQLException sqlException = new SQLException("Cannot read " + CONFIG_FILE, ex);
            sqlException.addSuppressed(poolError);
            throw sqlException;
        }
    }
}
