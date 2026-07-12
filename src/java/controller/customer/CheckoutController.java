package controller.customer;

import dao.VoucherDAO;
import java.io.IOException;
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
        if (request.getParameter("successOrderId") != null) {
            request.setAttribute("successOrderId", request.getParameter("successOrderId"));
        }
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

        HttpSession session = request.getSession();
        session.setAttribute("checkoutShippingAddress", shippingAddress);
        session.setAttribute("checkoutPhone", phone);
        session.setAttribute("checkoutNote", note);
        session.setAttribute("checkoutVoucherCode", voucherCode);

        request.setAttribute("shippingAddress", shippingAddress);
        request.setAttribute("phone", phone);
        request.setAttribute("note", note);
        request.setAttribute("voucherCode", voucherCode);
        request.setAttribute("cartTotal", cartTotal);
        request.setAttribute("appliedDiscount", voucherResult.getDiscountAmount());
        request.setAttribute("payableTotal", Math.max(0, cartTotal - voucherResult.getDiscountAmount()));
        request.getRequestDispatcher("/jsp/customer/checkout-payment.jsp").forward(request, response);
    }

    private void prepareCheckout(HttpServletRequest request) {
        double total = CartController.getCartTotal(request);
        request.setAttribute("cart", CartController.getCart(request));
        request.setAttribute("cartCount", CartController.getCartCount(request));
        request.setAttribute("cartTotal", total);
        if (request.getAttribute("appliedDiscount") == null) {
            request.setAttribute("appliedDiscount", 0);
        }
        if (request.getAttribute("payableTotal") == null) {
            request.setAttribute("payableTotal", total);
        }
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
