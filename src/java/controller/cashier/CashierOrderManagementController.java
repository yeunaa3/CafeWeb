package controller.cashier;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import model.ManagerOrderSummary;
import model.User;

@WebServlet(name = "CashierOrderManagementController", urlPatterns = {"/cashier/order-management"})
public class CashierOrderManagementController extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (CashierPageSupport.requireCashier(request, response) == null) return;
        String status = value(request.getParameter("status"));
        if (!status.isEmpty() && !isKnownStatus(status)) status = "";
        CashierPageSupport.prepare(request, "order-management", "Quản lý đơn hàng");
        OrderDAO orderDAO = new OrderDAO();
        request.setAttribute("selectedStatus", status);
        request.setAttribute("orderList", orderDAO.getManagerOrders(request.getParameter("q"), status, 100));
        int detailId = parseId(request.getParameter("detail"));
        if (detailId > 0) request.setAttribute("selectedOrder", orderDAO.getManagerOrderById(detailId));
        request.getRequestDispatcher("/jsp/cashier/order-management.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        User cashier = CashierPageSupport.requireCashier(request, response);
        if (cashier == null) return;
        int orderId = parseId(request.getParameter("id"));
        String status = value(request.getParameter("status"));
        boolean success = false;
        OrderDAO orderDAO = new OrderDAO();
        ManagerOrderSummary order = orderDAO.getManagerOrderById(orderId);
        boolean allowedAction = order != null
                && (("Pending".equals(order.getStatus()) && ("Approved".equals(status) || "Cancelled".equals(status)))
                || ("Approved".equals(order.getStatus()) && ("Completed".equals(status) || "Cancelled".equals(status))));
        if (allowedAction) {
            try {
                orderDAO.updateOrderStatusAndRewardPoints(orderId, status);
                success = true;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        request.getSession().setAttribute(success ? "cashierSuccess" : "cashierError",
                success ? "Đã cập nhật đơn #" + orderId + "." : "Không thể cập nhật đơn hàng.");
        response.sendRedirect(request.getContextPath() + "/cashier/order-management");
    }
    private int parseId(String value) { try { return Integer.parseInt(value); } catch (Exception ex) { return -1; } }
    private String value(String value) { return value == null ? "" : value.trim(); }
    private boolean isKnownStatus(String status) {
        return "Pending".equals(status) || "Approved".equals(status)
                || "Completed".equals(status) || "Cancelled".equals(status);
    }
}
