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
        Connection conn = null;
        try {
            Properties properties = new Properties();
            InputStream inputStream = getClass().getClassLoader().getResourceAsStream("ConnectDB.properties");
            if (inputStream == null) {
                inputStream = getClass().getClassLoader().getResourceAsStream("../ConnectDB.properties");
            }
            
            if (inputStream != null) {
                properties.load(inputStream);
                String user = properties.getProperty("userID");
                String pass = properties.getProperty("password");
                String url = properties.getProperty("url");
                
                Class.forName("com.microsoft.sqlserver.jdbc.SQLServerDriver");
                conn = DriverManager.getConnection(url, user, pass);
            } else {
                System.err.println("Không tìm thấy file ConnectDB.properties ");
            }
        } catch (ClassNotFoundException | SQLException | IOException ex) {
            Logger.getLogger(DBContext.class.getName()).log(Level.SEVERE, null, ex);
        }
        return conn;
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
