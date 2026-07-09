package controller.customer;

import dal.OrderDAO;
import dal.VoucherDAO;
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
import model.VoucherValidationResult;

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
        String voucherCode = trim(request.getParameter("voucherCode"));

        Integer currentUserId = getCurrentUserId(request);
        if (currentUserId == null) {
            response.sendRedirect(request.getContextPath() + "/login?returnUrl=/checkout");
            return;
        }

        if (cart.isEmpty()) {
            request.setAttribute("error", "Giỏ hàng đang trống.");
            prepareCheckout(request);
            request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
            return;
        }
        if (shippingAddress.isEmpty() || phone.isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập đầy đủ địa chỉ và số điện thoại.");
            prepareCheckout(request);
            request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
            return;
        }
        if (!phone.matches("0[0-9]{9,10}")) {
            request.setAttribute("error", "Số điện thoại không hợp lệ.");
            prepareCheckout(request);
            request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
            return;
        }

        double cartTotal = CartController.getCartTotal(request);
        VoucherValidationResult voucherResult = new VoucherDAO().validateVoucher(voucherCode, cartTotal, currentUserId);
        if (!voucherResult.isValid()) {
            request.setAttribute("error", voucherResult.getMessage());
            prepareCheckout(request);
            request.getRequestDispatcher("/jsp/customer/checkout.jsp").forward(request, response);
            return;
        }

        try {
            OrderDAO orderDAO = new OrderDAO();
            Integer voucherId = voucherResult.getVoucher() == null ? null : voucherResult.getVoucher().getVoucherId();
            int orderId = orderDAO.createOnlineOrder(currentUserId, cart, shippingAddress, phone, note,
                    voucherId, voucherResult.getDiscountAmount());
            request.getSession().removeAttribute(CartController.CART_SESSION_KEY);
            request.setAttribute("successOrderId", orderId);
            request.setAttribute("appliedDiscount", voucherResult.getDiscountAmount());
        } catch (SQLException ex) {
            request.setAttribute("error", "Không thể tạo đơn hàng. Vui lòng thử lại.");
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
