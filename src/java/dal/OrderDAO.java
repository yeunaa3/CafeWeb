package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import model.CartItem;
import model.CustomerOrderSummary;
import model.Topping;

public class OrderDAO extends DBContext {

    public int createOnlineOrder(Integer userId, List<CartItem> cart, String shippingAddress, String phone, String note) throws SQLException {
        return createOnlineOrder(userId, cart, shippingAddress, phone, note, null, 0);
    }

    public int createOnlineOrder(Integer userId, List<CartItem> cart, String shippingAddress, String phone, String note, Integer voucherId, double discountAmount) throws SQLException {
        if (cart == null || cart.isEmpty()) {
            throw new SQLException("Cart is empty");
        }

        Connection con = null;
        PreparedStatement orderPs = null;
        PreparedStatement detailPs = null;
        PreparedStatement toppingPs = null;
        PreparedStatement voucherLockPs = null;
        PreparedStatement consumeVoucherPs = null;
        ResultSet generatedKeys = null;
        ResultSet voucherRs = null;

        String orderSql = "INSERT INTO Orders (user_id, staff_id, voucher_id, total_price, discount_amount, status, order_type, shipping_address, shipping_phone, payment_method, note) "
                + "VALUES (?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String detailSql = "INSERT INTO OrderDetails (order_id, product_id, quantity, selected_size, ice_level, sugar_level, price) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        String toppingSql = "INSERT INTO OrderDetailToppings (order_detail_id, topping_id, topping_price) VALUES (?, ?, ?)";
        String voucherLockSql = "SELECT owner_user_id, status FROM Vouchers WITH (UPDLOCK) WHERE voucher_id = ?";
        String consumeVoucherSql = "UPDATE Vouchers SET status = 0 WHERE voucher_id = ? AND status = 1";

        try {
            con = getConnection();
            con.setAutoCommit(false);

            boolean consumePrivateVoucher = false;
            if (voucherId != null) {
                voucherLockPs = con.prepareStatement(voucherLockSql);
                voucherLockPs.setInt(1, voucherId);
                voucherRs = voucherLockPs.executeQuery();
                if (!voucherRs.next() || !voucherRs.getBoolean("status")) {
                    throw new SQLException("Voucher is unavailable");
                }
                Object owner = voucherRs.getObject("owner_user_id");
                if (owner != null) {
                    if (userId == null || ((Number) owner).intValue() != userId.intValue()) {
                        throw new SQLException("Voucher owner mismatch");
                    }
                    consumePrivateVoucher = true;
                }
                voucherRs.close();
                voucherRs = null;
            }

            orderPs = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            if (userId == null) {
                orderPs.setNull(1, java.sql.Types.INTEGER);
            } else {
                orderPs.setInt(1, userId);
            }
            if (voucherId == null) {
                orderPs.setNull(2, java.sql.Types.INTEGER);
            } else {
                orderPs.setInt(2, voucherId);
            }
            double originalTotal = calculateTotal(cart);
            double appliedDiscount = Math.max(0, Math.min(discountAmount, originalTotal));
            orderPs.setDouble(3, originalTotal - appliedDiscount);
            orderPs.setDouble(4, appliedDiscount);
            orderPs.setString(5, "Pending");
            orderPs.setString(6, "Online");
            orderPs.setString(7, shippingAddress);
            orderPs.setString(8, phone);
            orderPs.setString(9, "Cash");
            orderPs.setString(10, note == null || note.trim().isEmpty() ? null : note.trim());
            orderPs.executeUpdate();

            generatedKeys = orderPs.getGeneratedKeys();
            if (!generatedKeys.next()) {
                throw new SQLException("Cannot create order");
            }
            int orderId = generatedKeys.getInt(1);

            detailPs = con.prepareStatement(detailSql, Statement.RETURN_GENERATED_KEYS);
            toppingPs = con.prepareStatement(toppingSql);

            for (CartItem item : cart) {
                detailPs.setInt(1, orderId);
                detailPs.setInt(2, item.getProductId());
                detailPs.setInt(3, item.getQuantity());
                detailPs.setString(4, item.getSelectedSize());
                detailPs.setString(5, item.getIceLevel());
                detailPs.setString(6, item.getSugarLevel());
                detailPs.setDouble(7, item.getDrinkPrice());
                detailPs.executeUpdate();

                ResultSet detailKeys = detailPs.getGeneratedKeys();
                if (detailKeys.next() && item.getToppings() != null) {
                    int orderDetailId = detailKeys.getInt(1);
                    for (Topping topping : item.getToppings()) {
                        toppingPs.setInt(1, orderDetailId);
                        toppingPs.setInt(2, topping.getToppingId());
                        toppingPs.setDouble(3, topping.getPrice());
                        toppingPs.addBatch();
                    }
                    toppingPs.executeBatch();
                }
                if (detailKeys != null) {
                    detailKeys.close();
                }
            }

            if (consumePrivateVoucher) {
                consumeVoucherPs = con.prepareStatement(consumeVoucherSql);
                consumeVoucherPs.setInt(1, voucherId);
                if (consumeVoucherPs.executeUpdate() != 1) {
                    throw new SQLException("Voucher was already used");
                }
            }

            con.commit();
            return orderId;
        } catch (SQLException ex) {
            if (con != null) {
                con.rollback();
            }
            throw ex;
        } finally {
            if (voucherRs != null) voucherRs.close();
            if (generatedKeys != null) generatedKeys.close();
            if (consumeVoucherPs != null) consumeVoucherPs.close();
            if (voucherLockPs != null) voucherLockPs.close();
            if (toppingPs != null) toppingPs.close();
            if (detailPs != null) detailPs.close();
            if (orderPs != null) orderPs.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    private double calculateTotal(List<CartItem> cart) {
        double total = 0;
        for (CartItem item : cart) {
            total += item.getLineTotal();
        }
        return total;
    }

    private String buildOrderNote(String phone, String note) {
        StringBuilder builder = new StringBuilder();
        builder.append("Phone: ").append(phone == null ? "" : phone.trim());
        if (note != null && !note.trim().isEmpty()) {
            builder.append(" | Note: ").append(note.trim());
        }
        return builder.toString();
    }

    public List<CustomerOrderSummary> getCustomerOrders(Integer userId) {
        List<CustomerOrderSummary> result = new ArrayList<CustomerOrderSummary>();
        if (userId == null) {
            return result;
        }
        Map<Integer, CustomerOrderSummary> orderMap = new LinkedHashMap<Integer, CustomerOrderSummary>();
        String sql = "SELECT o.order_id, o.total_price, o.discount_amount, o.order_date, o.status, o.order_type, "
                + "o.shipping_address, o.payment_method, o.note, od.quantity, p.product_name "
                + "FROM Orders o "
                + "LEFT JOIN OrderDetails od ON o.order_id = od.order_id "
                + "LEFT JOIN Products p ON od.product_id = p.product_id "
                + "WHERE o.user_id = ? "
                + "ORDER BY o.order_date DESC, o.order_id DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            while (rs.next()) {
                int orderId = rs.getInt("order_id");
                CustomerOrderSummary order = orderMap.get(orderId);
                if (order == null) {
                    order = new CustomerOrderSummary();
                    order.setOrderId(orderId);
                    order.setTotalPrice(rs.getDouble("total_price"));
                    order.setDiscountAmount(rs.getDouble("discount_amount"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setStatus(rs.getString("status"));
                    order.setOrderType(rs.getString("order_type"));
                    order.setShippingAddress(rs.getString("shipping_address"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setNote(rs.getString("note"));
                    orderMap.put(orderId, order);
                }
                String productName = rs.getString("product_name");
                int quantity = rs.getInt("quantity");
                if (productName != null) {
                    order.addItem(quantity + " x " + productName);
                }
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        result.addAll(orderMap.values());
        return result;
    }

    public void updateOrderStatusAndRewardPoints(int orderId, String newStatus) throws SQLException {
        Connection con = null;
        PreparedStatement selectPs = null;
        PreparedStatement updateOrderPs = null;
        PreparedStatement updatePointPs = null;
        PreparedStatement markAwardedPs = null;
        ResultSet rs = null;
        String selectSql = "SELECT user_id, total_price, status, points_awarded FROM Orders WITH (UPDLOCK) WHERE order_id = ?";
        String updateOrderSql = "UPDATE Orders SET status = ? WHERE order_id = ?";
        String updatePointSql = "UPDATE Users SET points = points + ? WHERE user_id = ?";
        String markAwardedSql = "UPDATE Orders SET points_awarded = 1 WHERE order_id = ?";
        try {
            con = getConnection();
            con.setAutoCommit(false);
            selectPs = con.prepareStatement(selectSql);
            selectPs.setInt(1, orderId);
            rs = selectPs.executeQuery();
            if (!rs.next()) {
                throw new SQLException("Order not found");
            }
            int userId = rs.getInt("user_id");
            boolean hasUser = !rs.wasNull();
            double totalPrice = rs.getDouble("total_price");
            String oldStatus = rs.getString("status");
            boolean pointsAwarded = rs.getBoolean("points_awarded");

            updateOrderPs = con.prepareStatement(updateOrderSql);
            updateOrderPs.setString(1, newStatus);
            updateOrderPs.setInt(2, orderId);
            updateOrderPs.executeUpdate();

            if (hasUser && !pointsAwarded && "Completed".equalsIgnoreCase(newStatus)
                    && !"Completed".equalsIgnoreCase(oldStatus)) {
                int earnedPoints = (int) Math.floor(totalPrice / 1000);
                if (earnedPoints > 0) {
                    updatePointPs = con.prepareStatement(updatePointSql);
                    updatePointPs.setInt(1, earnedPoints);
                    updatePointPs.setInt(2, userId);
                    updatePointPs.executeUpdate();
                }
                markAwardedPs = con.prepareStatement(markAwardedSql);
                markAwardedPs.setInt(1, orderId);
                markAwardedPs.executeUpdate();
            }

            con.commit();
        } catch (SQLException ex) {
            if (con != null) con.rollback();
            throw ex;
        } finally {
            if (rs != null) rs.close();
            if (markAwardedPs != null) markAwardedPs.close();
            if (updatePointPs != null) updatePointPs.close();
            if (updateOrderPs != null) updateOrderPs.close();
            if (selectPs != null) selectPs.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }
}
