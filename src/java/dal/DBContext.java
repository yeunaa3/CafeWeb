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

    public Connection getConnection() throws SQLException {
        try {
            Properties properties = new Properties();
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream("ConnectDB.properties");
            if (inputStream == null) {
                inputStream = getClass().getClassLoader().getResourceAsStream("../ConnectDB.properties");
            }

            if (inputStream == null) {
                throw new SQLException("Khong tim thay file ConnectDB.properties trong classpath.");
            }

            properties.load(inputStream);
            String user = properties.getProperty("userID");
            String pass = properties.getProperty("password");
            String url = properties.getProperty("url");
            if (url == null || url.trim().isEmpty()) {
                throw new SQLException("Thieu url trong ConnectDB.properties.");
            }

            Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
            return DriverManager.getConnection(url, user, pass);
        } catch (ClassNotFoundException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
            throw new SQLException("Khong tim thay SQL Server JDBC Driver. Kiem tra sqljdbc42.jar trong WEB-INF/lib.", ex);
        } catch (IOException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
            throw new SQLException("Khong doc duoc file ConnectDB.properties.", ex);
        }
    }

    public void closeConnection(Connection con, PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null && !rs.isClosed()) rs.close();
            if (ps != null && !ps.isClosed()) ps.close();
            if (con != null && !con.isClosed()) con.close();
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
}
