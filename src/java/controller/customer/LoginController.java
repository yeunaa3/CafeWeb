package controller.customer;

import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;
import model.User;

@WebServlet(name = "LoginController", urlPatterns = {"/login", "/check"})
public class LoginController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (getLoggedInUser(request) != null) {
            response.sendRedirect(request.getContextPath() + destinationFor(getLoggedInUser(request)));
            return;
        }
        request.setAttribute("returnUrl", safeReturnUrl(request.getParameter("returnUrl")));
        request.getRequestDispatcher("/jsp/auth/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        String usernameOrEmail = trim(request.getParameter("usernameOrEmail"));
        String password = request.getParameter("password");
        String returnUrl = safeReturnUrl(request.getParameter("returnUrl"));

        request.setAttribute("usernameOrEmail", usernameOrEmail);
        request.setAttribute("returnUrl", returnUrl);
        if (usernameOrEmail.isEmpty() || password == null || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập tài khoản và mật khẩu.");
            request.getRequestDispatcher("/jsp/auth/login.jsp").forward(request, response);
            return;
        }

        User user = new UserDAO().authenticate(usernameOrEmail, password);
        if (user == null) {
            request.setAttribute("error", "Tài khoản hoặc mật khẩu không chính xác.");
            request.getRequestDispatcher("/jsp/auth/login.jsp").forward(request, response);
            return;
        }
        if (!user.isStatus()) {
            request.setAttribute("error", "Tài khoản đã bị khóa. Vui lòng liên hệ quản lý.");
            request.getRequestDispatcher("/jsp/auth/login.jsp").forward(request, response);
            return;
        }

        HttpSession session = request.getSession();
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getUserId());
        session.setMaxInactiveInterval(30 * 60);

        if (user.getRoleId() == 3 && isCustomerReturnUrl(returnUrl)) {
            response.sendRedirect(request.getContextPath() + returnUrl);
        } else {
            response.sendRedirect(request.getContextPath() + destinationFor(user));
        }
    }

    private User getLoggedInUser(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        Object value = session == null ? null : session.getAttribute("user");
        return value instanceof User ? (User) value : null;
    }

    private String safeReturnUrl(String value) {
        String url = trim(value);
        if (!url.startsWith("/") || url.startsWith("//") || url.contains(":") || url.contains("\\")) {
            return "";
        }
        return url;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private boolean isCustomerReturnUrl(String returnUrl) {
        return returnUrl.equals("/menu")
                || returnUrl.equals("/checkout")
                || returnUrl.equals("/checkout/payment")
                || returnUrl.equals("/profile")
                || returnUrl.equals("/redeem");
    }

    private String destinationFor(User user) {
        if (user.getRoleId() == 1) return "/manager/dashboard";
        if (user.getRoleId() == 2) return "/cashier/order";
        if (user.getRoleId() == 3) return "/profile";
        return "/home";
    }
}
