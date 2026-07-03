package controller.customer;

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
import model.CartItem;
import model.User;

@WebServlet(name = "CheckoutController", urlPatterns = {"/checkout"})
public class CheckoutController extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        prepareCheckout(request);
        request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.setCharacterEncoding("UTF-8");
        List<CartItem> cart = CartController.getCart(request);
        String shippingAddress = trim(request.getParameter("shippingAddress"));
        String phone = trim(request.getParameter("phone"));
        String note = trim(request.getParameter("note"));

        if (cart.isEmpty()) {
            request.setAttribute("error", "Gio hang dang trong.");
            prepareCheckout(request);
            request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
            return;
        }
        if (shippingAddress.isEmpty() || phone.isEmpty()) {
            request.setAttribute("error", "Vui long nhap day du dia chi va so dien thoai.");
            prepareCheckout(request);
            request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
            return;
        }
        if (!phone.matches("0[0-9]{9,10}")) {
            request.setAttribute("error", "So dien thoai khong hop le.");
            prepareCheckout(request);
            request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
            return;
        }

        try {
            OrderDAO orderDAO = new OrderDAO();
            int orderId = orderDAO.createOnlineOrder(getCurrentUserId(request), cart, shippingAddress, phone, note);
            request.getSession().removeAttribute(CartController.CART_SESSION_KEY);
            request.setAttribute("successOrderId", orderId);
        } catch (SQLException ex) {
            request.setAttribute("error", "Khong the tao don hang. Vui long thu lai.");
        }
        prepareCheckout(request);
        request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
    }

    private void prepareCheckout(HttpServletRequest request) {
        request.setAttribute("cart", CartController.getCart(request));
        request.setAttribute("cartCount", CartController.getCartCount(request));
        request.setAttribute("cartTotal", CartController.getCartTotal(request));
    }

    private Integer getCurrentUserId(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return null;
        }
        Object user = session.getAttribute("user");
        if (user instanceof User) {
            return ((User) user).getUserId();
        }
        Object userId = session.getAttribute("userId");
        if (userId instanceof Integer) {
            return (Integer) userId;
        }
        return null;
    }

    private String trim(String value) {
        return value == null ? "" : value.trim();
    }
}
