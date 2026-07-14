package dao;

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
import model.DashboardSummary;
import model.ManagerOrderSummary;
import model.ProductSalesStat;
import model.RevenueStat;
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
        PreparedStatement paymentPs = null;
        PreparedStatement voucherLockPs = null;
        PreparedStatement consumeVoucherPs = null;
        ResultSet generatedKeys = null;
        ResultSet voucherRs = null;

        String orderSql = "INSERT INTO Orders (user_id, staff_id, voucher_id, total_price, discount_amount, status, order_type, shipping_address, shipping_phone, payment_method, note) "
                + "VALUES (?, NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        String detailSql = "INSERT INTO OrderDetails (order_id, product_id, quantity, selected_size, ice_level, sugar_level, price) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?)";
        String toppingSql = "INSERT INTO OrderDetailToppings (order_detail_id, topping_id, topping_price) VALUES (?, ?, ?)";
        String paymentSql = "INSERT INTO Payments(order_id, payment_method, amount, amount_received, change_amount, payment_status, paid_at) "
                + "VALUES (?, ?, ?, ?, 0, 'Paid', SYSDATETIME())";
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
            orderPs.setString(9, "QR-Code");
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

            double payableTotal = originalTotal - appliedDiscount;
            paymentPs = con.prepareStatement(paymentSql);
            paymentPs.setInt(1, orderId);
            paymentPs.setString(2, "QR-Code");
            paymentPs.setDouble(3, payableTotal);
            paymentPs.setDouble(4, payableTotal);
            paymentPs.executeUpdate();

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
            if (paymentPs != null) paymentPs.close();
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

    public int countOrdersByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM Orders WHERE status = ?";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setString(1, status);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return 0;
        } finally {
            closeConnection(con, ps, rs);
        }
    }

    public int createCounterOrder(int staffId, List<CartItem> cart, String paymentMethod,
            Integer voucherId, double discountAmount, double amountReceived) throws SQLException {
        if (cart == null || cart.isEmpty()) throw new SQLException("Cart is empty");
        double originalTotal = calculateTotal(cart);
        double appliedDiscount = Math.max(0, Math.min(discountAmount, originalTotal));
        double payable = originalTotal - appliedDiscount;
        if ("Cash".equals(paymentMethod) && amountReceived < payable) {
            throw new SQLException("Received amount is not enough");
        }

        String orderSql = "INSERT INTO Orders(user_id,staff_id,voucher_id,total_price,discount_amount,status,"
                + "order_type,payment_method,note) VALUES(NULL,?,?,?,?,?,'At-Counter',?,NULL)";
        String detailSql = "INSERT INTO OrderDetails(order_id,product_id,quantity,selected_size,ice_level,"
                + "sugar_level,price,note) VALUES(?,?,?,?,?,?,?,?)";
        String toppingSql = "INSERT INTO OrderDetailToppings(order_detail_id,topping_id,topping_price) VALUES(?,?,?)";
        String paymentSql = "INSERT INTO Payments(order_id,payment_method,amount,amount_received,change_amount,"
                + "payment_status,paid_at) VALUES(?,?,?,?,?,'Paid',SYSDATETIME())";
        String historySql = "INSERT INTO OrderStatusHistory(order_id,old_status,new_status,changed_by,note) "
                + "VALUES(?,NULL,'Completed',?,N'Đơn tại quầy đã thanh toán')";
        Connection con = null;
        PreparedStatement orderPs = null;
        PreparedStatement detailPs = null;
        PreparedStatement toppingPs = null;
        PreparedStatement paymentPs = null;
        PreparedStatement historyPs = null;
        ResultSet keys = null;
        try {
            con = getConnection();
            con.setAutoCommit(false);
            orderPs = con.prepareStatement(orderSql, Statement.RETURN_GENERATED_KEYS);
            orderPs.setInt(1, staffId);
            if (voucherId == null) orderPs.setNull(2, java.sql.Types.INTEGER); else orderPs.setInt(2, voucherId);
            orderPs.setDouble(3, payable);
            orderPs.setDouble(4, appliedDiscount);
            orderPs.setString(5, "Completed");
            orderPs.setString(6, paymentMethod);
            orderPs.executeUpdate();
            keys = orderPs.getGeneratedKeys();
            if (!keys.next()) throw new SQLException("Cannot create counter order");
            int orderId = keys.getInt(1);
            keys.close();
            keys = null;

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
                detailPs.setString(8, item.getNote());
                detailPs.executeUpdate();
                try (ResultSet detailKeys = detailPs.getGeneratedKeys()) {
                    if (detailKeys.next() && item.getToppings() != null) {
                        int detailId = detailKeys.getInt(1);
                        for (Topping topping : item.getToppings()) {
                            toppingPs.setInt(1, detailId);
                            toppingPs.setInt(2, topping.getToppingId());
                            toppingPs.setDouble(3, topping.getPrice());
                            toppingPs.addBatch();
                        }
                        toppingPs.executeBatch();
                    }
                }
            }

            double received = "Cash".equals(paymentMethod) ? amountReceived : payable;
            paymentPs = con.prepareStatement(paymentSql);
            paymentPs.setInt(1, orderId);
            paymentPs.setString(2, paymentMethod);
            paymentPs.setDouble(3, payable);
            paymentPs.setDouble(4, received);
            paymentPs.setDouble(5, Math.max(0, received - payable));
            paymentPs.executeUpdate();

            historyPs = con.prepareStatement(historySql);
            historyPs.setInt(1, orderId);
            historyPs.setInt(2, staffId);
            historyPs.executeUpdate();
            con.commit();
            return orderId;
        } catch (SQLException ex) {
            if (con != null) con.rollback();
            throw ex;
        } finally {
            if (keys != null) keys.close();
            if (historyPs != null) historyPs.close();
            if (paymentPs != null) paymentPs.close();
            if (toppingPs != null) toppingPs.close();
            if (detailPs != null) detailPs.close();
            if (orderPs != null) orderPs.close();
            if (con != null) {
                con.setAutoCommit(true);
                con.close();
            }
        }
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

    public List<ManagerOrderSummary> getManagerOrders(String keyword, String status, int limit) {
        List<ManagerOrderSummary> orders = new ArrayList<ManagerOrderSummary>();
        String search = keyword == null ? "" : keyword.trim();
        String state = status == null ? "" : status.trim();
        String sql = "SELECT TOP (?) o.order_id, COALESCE(u.full_name, N'Khách vãng lai') AS customer_name, "
                + "o.order_date, o.total_price, o.status, o.order_type, o.payment_method, "
                + "o.shipping_address, o.shipping_phone, o.note, "
                + "COALESCE(STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT(p.product_name, N' ×', od.quantity)), N', '), N'') AS items "
                + "FROM Orders o LEFT JOIN Users u ON u.user_id=o.user_id "
                + "LEFT JOIN OrderDetails od ON od.order_id=o.order_id "
                + "LEFT JOIN Products p ON p.product_id=od.product_id "
                + "WHERE (?='' OR CAST(o.order_id AS VARCHAR(20)) LIKE ? OR u.full_name LIKE ?) "
                + "AND (?='' OR o.status=?) "
                + "GROUP BY o.order_id, u.full_name, o.order_date, o.total_price, o.status, o.order_type, "
                + "o.payment_method, o.shipping_address, o.shipping_phone, o.note "
                + "ORDER BY o.order_date DESC, o.order_id DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, limit);
            ps.setString(2, search);
            ps.setString(3, "%" + search + "%");
            ps.setString(4, "%" + search + "%");
            ps.setString(5, state);
            ps.setString(6, state);
            rs = ps.executeQuery();
            while (rs.next()) orders.add(mapManagerOrder(rs));
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        return orders;
    }

    public ManagerOrderSummary getManagerOrderById(int orderId) {
        String sql = "SELECT o.order_id, COALESCE(u.full_name, N'Khách vãng lai') AS customer_name, "
                + "o.order_date, o.total_price, o.status, o.order_type, o.payment_method, "
                + "o.shipping_address, o.shipping_phone, o.note, "
                + "COALESCE(STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT(p.product_name, N' ×', od.quantity, "
                + "N' (', od.selected_size, N', đá ', od.ice_level, N', đường ', od.sugar_level, N')')), N', '), N'') AS items "
                + "FROM Orders o LEFT JOIN Users u ON u.user_id=o.user_id "
                + "LEFT JOIN OrderDetails od ON od.order_id=o.order_id "
                + "LEFT JOIN Products p ON p.product_id=od.product_id WHERE o.order_id=? "
                + "GROUP BY o.order_id, u.full_name, o.order_date, o.total_price, o.status, o.order_type, "
                + "o.payment_method, o.shipping_address, o.shipping_phone, o.note";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, orderId);
            rs = ps.executeQuery();
            return rs.next() ? mapManagerOrder(rs) : null;
        } catch (SQLException ex) {
            ex.printStackTrace();
            return null;
        } finally {
            closeConnection(con, ps, rs);
        }
    }

    public DashboardSummary getDashboardSummary(int days) {
        int safeDays = days < 1 ? 7 : days;
        DashboardSummary summary = new DashboardSummary();
        loadDashboardMetrics(summary, safeDays);
        loadRevenueStats(summary, safeDays);
        loadTopProducts(summary, safeDays);
        loadRecentOrders(summary, safeDays);
        return summary;
    }

    private void loadDashboardMetrics(DashboardSummary summary, int days) {
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM Products WHERE status=1) AS product_count, "
                + "(SELECT COUNT(*) FROM Orders WHERE CAST(order_date AS DATE)=CAST(GETDATE() AS DATE)) AS today_orders, "
                + "(SELECT COALESCE(SUM(total_price),0) FROM Orders WHERE status='Completed' "
                + "AND CAST(order_date AS DATE)=CAST(GETDATE() AS DATE)) AS today_revenue, "
                + "(SELECT COALESCE(SUM(total_price),0) FROM Orders WHERE status='Completed' "
                + "AND order_date>=DATEADD(day, 1-?, CAST(GETDATE() AS DATE))) AS total_revenue, "
                + "(SELECT COUNT(*) FROM Users WHERE role_id=3 AND status=1) AS customer_count";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, days);
            rs = ps.executeQuery();
            if (rs.next()) {
                summary.setActiveProductCount(rs.getInt("product_count"));
                summary.setTodayOrderCount(rs.getInt("today_orders"));
                summary.setTodayRevenue(rs.getDouble("today_revenue"));
                summary.setTotalRevenue(rs.getDouble("total_revenue"));
                summary.setCustomerCount(rs.getInt("customer_count"));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
    }

    private void loadRevenueStats(DashboardSummary summary, int days) {
        List<RevenueStat> stats = new ArrayList<RevenueStat>();
        String sql = "SELECT CAST(order_date AS DATE) AS revenue_date, COUNT(*) AS order_count, "
                + "SUM(total_price) AS revenue FROM Orders WHERE status='Completed' "
                + "AND order_date>=DATEADD(day, 1-?, CAST(GETDATE() AS DATE)) "
                + "GROUP BY CAST(order_date AS DATE) ORDER BY revenue_date";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        double maximum = 0;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, days);
            rs = ps.executeQuery();
            while (rs.next()) {
                RevenueStat stat = new RevenueStat();
                stat.setRevenueDate(rs.getDate("revenue_date"));
                stat.setOrderCount(rs.getInt("order_count"));
                stat.setRevenue(rs.getDouble("revenue"));
                maximum = Math.max(maximum, stat.getRevenue());
                stats.add(stat);
            }
            for (RevenueStat stat : stats) {
                stat.setPercentage(maximum == 0 ? 0 : Math.max(8, stat.getRevenue() * 100 / maximum));
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        summary.setRevenueStats(stats);
    }

    private void loadTopProducts(DashboardSummary summary, int days) {
        List<ProductSalesStat> products = new ArrayList<ProductSalesStat>();
        String sql = "SELECT TOP 6 p.product_id, p.product_name, SUM(od.quantity) AS quantity_sold, "
                + "SUM(od.quantity*od.price) AS revenue FROM OrderDetails od "
                + "JOIN Orders o ON o.order_id=od.order_id JOIN Products p ON p.product_id=od.product_id "
                + "WHERE o.status='Completed' AND o.order_date>=DATEADD(day, 1-?, CAST(GETDATE() AS DATE)) "
                + "GROUP BY p.product_id,p.product_name "
                + "ORDER BY quantity_sold DESC, revenue DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, days);
            rs = ps.executeQuery();
            while (rs.next()) {
                ProductSalesStat product = new ProductSalesStat();
                product.setProductId(rs.getInt("product_id"));
                product.setProductName(rs.getString("product_name"));
                product.setQuantitySold(rs.getInt("quantity_sold"));
                product.setRevenue(rs.getDouble("revenue"));
                products.add(product);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        summary.setTopProducts(products);
    }

    private void loadRecentOrders(DashboardSummary summary, int days) {
        List<ManagerOrderSummary> orders = new ArrayList<ManagerOrderSummary>();
        String sql = "SELECT TOP 6 o.order_id, COALESCE(u.full_name, N'Khách vãng lai') AS customer_name, "
                + "o.order_date, o.total_price, o.status, o.order_type, o.payment_method, "
                + "o.shipping_address, o.shipping_phone, o.note, "
                + "COALESCE(STRING_AGG(CONVERT(NVARCHAR(MAX), CONCAT(p.product_name, N' ×', od.quantity)), N', '), N'') AS items "
                + "FROM Orders o LEFT JOIN Users u ON u.user_id=o.user_id "
                + "LEFT JOIN OrderDetails od ON od.order_id=o.order_id "
                + "LEFT JOIN Products p ON p.product_id=od.product_id "
                + "WHERE o.order_date>=DATEADD(day, 1-?, CAST(GETDATE() AS DATE)) "
                + "GROUP BY o.order_id, u.full_name, o.order_date, o.total_price, o.status, o.order_type, "
                + "o.payment_method, o.shipping_address, o.shipping_phone, o.note "
                + "ORDER BY o.order_date DESC, o.order_id DESC";
        Connection con = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            con = getConnection();
            ps = con.prepareStatement(sql);
            ps.setInt(1, days);
            rs = ps.executeQuery();
            while (rs.next()) orders.add(mapManagerOrder(rs));
        } catch (SQLException ex) {
            ex.printStackTrace();
        } finally {
            closeConnection(con, ps, rs);
        }
        summary.setRecentOrders(orders);
    }
    private ManagerOrderSummary mapManagerOrder(ResultSet rs) throws SQLException {
        ManagerOrderSummary order = new ManagerOrderSummary();
        order.setOrderId(rs.getInt("order_id"));
        order.setCustomerName(rs.getString("customer_name"));
        order.setOrderDate(rs.getTimestamp("order_date"));
        order.setTotalPrice(rs.getDouble("total_price"));
        order.setStatus(rs.getString("status"));
        order.setOrderType(rs.getString("order_type"));
        order.setPaymentMethod(rs.getString("payment_method"));
        order.setShippingAddress(rs.getString("shipping_address"));
        order.setShippingPhone(rs.getString("shipping_phone"));
        order.setNote(rs.getString("note"));
        order.setItems(rs.getString("items"));
        return order;
    }

}

