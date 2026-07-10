package utils;

import java.sql.Connection;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public final class DBCPUtils {
    private static final String RESOURCE_NAME = "java:comp/env/jdbc/CBMS";
    private static DataSource dataSource;

    private DBCPUtils() {
    }

    public static Connection getConnection() throws SQLException {
        try {
            return getDataSource().getConnection();
        } catch (NamingException ex) {
            throw new SQLException("Cannot find Tomcat connection pool: " + RESOURCE_NAME, ex);
        }
    }

    private static synchronized DataSource getDataSource() throws NamingException {
        if (dataSource == null) {
            InitialContext context = new InitialContext();
            dataSource = (DataSource) context.lookup(RESOURCE_NAME);
        }
        return dataSource;
    }
}
