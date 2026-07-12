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
        return getDataSource().getConnection();
    }

    private static synchronized DataSource getDataSource() throws SQLException {
        if (dataSource == null) {
            try {
                InitialContext context = new InitialContext();
                dataSource = (DataSource) context.lookup(RESOURCE_NAME);
            } catch (NamingException ex) {
                throw new SQLException("Cannot find Tomcat DataSource " + RESOURCE_NAME
                        + ". Check web/META-INF/context.xml.", ex);
            }
        }
        return dataSource;
    }
}
