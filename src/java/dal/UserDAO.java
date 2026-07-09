package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import model.User;

public class UserDAO extends DBContext {

    public User authenticate(String usernameOrEmail, String password) {
        String sql = "SELECT " + userColumns()
                + " FROM Users WHERE (username = ? OR email = ?) AND password = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, usernameOrEmail);
            ps.setString(2, usernameOrEmail);
            ps.setString(3, password);
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

    public boolean isUsernameOrEmailTaken(String username, String email) {
        String sql = "SELECT 1 FROM Users WHERE username = ? OR email = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, username);
            ps.setString(2, email);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException ex) {
            ex.printStackTrace();
            return true;
        } finally {
            closeConnection(con, ps, rs);
        }
    }

    public boolean isUsernameOrEmailTakenByOther(int userId, String username, String email) {
        String sql = "SELECT 1 FROM Users WHERE user_id <> ? AND (username = ? OR email = ?)";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            ps.setString(2, username);
            ps.setString(3, email);
            rs = ps.executeQuery();
            return rs.next();
        } catch (SQLException ex) {
            ex.printStackTrace();
            return true;
        } finally {
            closeConnection(con, ps, rs);
        }
    }

    public boolean createCustomer(User user) {
        String sql = "INSERT INTO Users (username, password, full_name, email, phone, address, status, points, role_id) "
                + "SELECT ?, ?, ?, ?, ?, ?, 1, 0, role_id FROM Roles WHERE role_name = 'Customer'";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getAddress());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public User getUserById(int userId) {
        String sql = "SELECT " + userColumns() + " FROM Users WHERE user_id = ?";
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
        String sql = "SELECT TOP 1 " + userColumns()
                + " FROM Users WHERE role_id = 3 AND status = 1 ORDER BY user_id";
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
        String sql = "UPDATE Users SET username = ?, full_name = ?, email = ?, phone = ?, address = ?, gender = ? WHERE user_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getFullName());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getPhone());
            ps.setString(5, user.getAddress());
            ps.setString(6, user.getGender());
            ps.setInt(7, user.getUserId());
            return ps.executeUpdate() > 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, null);
        }
        return false;
    }

    public List<User> getStaff(String keyword) {
        List<User> staff = new ArrayList<User>();
        String value = keyword == null ? "" : keyword.trim();
        String sql = "SELECT " + userColumns() + " FROM Users "
                + "WHERE role_id = 2 AND (? = '' OR full_name LIKE ? OR username LIKE ? OR email LIKE ?) "
                + "ORDER BY status DESC, created_at DESC, user_id DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            String pattern = "%" + value + "%";
            ps.setString(1, value);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, pattern);
            rs = ps.executeQuery();
            while (rs.next()) staff.add(mapUser(rs));
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return staff;
    }

    public boolean createStaff(User user) {
        String sql = "INSERT INTO Users (username, password, full_name, email, phone, staff_position, "
                + "status, points, role_id) VALUES (?, ?, ?, ?, ?, ?, 1, 0, 2)";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, user.getUsername());
            ps.setString(2, user.getPassword());
            ps.setString(3, user.getFullName());
            ps.setString(4, user.getEmail());
            ps.setString(5, user.getPhone());
            ps.setString(6, user.getStaffPosition());
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public boolean updateStaff(User user, boolean changePassword) {
        String sql = changePassword
                ? "UPDATE Users SET full_name=?, phone=?, email=?, staff_position=?, username=?, password=? WHERE user_id=? AND role_id=2"
                : "UPDATE Users SET full_name=?, phone=?, email=?, staff_position=?, username=? WHERE user_id=? AND role_id=2";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, user.getFullName());
            ps.setString(2, user.getPhone());
            ps.setString(3, user.getEmail());
            ps.setString(4, user.getStaffPosition());
            ps.setString(5, user.getUsername());
            if (changePassword) {
                ps.setString(6, user.getPassword());
                ps.setInt(7, user.getUserId());
            } else {
                ps.setInt(6, user.getUserId());
            }
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public boolean setStaffStatus(int userId, boolean active) {
        String sql = "UPDATE Users SET status = ? WHERE user_id = ? AND role_id = 2";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setBoolean(1, active);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public boolean deleteStaff(int userId) {
        String sql = "DELETE u FROM Users u WHERE u.user_id = ? AND u.role_id = 2 "
                + "AND NOT EXISTS (SELECT 1 FROM Orders o WHERE o.staff_id = u.user_id OR o.user_id = u.user_id)";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public boolean updateAvatar(int userId, String avatarUrl) {
        ensureAvatarColumn();
        String sql = "UPDATE Users SET avatar_url = ? WHERE user_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, avatarUrl);
            ps.setInt(2, userId);
            return ps.executeUpdate() == 1;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return false;
        } finally {
            closeConnection(con, ps, null);
        }
    }

    private String userColumns() {
        String avatarColumn = hasAvatarColumn()
                ? "avatar_url"
                : "CAST(NULL AS VARCHAR(255)) AS avatar_url";
        return "user_id, username, password, full_name, email, phone, address, gender, "
                + "staff_position, status, points, role_id, " + avatarColumn + ", created_at";
    }

    private boolean hasAvatarColumn() {
        String sql = "SELECT COL_LENGTH('dbo.Users', 'avatar_url')";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            return rs.next() && rs.getObject(1) != null;
        } catch (SQLException ex) {
            return false;
        } finally {
            closeConnection(con, ps, rs);
        }
    }

    private void ensureAvatarColumn() {
        if (hasAvatarColumn()) {
            return;
        }
        String sql = "ALTER TABLE dbo.Users ADD avatar_url VARCHAR(255) NULL";
        Connection con = null;
        PreparedStatement ps = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.executeUpdate();
        } catch (SQLException ex) {
            if (!hasAvatarColumn()) {
                ex.printStackTrace();
            }
        } finally {
            closeConnection(con, ps, null);
        }
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
        user.setGender(rs.getString("gender"));
        user.setStaffPosition(rs.getString("staff_position"));
        user.setStatus(rs.getBoolean("status"));
        user.setPoints(rs.getInt("points"));
        user.setRoleId(rs.getInt("role_id"));
        user.setAvatarUrl(rs.getString("avatar_url"));
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
        user.setAvatarUrl(null);
        return user;
    }
}
