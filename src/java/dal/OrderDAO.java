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
import model.CashierOrderView;
import model.CustomerOrderSummary;
import model.Topping;

public class OrderDAO extends DBContext {

    public static class PaymentResult {
        private final int orderId;
        private final double totalPrice;
        private final double amountReceived;
        private final double changeAmount;

        public PaymentResult(int orderId, double totalPrice, double amountReceived, double changeAmount) {
            this.orderId = orderId;
            this.totalPrice = totalPrice;
            this.amountReceived = amountReceived;
            this.changeAmount = changeAmount;
        }

        public int getOrderId() { return orderId; }
        public double getTotalPrice() { return totalPrice; }
        public double getAmountReceived() { return amountReceived; }
        public double getChangeAmount() { return changeAmount; }
    }

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
        ResultSet generatedKeys = null;

        String orderSql = "INSERT INTO Orders (user_id, staff_id, voucher_id, total_price, discount_amount, status, order_type, shipping_address, payment_method, note) "
                + "VALUES (?, NULL, ?, ?, ?, ?, ?, ?, ?, ?)";
        String detailSql = "INSERT INTO OrderDetails (order_id, product_id, quantity, selected_size, ice_level, sugar_level, price) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        String toppingSql = "INSERT INTO OrderDetailToppings (order_detail_id, topping_id, topping_price) VALUES (?, ?, ?)";

