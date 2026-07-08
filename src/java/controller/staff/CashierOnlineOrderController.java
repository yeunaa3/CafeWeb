package controller.staff;

import dal.OrderDAO;
import java.io.IOException;
import java.sql.SQLException;
import java.util.List;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.CashierOrderView;
import model.User;

@WebServlet(name = "CashierOnlineOrderController", urlPatterns = {"/cashier/orders"})
public class CashierOnlineOrderController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        loadOrders(request);
        request.getRequestDispatcher("/jsp/staff/online-orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String action = trim(request.getParameter("action"));
        int orderId = parseInt(request.getParameter("orderId"), 0);
        int staffId = getCurrentStaffId(request);
        OrderDAO orderDAO = new OrderDAO();

        try {
            if (orderId <= 0) {
                throw new SQLException("Order id is invalid");
            }
            if ("approve".equals(action)) {
                orderDAO.approveOnlineOrder(orderId, staffId);
                request.setAttribute("success", "Đã duyệt đơn #" + orderId + " và chuyển xuống bar.");
            } else if ("reject".equals(action)) {
                orderDAO.rejectOnlineOrder(orderId, staffId);
                request.setAttribute("success", "Đã từ chối đơn #" + orderId + " và ghi nhận hoàn tiền.");
            } else if ("pay".equals(action)) {
                String paymentMethod = trim(request.getParameter("paymentMethod"));
                double amountReceived = parseMoney(request.getParameter("amountReceived"));
                OrderDAO.PaymentResult result = orderDAO.confirmPayment(orderId, staffId, paymentMethod, amountReceived);
                request.setAttribute("success", "Đơn #" + orderId + " đã thanh toán. Tiền thừa: "
                        + formatVnd(result.getChangeAmount()) + "đ. Đã kích hoạt in hóa đơn giấy.");
                request.setAttribute("printOrderId", orderId);
            } else {
                request.setAttribute("error", "Thao tác không hợp lệ.");
            }
        } catch (SQLException ex) {
            request.setAttribute("error", ex.getMessage());
        }

        loadOrders(request);
        request.getRequestDispatcher("/jsp/staff/online-orders.jsp").forward(request, response);
    }

    private void loadOrders(HttpServletRequest request) {
        List<CashierOrderView> orders = new OrderDAO().getOnlineOrdersForCashier();
        request.setAttribute("orders", orders);
    }

    private int getCurrentStaffId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object user = session.getAttribute("user");
            if (user instanceof User) {
                return ((User) user).getUserId();
            }
            Object userId = session.getAttribute("userId");
            if (userId instanceof Integer) {
                return (Integer) userId;
            }
        }
        return 2;
    }

    private int parseInt(String value, int fallback) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException ex) {
            return fallback;
        }
    }

    private double parseMoney(String value) {
        if (value == null) {
            return 0;
        }
        String normalized = value.replace(".", "").replace(",", "").trim();
        if (normalized.isEmpty()) {
            return 0;
        }
        try {
            return Double.parseDouble(normalized);
        } catch (NumberFormatException ex) {
            return 0;
        }
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private String formatVnd(double value) {
        return String.format("%,.0f", value).replace(",", ".");
    }
}
