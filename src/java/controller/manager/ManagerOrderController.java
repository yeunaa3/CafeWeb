package controller.manager;

import dal.OrderDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.util.Arrays;
import java.util.HashSet;
import java.util.Set;

@WebServlet(name = "ManagerOrderController", urlPatterns = {"/manager/orders"})
public class ManagerOrderController extends HttpServlet {
    private static final Set<String> STATUSES = new HashSet<String>(Arrays.asList(
            "Pending", "Approved", "Processing", "Ready", "Delivering", "Completed", "Cancelled", "Refunded"));

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        String status = trim(request.getParameter("status"));
        if (!status.isEmpty() && !STATUSES.contains(status)) status = "";
        ManagerPageSupport.prepare(request, "orders", "Quản lý đơn hàng");
        OrderDAO orderDAO = new OrderDAO();
        request.setAttribute("selectedStatus", status);
        request.setAttribute("orderList", orderDAO.getManagerOrders(request.getParameter("q"), status, 100));
        int detailId = parseId(request.getParameter("detail"));
        if (detailId > 0) request.setAttribute("selectedOrder", orderDAO.getManagerOrderById(detailId));
        request.getRequestDispatcher("/jsp/manager/orders.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        if (ManagerPageSupport.requireManager(request, response) == null) return;
        int orderId = parseId(request.getParameter("id"));
        String status = trim(request.getParameter("status"));
        boolean success = false;
        if (orderId > 0 && STATUSES.contains(status)) {
            try {
                new OrderDAO().updateOrderStatusAndRewardPoints(orderId, status);
                success = true;
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        }
        request.getSession().setAttribute(success ? "managerSuccess" : "managerError",
                success ? "Đã cập nhật trạng thái đơn #" + orderId + "." : "Không thể cập nhật trạng thái đơn hàng.");
        response.sendRedirect(request.getContextPath() + "/manager/orders");
    }

    private int parseId(String value) {
        try { return Integer.parseInt(value); } catch (NumberFormatException ex) { return -1; }
    }
    private String trim(String value) { return value == null ? "" : value.trim(); }
}
