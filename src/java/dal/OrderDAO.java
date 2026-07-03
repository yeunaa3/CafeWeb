package dal;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.List;
import model.CartItem;
import model.Topping;

public class OrderDAO extends DBContext {

    public int createOnlineOrder(Integer userId, List<CartItem> cart, String shippingAddress, String phone, String note) throws SQLException {
        if (cart == null || cart.isEmpty()) {
            throw new SQLException("Cart is empty");
        }

        Connection con = null;
        PreparedStatement orderPs = null;
        PreparedStatement detailPs = null;
        PreparedStatement toppingPs = null;
        ResultSet generatedKeys = null;

        String orderSql = "INSERT INTO Orders (user_id, staff_id, voucher_id, total_price, discount_amount, status, order_type, shipping_address, payment_method, note) "
                + "VALUES (?, NULL, NULL, ?, 0, ?, ?, ?, ?, ?)";
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
            orderPs.setDouble(2, calculateTotal(cart));
            orderPs.setString(3, "Pending");
            orderPs.setString(4, "Online");
            orderPs.setString(5, shippingAddress);
            orderPs.setString(6, "Cash");
            orderPs.setString(7, buildOrderNote(phone, note));
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
}
