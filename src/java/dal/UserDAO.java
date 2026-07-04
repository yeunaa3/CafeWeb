package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import model.User;

public class UserDAO extends DBContext {

    public User getUserById(int userId) {
        String sql = "SELECT user_id, username, password, full_name, email, phone, address, status, points, role_id, created_at "
                + "FROM Users WHERE user_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return null;
    }

    public User getDefaultCustomer() {
        String sql = "SELECT TOP 1 user_id, username, password, full_name, email, phone, address, status, points, role_id, created_at "
                + "FROM Users WHERE role_id = 3 AND status = 1 ORDER BY user_id";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapUser(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return createFallbackCustomer();
    }

    public boolean updateProfile(User user) {
        String sql = "UPDATE Users SET full_name = ?, email = ?, phone = ?, address = ? WHERE user_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getEmail());
            ps.setString(3, user.getPhone());
            ps.setString(4, user.getAddress());
            ps.setInt(5, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, null);
        }
        return false;
    }

    private User mapUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUsername(rs.getString("username"));
        user.setPassword(rs.getString("password"));
        user.setFullName(rs.getString("full_name"));
        user.setEmail(rs.getString("email"));
        user.setPhone(rs.getString("phone"));
        user.setAddress(rs.getString("address"));
        user.setStatus(rs.getBoolean("status"));
        user.setPoints(rs.getInt("points"));
        user.setRoleId(rs.getInt("role_id"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        return user;
    }

    private User createFallbackCustomer() {
        User user = new User();
        user.setUserId(4);
        user.setUsername("customer01");
        user.setFullName("Phan Khach Hang Online");
        user.setEmail("customer01@gmail.com");
        user.setPhone("0909090909");
        user.setAddress("");
        user.setStatus(true);
        user.setPoints(0);
        user.setRoleId(3);
        return user;
    }
}
