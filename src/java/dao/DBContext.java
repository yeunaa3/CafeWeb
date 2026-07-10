package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.logging.Level;
import java.util.logging.Logger;
import utils.DBCPUtils;

public class DBContext {

    public Connection getConnection() {
        try {
            return DBCPUtils.getConnection();
        } catch (SQLException ex) {
            Logger.getLogger(DBContext.class.getName()).log(
                    Level.SEVERE,
                    "Cannot connect to CBMS database. Check SQL Server service, TCP/IP/port, "
                    + "database name, SQL Authentication and WEB-INF/classes/ConnectDB.properties.",
                    ex);
            throw new IllegalStateException(
                    "Cannot connect to CBMS database. See the server log for the root cause.", ex);
        }
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
