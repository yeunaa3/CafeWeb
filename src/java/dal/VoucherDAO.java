package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import model.RedeemOption;
import model.Voucher;
import model.VoucherValidationResult;

public class VoucherDAO extends DBContext {

    public List<RedeemOption> getRedeemOptions() {
        List<RedeemOption> options = new ArrayList<RedeemOption>();
        options.add(new RedeemOption(1000, 20000, 50000, 30));
        options.add(new RedeemOption(2000, 30000, 70000, 30));
        options.add(new RedeemOption(3000, 50000, 120000, 45));
        return options;
    }

    public List<Voucher> getActiveVouchers(int limit) {
        List<Voucher> vouchers = new ArrayList<Voucher>();
        String sql = "SELECT TOP (?) voucher_id, voucher_code, discount_value, min_order_value, expiry_date, status "
                + "FROM Vouchers WHERE status = 1 AND expiry_date >= GETDATE() ORDER BY voucher_id DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();
            while (rs.next()) {
                vouchers.add(mapVoucher(rs));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return vouchers;
    }

    public Voucher redeemPointsForVoucher(int userId, RedeemOption option) throws SQLException {
        Connection con = null;
        PreparedStatement userPs = null;
        PreparedStatement updateUserPs = null;
        PreparedStatement voucherPs = null;
        ResultSet userRs = null;
        ResultSet keys = null;
        String selectUser = "SELECT points FROM Users WITH (UPDLOCK) WHERE user_id = ?";
        String updateUser = "UPDATE Users SET points = points - ? WHERE user_id = ?";
        String insertVoucher = "INSERT INTO Vouchers (voucher_code, discount_value, min_order_value, expiry_date, status) "
                + "VALUES (?, ?, ?, DATEADD(day, ?, GETDATE()), 1)";
        try {
            con = getConnection();
            con.setAutoCommit(false);

            userPs = con.prepareStatement(selectUser);
            userPs.setInt(1, userId);
            userRs = userPs.executeQuery();
            if (!userRs.next()) {
                throw new SQLException("Customer not found");
            }
            int points = userRs.getInt("points");
            if (points < option.getPointsCost()) {
                throw new SQLException("Not enough points");
            }

            updateUserPs = con.prepareStatement(updateUser);
            updateUserPs.setInt(1, option.getPointsCost());
            updateUserPs.setInt(2, userId);
            updateUserPs.executeUpdate();

            voucherPs = con.prepareStatement(insertVoucher, Statement.RETURN_GENERATED_KEYS);
            voucherPs.setString(1, buildVoucherCode(userId));
            voucherPs.setDouble(2, option.getDiscountValue());
            voucherPs.setDouble(3, option.getMinOrderValue());
            voucherPs.setInt(4, option.getValidDays());
            voucherPs.executeUpdate();

            keys = voucherPs.getGeneratedKeys();
            if (!keys.next()) {
                throw new SQLException("Cannot create voucher");
            }
            con.commit();
            return getVoucherById(keys.getInt(1));
        } catch (SQLException ex) {
            if (con != null) con.rollback();
            throw ex;
        } finally {
            if (keys != null) keys.close();
            if (userRs != null) userRs.close();
            if (voucherPs != null) voucherPs.close();
            if (updateUserPs != null) updateUserPs.close();
            if (userPs != null) userPs.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    public VoucherValidationResult validateVoucher(String voucherCode, double orderTotal) {
        if (voucherCode == null || voucherCode.trim().isEmpty()) {
            return new VoucherValidationResult(true, "");
        }
        Voucher voucher = getVoucherByCode(voucherCode.trim());
        if (voucher == null || !voucher.isStatus()) {
            return new VoucherValidationResult(false, "Mã giảm giá không tồn tại hoặc đã bị khóa.");
        }
        Timestamp now = new Timestamp(System.currentTimeMillis());
        if (voucher.getExpiryDate() != null && voucher.getExpiryDate().before(now)) {
            return new VoucherValidationResult(false, "Mã giảm giá đã hết hạn.");
        }
        if (orderTotal < voucher.getMinOrderValue()) {
            return new VoucherValidationResult(false, "Đơn hàng chưa đạt giá trị tối thiểu để áp dụng voucher.");
        }
        VoucherValidationResult result = new VoucherValidationResult(true, "Áp dụng voucher thành công.");
        result.setVoucher(voucher);
        result.setDiscountAmount(Math.min(voucher.getDiscountValue(), orderTotal));
        return result;
    }

    public Voucher getVoucherById(int voucherId) {
        String sql = "SELECT voucher_id, voucher_code, discount_value, min_order_value, expiry_date, status FROM Vouchers WHERE voucher_id = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, voucherId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapVoucher(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return null;
    }

    public Voucher getVoucherByCode(String voucherCode) {
        String sql = "SELECT voucher_id, voucher_code, discount_value, min_order_value, expiry_date, status FROM Vouchers WHERE voucher_code = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, voucherCode);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapVoucher(rs);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return null;
    }

    private Voucher mapVoucher(ResultSet rs) throws SQLException {
        Voucher voucher = new Voucher();
        voucher.setVoucherId(rs.getInt("voucher_id"));
        voucher.setVoucherCode(rs.getString("voucher_code"));
        voucher.setDiscountValue(rs.getDouble("discount_value"));
        voucher.setMinOrderValue(rs.getDouble("min_order_value"));
        voucher.setExpiryDate(rs.getTimestamp("expiry_date"));
        voucher.setStatus(rs.getBoolean("status"));
        return voucher;
    }

    private String buildVoucherCode(int userId) {
        return "CBMS" + userId + System.currentTimeMillis();
    }
}
