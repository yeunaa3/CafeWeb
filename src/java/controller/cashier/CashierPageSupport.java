package controller.cashier;

import dao.OrderDAO;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

public final class CashierPageSupport {
    private CashierPageSupport() {}

    public static User requireCashier(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("user");
        if (!(value instanceof User)) {
            String returnUrl = request.getRequestURI().substring(request.getContextPath().length());
            response.sendRedirect(request.getContextPath() + "/login?returnUrl=" + returnUrl);
            return null;
        }
        User user = (User) value;
        if (user.getRoleId() != 2) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN);
            return null;
        }
        request.setAttribute("cashier", user);
        return user;
    }

    public static void prepare(HttpServletRequest request, String activePage, String pageTitle) {
        request.setAttribute("activePage", activePage);
        request.setAttribute("pageTitle", pageTitle);
        request.setAttribute("pendingOrderCount", new OrderDAO().countOrdersByStatus("Pending"));
        HttpSession session = request.getSession(false);
        if (session != null) {
            Object success = session.getAttribute("cashierSuccess");
            Object error = session.getAttribute("cashierError");
            if (success != null) request.setAttribute("success", success);
            if (error != null) request.setAttribute("error", error);
            session.removeAttribute("cashierSuccess");
            session.removeAttribute("cashierError");
        }
    }
}