        try {
            con = getConnection();
            con.setAutoCommit(false);

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
            orderPs.setString(8, "Cash");
            orderPs.setString(9, buildOrderNote(phone, note));
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

            con.commit();
            return orderId;
        } catch (SQLException ex) {
            if (con != null) {
                con.rollback();
            }
            throw ex;
        } finally {
            if (generatedKeys != null) generatedKeys.close();
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

    public List<CashierOrderView> getOnlineOrdersForCashier() {
        List<CashierOrderView> result = new ArrayList<CashierOrderView>();
        Map<Integer, CashierOrderView> orderMap = new LinkedHashMap<Integer, CashierOrderView>();
        String sql = "SELECT o.order_id, o.staff_id, o.total_price, o.discount_amount, o.order_date, o.status, "
                + "o.order_type, o.shipping_address, o.payment_method, o.note, "
                + "u.full_name, u.phone, od.quantity, od.selected_size, od.ice_level, od.sugar_level, p.product_name "
                + "FROM Orders o "
                + "LEFT JOIN Users u ON o.user_id = u.user_id "
                + "LEFT JOIN OrderDetails od ON o.order_id = od.order_id "
                + "LEFT JOIN Products p ON od.product_id = p.product_id "
                + "WHERE o.order_type = 'Online' "
                + "AND o.status IN ('Pending', 'Processing', 'Paid', 'Cancelled') "
                + "ORDER BY CASE o.status WHEN 'Pending' THEN 1 WHEN 'Processing' THEN 2 WHEN 'Paid' THEN 3 ELSE 4 END, "
                + "o.order_date DESC, o.order_id DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                int orderId = rs.getInt("order_id");
                CashierOrderView order = orderMap.get(orderId);
                if (order == null) {
                    order = new CashierOrderView();
                    order.setOrderId(orderId);
                    order.setStaffId(rs.getInt("staff_id"));
                    if (rs.wasNull()) {
                        order.setStaffId(null);
                    }
                    order.setTotalPrice(rs.getDouble("total_price"));
                    order.setDiscountAmount(rs.getDouble("discount_amount"));
                    order.setOrderDate(rs.getTimestamp("order_date"));
                    order.setStatus(rs.getString("status"));
                    order.setOrderType(rs.getString("order_type"));
                    order.setShippingAddress(rs.getString("shipping_address"));
                    order.setPaymentMethod(rs.getString("payment_method"));
                    order.setNote(rs.getString("note"));
                    order.setCustomerName(rs.getString("full_name"));
                    order.setCustomerPhone(rs.getString("phone"));
                    orderMap.put(orderId, order);
                }
                String productName = rs.getString("product_name");
                if (productName != null) {
                    order.addItem(rs.getInt("quantity") + " x " + productName
                            + " | Size " + rs.getString("selected_size")
                            + " | Đá " + rs.getString("ice_level")
                            + " | Đường " + rs.getString("sugar_level"));
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

    public void approveOnlineOrder(int orderId, int staffId) throws SQLException {
        updateOnlineOrderStatus(orderId, staffId, "Pending", "Processing", null);
    }

    public void rejectOnlineOrder(int orderId, int staffId) throws SQLException {
        updateOnlineOrderStatus(orderId, staffId, "Pending", "Cancelled", null);
    }

    public PaymentResult confirmPayment(int orderId, int staffId, String paymentMethod, double amountReceived) throws SQLException {
        Connection con = null;
        PreparedStatement selectPs = null;
        PreparedStatement updatePs = null;
        ResultSet rs = null;
        String selectSql = "SELECT total_price, status FROM Orders WITH (UPDLOCK) WHERE order_id = ? AND order_type = 'Online'";
        String updateSql = "UPDATE Orders SET status = 'Paid', staff_id = ?, payment_method = ? WHERE order_id = ?";
        try {
            con = getConnection();
            con.setAutoCommit(false);
            selectPs = con.prepareStatement(selectSql);
            selectPs.setInt(1, orderId);
            rs = selectPs.executeQuery();
            if (!rs.next()) {
                throw new SQLException("Không tìm thấy đơn online cần thanh toán.");
            }
            double totalPrice = rs.getDouble("total_price");
            String status = rs.getString("status");
            if (!"Processing".equalsIgnoreCase(status) && !"Pending".equalsIgnoreCase(status)) {
                throw new SQLException("Chỉ có thể xác nhận thanh toán cho đơn đang chờ hoặc đã duyệt.");
            }

            String method = paymentMethod == null || paymentMethod.trim().isEmpty() ? "Cash" : paymentMethod.trim();
            double received = "QR-Code".equalsIgnoreCase(method) ? totalPrice : amountReceived;
            if (received < totalPrice) {
                throw new SQLException("Tiền khách đưa chưa đủ để thanh toán đơn hàng.");
            }

            updatePs = con.prepareStatement(updateSql);
            updatePs.setInt(1, staffId);
            updatePs.setString(2, method);
            updatePs.setInt(3, orderId);
            updatePs.executeUpdate();
            con.commit();

            return new PaymentResult(orderId, totalPrice, received, received - totalPrice);
        } catch (SQLException ex) {
            if (con != null) con.rollback();
            throw ex;
        } finally {
            if (rs != null) rs.close();
            if (updatePs != null) updatePs.close();
            if (selectPs != null) selectPs.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
    }

    private void updateOnlineOrderStatus(int orderId, int staffId, String expectedStatus, String newStatus, String paymentMethod) throws SQLException {
        Connection con = null;
        PreparedStatement ps = null;
        String sql = "UPDATE Orders SET status = ?, staff_id = ?, payment_method = COALESCE(?, payment_method) "
                + "WHERE order_id = ? AND order_type = 'Online' AND status = ?";
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, newStatus);
            ps.setInt(2, staffId);
            ps.setString(3, paymentMethod);
            ps.setInt(4, orderId);
            ps.setString(5, expectedStatus);
            int affected = ps.executeUpdate();
            if (affected == 0) {
                throw new SQLException("Không thể cập nhật đơn. Đơn có thể đã được xử lý trước đó.");
            }
        } finally {
            closeConnection(con, ps, null);
        }
    }

    public void updateOrderStatusAndRewardPoints(int orderId, String newStatus) throws SQLException {
        Connection con = null;
        PreparedStatement selectPs = null;
        PreparedStatement updateOrderPs = null;
        PreparedStatement updatePointPs = null;
        ResultSet rs = null;
        String selectSql = "SELECT user_id, total_price, status FROM Orders WITH (UPDLOCK) WHERE order_id = ?";
        String updateOrderSql = "UPDATE Orders SET status = ? WHERE order_id = ?";
        String updatePointSql = "UPDATE Users SET points = points + ? WHERE user_id = ?";
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

            updateOrderPs = con.prepareStatement(updateOrderSql);
            updateOrderPs.setString(1, newStatus);
            updateOrderPs.setInt(2, orderId);
            updateOrderPs.executeUpdate();

            if (hasUser && "Completed".equalsIgnoreCase(newStatus) && !"Completed".equalsIgnoreCase(oldStatus)) {
                int earnedPoints = (int) Math.floor(totalPrice / 1000);
                updatePointPs = con.prepareStatement(updatePointSql);
                updatePointPs.setInt(1, earnedPoints);
                updatePointPs.setInt(2, userId);
                updatePointPs.executeUpdate();
            }

            con.commit();
        } catch (SQLException ex) {
            if (con != null) con.rollback();
            throw ex;
        } finally {
            if (rs != null) rs.close();
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
